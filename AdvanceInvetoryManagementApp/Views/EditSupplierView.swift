//
//  EditSupplierView.swift
//  AdvanceInvetoryManagementApp
//
//  Created by Hercio Venceslau Silla on 27/12/24.
//

import Foundation
import SwiftUI
import FirebaseFirestore

struct EditSupplierView: View {
    @State private var name: String
    @State private var address: String
    @State private var contact: String
    @State private var latitude: Double
    @State private var longitude: Double
    @ObservedObject var viewModel: InventoryViewModel

    var supplier: Supplier

    init(supplier: Supplier, viewModel: InventoryViewModel) {
        _name = State(initialValue: supplier.name)
        _address = State(initialValue: supplier.address)
        _contact = State(initialValue: supplier.contact)
        _latitude = State(initialValue: supplier.location.latitude)
        _longitude = State(initialValue: supplier.location.longitude)
        self.supplier = supplier
        self.viewModel = viewModel
    }

    var body: some View {
        VStack {
            TextField("Nama Supplier", text: $name)
                .padding()
                .textFieldStyle(RoundedBorderTextFieldStyle())

            TextField("Alamat", text: $address)
                .padding()
                .textFieldStyle(RoundedBorderTextFieldStyle())

            TextField("Kontak", text: $contact)
                .padding()
                .textFieldStyle(RoundedBorderTextFieldStyle())

            HStack {
                TextField("Latitude", value: $latitude, format: .number)
                    .keyboardType(.decimalPad)
                    .padding()
                    .textFieldStyle(RoundedBorderTextFieldStyle())

                TextField("Longitude", value: $longitude, format: .number)
                    .keyboardType(.decimalPad)
                    .padding()
                    .textFieldStyle(RoundedBorderTextFieldStyle())
            }

            Button("Simpan") {
                saveChanges()
            }
            .padding()
            .background(RoundedRectangle(cornerRadius: 8).fill(Color.blue))
            .foregroundColor(.white)
        }
        .padding()
        .navigationTitle("Edit Supplier")
    }

    func saveChanges() {
        let supplierId = supplier.id

        let updatedSupplier = Supplier(
            id: supplierId,
            name: name,
            address: address,
            contact: contact,
            location: Supplier.Location(latitude: latitude, longitude: longitude)
        )

        // Update supplier di Firestore
        viewModel.updateSupplier(updatedSupplier) { success in
            if success {
                print("Supplier updated successfully!")

                // Update item dengan supplierId yang baru
                viewModel.updateItemsForSupplier(supplierId: supplierId, updatedSupplier: updatedSupplier)
            } else {
                print("Failed to update supplier.")
            }
        }
    }
}



