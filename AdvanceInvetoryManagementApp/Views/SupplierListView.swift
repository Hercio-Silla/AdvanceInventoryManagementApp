//
//  SupplierListView.swift
//  AdvanceInvetoryManagementApp
//
//  Created by Hercio Venceslau Silla on 23/12/24.
//

import SwiftUI
import FirebaseFirestore

struct SupplierListView: View {
    @State private var suppliers = [Supplier]()
    @ObservedObject var viewModel: InventoryViewModel

    private let db = Firestore.firestore()

    var body: some View {
        NavigationStack {
            VStack {
                List {
                    ForEach(suppliers) { supplier in
                        SupplierListRow(
                            supplier: supplier,
                            onDelete: { deleteSupplier(supplier) }
                        )
                    }
                }

                NavigationLink(destination: SupplierAddView()) {
                    Text("Tambah Supplier")
                        .foregroundColor(.blue)
                        .padding()
                        .background(RoundedRectangle(cornerRadius: 8).stroke(Color.blue, lineWidth: 2))
                }
                .padding()
            }
            .onAppear {
                fetchSuppliers()
            }
            .navigationTitle("Daftar Supplier")
        }
    }

    func fetchSuppliers() {
        db.collection("suppliers").addSnapshotListener { snapshot, error in
            if let error = error {
                print("Error fetching suppliers: \(error)")
            } else {
                suppliers = snapshot?.documents.compactMap { document in
                    let data = document.data()
                    let id = document.documentID
                    guard let name = data["name"] as? String,
                          let address = data["address"] as? String,
                          let contact = data["contact"] as? String,
                          let locationData = data["location"] as? [String: Double],
                          let latitude = locationData["latitude"],
                          let longitude = locationData["longitude"] else {
                        return nil
                    }
                    return Supplier(
                        id: id,
                        name: name,
                        address: address,
                        contact: contact,
                        location: Supplier.Location(latitude: latitude, longitude: longitude)
                    )
                } ?? []
            }
        }
    }

    func deleteSupplier(_ supplier: Supplier) {
        db.collection("suppliers").document(supplier.id).delete { error in
            if let error = error {
                print("Error deleting supplier: \(error)")
            }
        }
        suppliers.removeAll { $0.id == supplier.id }
    }
}

struct SupplierListRow: View {
    var supplier: Supplier
    var onDelete: () -> Void

    var body: some View {
        NavigationLink(destination: SupplierDetailView(supplier: supplier)) {
            SupplierRow(supplier: supplier)
                .padding(.vertical, 5)
        }
        .swipeActions(edge: .trailing) {
            // Tombol Edit
            NavigationLink(destination: EditSupplierView(supplier: supplier, viewModel: InventoryViewModel())) {
                Label("Edit", systemImage: "pencil")
            }
            .tint(.blue)

            // Tombol Delete
            Button(role: .destructive, action: onDelete) {
                Label("Delete", systemImage: "trash")
            }
        }
    }
}

struct SupplierRow: View {
    var supplier: Supplier

    var body: some View {
        VStack(alignment: .leading) {
            Text(supplier.name)
                .font(.headline)
            Text(supplier.address)
                .font(.subheadline)
        }
    }
}

struct SupplierListView_Previews: PreviewProvider {
    static var previews: some View {
        SupplierListView(viewModel: InventoryViewModel())
    }
}





