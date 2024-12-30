//
//  InventoryViewModel.swift
//  AdvanceInvetoryManagementApp
//
//  Created by Hercio Venceslau Silla on 23/12/24.
//

import Foundation
import SwiftUI
import FirebaseFirestore

class InventoryViewModel: ObservableObject {
    @Published var items: [Item] = []
    @Published var suppliers: [Supplier] = []
    @Published var histories: [History] = []
    private let db = Firestore.firestore()
    private var listener: ListenerRegistration?

    init() {
        loadItemsFromFirestore()
        loadHistoriesFromFirestore()
    }

    deinit {
        listener?.remove()
    }

    // Fungsi untuk memuat data items dari Firestore
    func loadItemsFromFirestore() {
        listener = db.collection("items").addSnapshotListener { snapshot, error in
            if let error = error {
                print("Error fetching items: \(error)")
            } else {
                self.items = snapshot?.documents.compactMap { document in
                    let data = document.data()
                    let id = document.documentID
                    let supplierId = data["supplierId"] as? String ?? ""
                    
                    // Debug query supplierId
                    print("Processing document ID: \(id), SupplierId: \(supplierId), data: \(data)")

                    // Validasi data dan mapping ke model Item
                    let name = data["name"] as? String ?? "Unknown Item"
                    let description = data["description"] as? String ?? "No description"
                    let price = data["price"] as? Double ?? 0.0
                    let category = data["category"] as? String ?? "Uncategorized"
                    let stock = data["stock"] as? Int ?? 0
                    let photoPath = data["photoPath"] as? String ?? ""
                    
                    // Skipping invalid items
                    if name.isEmpty || category.isEmpty {
                        print("Skipping invalid item document: \(id)")
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

    // Fungsi untuk memuat data suppliers
    func loadSuppliersFromFirestore() {
        db.collection("suppliers").addSnapshotListener { snapshot, error in
            if let error = error {
                print("Error fetching suppliers: \(error)")
            } else {
                self.suppliers = snapshot?.documents.compactMap { document in
                    let data = document.data()
                    let id = document.documentID

                    let name = data["name"] as? String ?? "Unknown Supplier"
                    let address = data["address"] as? String ?? "No address"
                    let contact = data["contact"] as? String ?? "No contact"
                    let locationData = data["location"] as? [String: Double] ?? [:]
                    let latitude = locationData["latitude"] ?? 0.0
                    let longitude = locationData["longitude"] ?? 0.0

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

    // Fungsi untuk memuat data histories
    func loadHistoriesFromFirestore() {
        db.collection("histories").addSnapshotListener { snapshot, error in
            if let error = error {
                print("Error fetching histories: \(error)")
            } else {
                self.histories = snapshot?.documents.compactMap { document in
                    let data = document.data()
                    let id = document.documentID

                    let itemId = data["itemId"] as? String ?? ""
                    let type = data["type"] as? String ?? "Unknown"
                    let quantity = data["quantity"] as? Int ?? 0
                    let timestamp = data["date"] as? Timestamp

                    guard let date = timestamp?.dateValue() else {
                        print("Skipping invalid history document: \(id)")
                        return nil
                    }

                    return History(
                        id: id,
                        itemId: itemId,
                        type: type,
                        quantity: quantity,
                        date: date
                    )
                } ?? []
            }
        }
    }

    // Fungsi untuk memperbarui stok item di Firestore
    func updateStock(for item: Item, amount: Int, type: String, date: Date) {
        if let index = items.firstIndex(where: { $0.id == item.id }) {
            // Update stock locally
            items[index].stock += amount
            
            // Update Firestore
            db.collection("items").document(item.id).updateData([
                "stock": items[index].stock
            ]) { error in
                if let error = error {
                    print("Error updating stock: \(error)")
                }
            }
        }
    }


    // Fungsi untuk menambahkan riwayat transaksi (histories)
    func addHistory(itemId: String, type: String, quantity: Int, date: Date) {
        let newHistory: [String: Any] = [
            "itemId": itemId,
            "type": type,
            "quantity": quantity,
            "date": Timestamp(date: date)
        ]
        
        db.collection("histories").addDocument(data: newHistory) { error in
            if let error = error {
                print("Error adding history: \(error)")
            }
        }
    }

    // Fungsi untuk menyimpan item baru ke Firestore
 func addItem(name: String, description: String, price: Double, category: String, stock: Int, photo: String, supplierId: String) {
    let newItem: [String: Any] = [
        "name": name,
        "description": description,
        "price": price,
        "category": category,
        "stock": stock,
        "photoPath": photo,
        "supplierId": supplierId
    ]
    
    db.collection("items").addDocument(data: newItem) { error in
        if let error = error {
            print("Error adding item to Firestore: \(error)")
        }
    }
}


    // Fungsi untuk menghapus item dari Firestore
    func deleteItem(at offsets: IndexSet) {
        for index in offsets {
            let item = items[index]
            db.collection("items").document(item.id).delete { error in
                if let error = error {
                    print("Error deleting item: \(error)")
                } else {
                    DispatchQueue.main.async {
                        self.items.remove(atOffsets: offsets)
                    }
                }
            }
        }
    }

    
    func deleteSupplier(supplier: Supplier) {
        let supplierId = supplier.id

        db.collection("suppliers").document(supplierId).delete { error in
            if let error = error {
                print("Error deleting supplier: \(error)")
            } else {
                DispatchQueue.main.async {
                    self.items.removeAll { $0.id == supplierId }
                }
            }
        }
    }
    
    
    // Fungsi untuk memperbarui data item di Firestore
    func updateItem(_ updatedItem: Item) {
        db.collection("items").document(updatedItem.id).updateData([
            "name": updatedItem.name,
            "description": updatedItem.description,
            "price": updatedItem.price,
            "category": updatedItem.category,
            "stock": updatedItem.stock,
            "photoPath": updatedItem.photoPath,
            "supplierId": updatedItem.supplierId
        ]) { error in
            if let error = error {
                print("Error updating item in Firestore: \(error)")
            } else {
                // Directly fetch the updated item rather than relying on snapshot listener
                self.db.collection("items").document(updatedItem.id).getDocument { document, error in
                    if let error = error {
                        print("Error fetching updated item: \(error)")
                    } else if let document = document, document.exists {
                        // Use the updated item data for local sync
                        let data = document.data() ?? [:]
                        let updatedItem = Item(
                            id: document.documentID,
                            name: data["name"] as? String ?? "",
                            description: data["description"] as? String ?? "",
                            price: data["price"] as? Double ?? 0.0,
                            category: data["category"] as? String ?? "",
                            stock: data["stock"] as? Int ?? 0,
                            photoPath: data["photoPath"] as? String ?? "",
                            supplierId: data["supplierId"] as? String ?? ""
                        )
                        if let index = self.items.firstIndex(where: { $0.id == updatedItem.id }) {
                            self.items[index] = updatedItem
                        }
                    }
                }
            }
        }
    }

    
    func updateSupplier(_ updatedSupplier: Supplier, completion: @escaping (Bool) -> Void) {
        db.collection("suppliers").document(updatedSupplier.id).updateData([
            "name": updatedSupplier.name,
            "address": updatedSupplier.address,
            "contact": updatedSupplier.contact,
            "location": [
                "latitude": updatedSupplier.location.latitude,
                "longitude": updatedSupplier.location.longitude
            ]
        ]) { error in
            if let error = error {
                print("Error updating supplier: \(error)")
                completion(false)
            } else {
                print("Supplier \(updatedSupplier.name) updated successfully!")

                // Panggil updateItemsForSupplier untuk memperbarui data di koleksi items
                self.updateItemsForSupplier(supplierId: updatedSupplier.id, updatedSupplier: updatedSupplier)
                completion(true)
            }
        }
    }


    func updateItemsForSupplier(supplierId: String, updatedSupplier: Supplier) {
        print("Querying items with supplierId: \(supplierId)")

        db.collection("items").whereField("supplierId", isEqualTo: supplierId).getDocuments { snapshot, error in
            if let error = error {
                print("Error fetching items for supplierId \(supplierId): \(error)")
                return
            }

            guard let documents = snapshot?.documents else {
                print("No items found for supplierId: \(supplierId)")
                return
            }

            print("Found \(documents.count) items for supplierId: \(supplierId). Updating...")

            let group = DispatchGroup()

            for document in documents {
                let itemId = document.documentID
                group.enter()

                // Log data sebelum diupdate
                print("Updating item \(itemId), current supplierId: \(document.data()["supplierId"] ?? "Unknown")")

                self.db.collection("items").document(itemId).updateData([
                    "supplierId": updatedSupplier.id,  // Update supplierId
                    "supplierName": updatedSupplier.name // Update supplier name
                ]) { error in
                    if let error = error {
                        print("Error updating item \(itemId): \(error)")
                    } else {
                        print("Item \(itemId) updated successfully!")
                    }
                    group.leave()
                }
            }

            group.notify(queue: .main) {
                print("All items updated for supplier \(updatedSupplier.name). Reloading items...")
                // Reload items after update
                self.loadItemsFromFirestore()
            }
        }
    }

    
    func getSupplier(for item: Item, completion: @escaping (Supplier?) -> Void) {
        db.collection("suppliers").document(item.supplierId).getDocument { document, error in
            if let error = error {
                print("Error fetching supplier: \(error)")
                completion(nil)
            } else if let document = document, document.exists {
                let data = document.data() ?? [:]
                guard let name = data["name"] as? String,
                      let address = data["address"] as? String,
                      let contact = data["contact"] as? String,
                      let locationData = data["location"] as? [String: Double],
                      let latitude = locationData["latitude"],
                      let longitude = locationData["longitude"] else {
                    completion(nil)
                    return
                }
                let supplier = Supplier(
                    id: document.documentID,
                    name: name,
                    address: address,
                    contact: contact,
                    location: Supplier.Location(latitude: latitude, longitude: longitude)
                )
                completion(supplier)
            } else {
                completion(nil)
            }
        }
    }
    
    func queryItemsBySupplier(supplierId: String) {
        db.collection("items").whereField("supplierId", isEqualTo: supplierId).getDocuments { snapshot, error in
            if let error = error {
                print("Error fetching items for supplierId \(supplierId): \(error)")
            } else {
                guard let documents = snapshot?.documents else {
                    print("No items found for supplierId: \(supplierId)")
                    return
                }
                print("Found \(documents.count) items for supplierId: \(supplierId).")
                documents.forEach { document in
                    let data = document.data()
                    print("Item ID: \(document.documentID), Data: \(data)")
                }
            }
        }
    }

}



