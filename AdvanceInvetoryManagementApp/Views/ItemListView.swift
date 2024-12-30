//
//  ItemListView.swift
//  AdvanceInvetoryManagementApp
//
//  Created by Hercio Venceslau Silla on 23/12/24.
//

import SwiftUI
import FirebaseFirestore

struct ItemListView: View {
    @State private var items = [Item]()
    @State private var selectedSupplier: Supplier?
    @State private var isShowingAddItemView = false
    @ObservedObject var viewModel: InventoryViewModel

    private let db = Firestore.firestore()

    var body: some View {
        NavigationStack {
            VStack {
                Button(action: {
                    isShowingAddItemView.toggle()
                }) {
                    HStack {
                        Image(systemName: "plus.circle.fill")
                            .foregroundColor(.blue)
                        Text("Tambah Barang")
                            .font(.headline)
                            .foregroundColor(.blue)
                    }
                    .padding()
                }

                List {
                    ForEach(viewModel.items) { item in // Menggunakan viewModel.items
                        NavigationLink(destination: ItemDetailView(item: item, viewModel: viewModel)) {
                            HStack {
                                if let photoURL = URL(string: item.photoPath) {
                                    AsyncImage(url: photoURL) { image in
                                        image
                                            .resizable()
                                            .scaledToFill()
                                            .frame(width: 50, height: 50)
                                            .cornerRadius(8)
                                    } placeholder: {
                                        ProgressView()
                                            .frame(width: 50, height: 50)
                                    }
                                } else {
                                    Image(systemName: "photo")
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 50, height: 50)
                                        .cornerRadius(8)
                                        .foregroundColor(.gray)
                                }

                                VStack(alignment: .leading) {
                                    Text(item.name)
                                        .font(.headline)
                                    Text(item.category)
                                        .font(.subheadline)
                                        .foregroundColor(.gray)
                                }
                            }
                            .padding(.vertical, 5)
                        }
                        .swipeActions(edge: .trailing) {
                            NavigationLink(destination: EditItemView(item: item, viewModel: viewModel)) {
                                Label("Edit", systemImage: "pencil")
                            }
                            .tint(.blue)

                            Button(role: .destructive) {
                                viewModel.deleteItem(at: IndexSet(integer: viewModel.items.firstIndex(where: { $0.id == item.id })!))
                            } label: {
                                Label("Hapus", systemImage: "trash")
                            }
                        }
                    }
                }
                .onAppear {
                    viewModel.loadItemsFromFirestore() // Pastikan data di-load dari Firestore
                }
            }
            .navigationTitle("Daftar Barang")
            .sheet(isPresented: $isShowingAddItemView) {
                AddItemView()
            }
        }
    }

    func fetchItems() {
        db.collection("items").addSnapshotListener { snapshot, error in
            if let error = error {
                print("Error fetching items: \(error)")
            } else {
                items = snapshot?.documents.compactMap { document in
                    let data = document.data()

                    let id = document.documentID
                    guard let name = data["name"] as? String,
                          let description = data["description"] as? String,
                          let price = data["price"] as? Double,
                          let category = data["category"] as? String,
                          let stock = data["stock"] as? Int,
                          let photoPath = data["photoPath"] as? String,
                          let supplierId = data["supplierId"] as? String else {
                        return nil
                    }

                    return Item(
                        id: id,
                        name: name,
                        description: description,
                        price: price,
                        category: category,
                        stock: stock,
                        photoPath: photoPath,
                        supplierId: supplierId
                    )
                } ?? []
            }
        }
    }

    func deleteItem(_ item: Item) {
        db.collection("items").document(item.id).delete { error in
            if let error = error {
                print("Error deleting item: \(error)")
            }
        }
        items.removeAll { $0.id == item.id }
    }
}
struct ItemRow: View {
    var item: Item

    var body: some View {
        VStack(alignment: .leading) {
            Text(item.name)
                .font(.headline)
            Text(item.category)
                .font(.subheadline)
                .foregroundColor(.gray)
        }
    }
}

struct ItemListView_Previews: PreviewProvider {
    static var previews: some View {
        ItemListView(viewModel: InventoryViewModel())
    }
}










