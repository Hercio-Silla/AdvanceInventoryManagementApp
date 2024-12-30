//
//  SupplierAddView.swift
//  AdvanceInvetoryManagementApp
//
//  Created by Hercio Venceslau Silla on 23/12/24.
//

import SwiftUI
import CoreLocation
import FirebaseFirestore

struct SupplierAddView: View {
    @Environment(\.dismiss) var dismiss

    @State private var name: String = ""
    @State private var address: String = ""
    @State private var contact: String = ""
    @State private var location: CLLocationCoordinate2D? = nil
    @State private var isFetchingLocation = false

    var body: some View {
        Form {
            Section(header: Text("Informasi Supplier")) {
                TextField("Nama Supplier", text: $name)
                TextField("Alamat", text: $address)
                TextField("Kontak", text: $contact)
                    .keyboardType(.phonePad)
            }

            Section(header: Text("Lokasi Supplier")) {
                if let location = location {
                    Text("Koordinat: \(location.latitude), \(location.longitude)")
                        .font(.subheadline)
                } else {
                    Text("Lokasi belum tersedia")
                        .foregroundColor(.gray)
                }

                if isFetchingLocation {
                    ProgressView("Mengambil lokasi...")
                } else {
                    Button("Ambil Lokasi") {
                        fetchLocation()
                    }
                }
            }

            Button("Simpan") {
                saveSupplier()
            }
            .disabled(name.isEmpty || address.isEmpty || contact.isEmpty || location == nil)
        }
        .navigationTitle("Tambah Supplier")
    }

    func fetchLocation() {
        isFetchingLocation = true
        LocationManager.shared.requestLocation { result in
            isFetchingLocation = false
            switch result {
            case .success(let coordinate):
                self.location = coordinate
            case .failure(let error):
                print("Gagal mengambil lokasi: \(error)")
            }
        }
    }

    func saveSupplier() {
        guard let location = location else { return }

        let supplierData: [String: Any] = [
            "name": name,
            "address": address,
            "contact": contact,
            "location": [
                "latitude": location.latitude,
                "longitude": location.longitude
            ],
            "createdAt": Timestamp()
        ]

        Firestore.firestore().collection("suppliers").addDocument(data: supplierData) { error in
            if let error = error {
                print("Error saving supplier: \(error)")
            } else {
                print("Supplier berhasil disimpan!")
                dismiss()
            }
        }
    }
}

struct SupplierAddView_Previews: PreviewProvider {
    static var previews: some View {
        SupplierAddView()
    }
}

