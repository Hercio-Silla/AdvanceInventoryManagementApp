//
//  AddItemView.swift
//  AdvanceInvetoryManagementApp
//
//  Created by Hercio Venceslau Silla on 23/12/24.
//

import Foundation
import SwiftUI
import UIKit
import AVFoundation
import FirebaseStorage
import FirebaseFirestore

struct AddItemView: View {
    @Environment(\.dismiss) var dismiss

    @State private var name = ""
    @State private var description = ""
    @State private var price = ""
    @State private var category = ""
    @State private var stock = ""
    @State private var selectedImage: UIImage? = nil
    @State private var showImagePicker = false
    @State private var sourceType: UIImagePickerController.SourceType = .photoLibrary
    @State private var isCameraActive = false
    @State private var selectedSupplier: String = ""
    @State private var suppliers: [(id: String, name: String)] = []
    @State private var isLoading = false

    var body: some View {
        Form {
            Section(header: Text("Informasi Barang")) {
                TextField("Nama Barang", text: $name)
                TextField("Deskripsi", text: $description)
                TextField("Harga", text: $price)
                    .keyboardType(.decimalPad)
                TextField("Kategori", text: $category)
                TextField("Stok", text: $stock)
                    .keyboardType(.numberPad)

                Picker("Pilih Supplier", selection: $selectedSupplier) {
                    ForEach(suppliers, id: \.id) { supplier in
                        Text(supplier.name) // Menampilkan nama supplier
                    }
                }
                .pickerStyle(MenuPickerStyle())
            }

            Section(header: Text("Foto Barang")) {
                if let image = selectedImage {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                        .frame(height: 200)
                } else {
                    Text("Belum ada foto")
                        .foregroundColor(.gray)
                }

                HStack {
                    Button("Ambil Foto") {
                        sourceType = .camera
                        checkCameraAuthorizationStatus()
                    }
                    Spacer()
                    Button("Pilih dari Galeri") {
                        sourceType = .photoLibrary
                        showImagePicker = true
                    }
                }
            }
            .sheet(isPresented: $showImagePicker) {
                ImagePicker(selectedImage: $selectedImage, sourceType: sourceType)
            }

            Button("Simpan") {
                saveItem()
            }
            .disabled(isLoading || selectedSupplier.isEmpty) // Cegah klik saat loading atau supplier kosong
        }
        .navigationTitle("Tambah Barang")
        .onAppear {
            fetchSuppliers()
        }
    }

    func fetchSuppliers() {
        let db = Firestore.firestore()
        db.collection("suppliers").getDocuments { snapshot, error in
            if let error = error {
                print("Error fetching suppliers: \(error)")
                return
            }

            if let snapshot = snapshot {
                // Menyimpan supplier sebagai tuple (id, name)
                self.suppliers = snapshot.documents.compactMap { document in
                    guard let name = document.data()["name"] as? String else { return nil }
                    return (id: document.documentID, name: name)
                }
                // Set default selected supplier
                if let firstSupplier = self.suppliers.first {
                    self.selectedSupplier = firstSupplier.id
                }
            }
        }
    }

    func saveItem() {
        guard !name.isEmpty,
              !description.isEmpty,
              let price = Double(price),
              let stock = Int(stock),
              !selectedSupplier.isEmpty,
              let image = selectedImage else {
            print("Input tidak valid")
            return
        }

        isLoading = true
        print("Mulai menyimpan item...")

        let imageName = UUID().uuidString
        let storageRef = Storage.storage().reference().child("itemImages/\(imageName).jpg")

        if let imageData = image.jpegData(compressionQuality: 0.8) {
            storageRef.putData(imageData, metadata: nil) { metadata, error in
                if let error = error {
                    print("Error uploading image: \(error)")
                    isLoading = false
                    return
                }

                storageRef.downloadURL { url, error in
                    if let error = error {
                        print("Error getting download URL: \(error)")
                        isLoading = false
                        return
                    }

                    guard let imageUrl = url?.absoluteString else {
                        print("Gagal mendapatkan URL gambar")
                        isLoading = false
                        return
                    }

                    let db = Firestore.firestore()
                    let itemData: [String: Any] = [
                        "name": name,
                        "description": description,
                        "price": price,
                        "category": category,
                        "stock": stock,
                        "photoPath": imageUrl,
                        "supplierId": selectedSupplier, // Gunakan ID supplier
                        "createdAt": Timestamp()
                    ]

                    db.collection("items").addDocument(data: itemData) { error in
                        isLoading = false
                        if let error = error {
                            print("Error saving item to Firestore: \(error)")
                        } else {
                            print("Item successfully saved!")
                            dismiss()
                        }
                    }
                }
            }
        }
    }


    func checkCameraAuthorizationStatus() {
        let status = AVCaptureDevice.authorizationStatus(for: .video)

        switch status {
        case .authorized:
            openCamera()
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { granted in
                DispatchQueue.main.async {
                    if granted {
                        self.openCamera()
                    } else {
                        print("Akses kamera ditolak")
                    }
                }
            }
        case .denied, .restricted:
            showSettingsAlert()
        @unknown default:
            print("Status tidak diketahui")
        }
    }

    func openCamera() {
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            sourceType = .camera
            showImagePicker = true
        } else {
            print("Kamera tidak tersedia pada perangkat ini")
        }
    }

    func showSettingsAlert() {
        let alert = UIAlertController(
            title: "Akses Kamera Diperlukan",
            message: "Harap izinkan aplikasi untuk mengakses kamera melalui Pengaturan.",
            preferredStyle: .alert
        )

        alert.addAction(UIAlertAction(title: "Batal", style: .cancel))
        alert.addAction(UIAlertAction(title: "Pengaturan", style: .default, handler: { _ in
            if let settingsURL = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(settingsURL)
            }
        }))

        if let rootViewController = UIApplication.shared.windows.first?.rootViewController {
            rootViewController.present(alert, animated: true)
        }
    }
}


struct AddItemView_Previews: PreviewProvider {
    static var previews: some View {
        AddItemView()
    }
}
