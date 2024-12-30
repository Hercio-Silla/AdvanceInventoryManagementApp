//
//  EditItemView.swift
//  AdvanceInvetoryManagementApp
//
//  Created by Hercio Venceslau Silla on 27/12/24.
//

import SwiftUI
import FirebaseFirestore

struct EditItemView: View {
    @State var item: Item
    @ObservedObject var viewModel: InventoryViewModel
    @State private var name: String
    @State private var description: String
    @State private var price: Double
    @State private var category: String
    @State private var stock: Int
    @State private var photoPath: String
    @State private var selectedSupplier: String
    @State private var suppliers: [(id: String, name: String)] = []


    @Environment(\.presentationMode) var presentationMode // To dismiss the view after saving

    init(item: Item, viewModel: InventoryViewModel) {
        _item = State(initialValue: item)
        _viewModel = ObservedObject(wrappedValue: viewModel)
        _name = State(initialValue: item.name)
        _description = State(initialValue: item.description)
        _price = State(initialValue: item.price)
        _category = State(initialValue: item.category)
        _stock = State(initialValue: item.stock)
        _photoPath = State(initialValue: item.photoPath)
        _selectedSupplier = State(initialValue: item.supplierId)
    }

    var body: some View {
        VStack {
            Section(header: Text("Nama Barang")) {
                TextField("Nama Barang", text: $name)
                    .padding()
                    .textFieldStyle(RoundedBorderTextFieldStyle())
            }

            TextField("Deskripsi", text: $description)
                .padding()
                .textFieldStyle(RoundedBorderTextFieldStyle())

            TextField("Harga", value: $price, format: .currency(code: "IDR"))
                .padding()
                .keyboardType(.decimalPad)

            TextField("Kategori", text: $category)
                .padding()
                .textFieldStyle(RoundedBorderTextFieldStyle())

            TextField("Stok", value: $stock, format: .number)
                .padding()
                .keyboardType(.numberPad)

            TextField("Photo Path", text: $photoPath)
                .padding()
                .textFieldStyle(RoundedBorderTextFieldStyle())

            Picker("Pilih Supplier", selection: $selectedSupplier) {
                ForEach(suppliers, id: \.id) { supplier in
                    Text(supplier.name)
                }
            }
            .pickerStyle(MenuPickerStyle())

            Button("Simpan") {
                saveChanges()
            }
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(8)
        }
        .padding()
        .navigationTitle("Edit Barang")
        .onAppear {
            fetchSuppliers()
        }
    }

    private func fetchSuppliers() {
        let db = Firestore.firestore()
        db.collection("suppliers").getDocuments { snapshot, error in
            if let error = error {
                print("Error fetching suppliers: \(error)")
                return
            }

            if let snapshot = snapshot {
                self.suppliers = snapshot.documents.compactMap { document in
                    guard let name = document.data()["name"] as? String else {
                        print("Dokumen tanpa nama ditemukan: \(document.documentID)")
                        return nil
                    }
                    return (id: document.documentID, name: name) // Simpan ID dan nama supplier
                }

                // Tentukan supplier yang dipilih berdasarkan ID yang cocok
                if let supplier = suppliers.first(where: { $0.id == item.supplierId }) {
                    self.selectedSupplier = supplier.id
                } else {
                    self.selectedSupplier = suppliers.first?.id ?? ""
                }
            }
        }
    }


    private func saveChanges() {
        let updatedItem = Item(
            id: item.id,
            name: name,
            description: description,
            price: price,
            category: category,
            stock: stock,
            photoPath: photoPath,
            supplierId: selectedSupplier
        )

        // Update the item in Firestore through the viewModel
        viewModel.updateItem(updatedItem)

        // Dismiss the current view
        presentationMode.wrappedValue.dismiss()
    }
}

struct EditItemView_Previews: PreviewProvider {
    static var previews: some View {
        let mockViewModel = InventoryViewModel()
        let mockItem = Item(
            id: "1",
            name: "Item 1",
            description: "Description 1",
            price: 100.0,
            category: "Category 1",
            stock: 10,
            photoPath: "https://example.com/photo1.jpg",
            supplierId: "supplier_1"
        )
        return EditItemView(item: mockItem, viewModel: mockViewModel)
    }
}


