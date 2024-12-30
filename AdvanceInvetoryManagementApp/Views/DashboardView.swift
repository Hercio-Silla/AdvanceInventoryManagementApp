//
//  DashboardView.swift
//  AdvanceInvetoryManagementApp
//
//  Created by Hercio Venceslau Silla on 23/12/24.
//

import SwiftUI
import FirebaseFirestore
import FirebaseAuth

struct DashboardView: View {
    @ObservedObject var viewModel: InventoryViewModel
    @Binding var isLoggedIn: Bool
    @State private var totalSuppliers = 0
    private let db = Firestore.firestore()

    var body: some View {
        NavigationStack {
            VStack {
                Text("Dashboard")
                    .font(.largeTitle)
                    .padding()

                VStack(spacing: 20) {
                    // Total Items Section
                    HStack {
                        Text("Total Items: \(viewModel.items.count)")
                        Spacer()
                        NavigationLink(destination: ItemListView(viewModel: viewModel)) {
                            Text("View Items")
                        }
                    }

                    // Total Suppliers Section
                    HStack {
                        Text("Total Suppliers: \(totalSuppliers)")
                        Spacer()
                        NavigationLink(destination: SupplierListView(viewModel: viewModel)) {
                            Text("View Suppliers")
                        }
                    }
                }
                .onAppear {
                    fetchData()
                    if viewModel.items.isEmpty {
                        fetchItems()
                    }
                }

                Spacer()

                // Logout Button
                Button(action: logout) {
                    Text("Logout")
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.red)
                        .cornerRadius(8)
                }
                .padding()
            }
            .padding()
        }
    }

    private func fetchData() {
        db.collection("suppliers").getDocuments { snapshot, error in
            if let error = error {
                print("Error fetching suppliers: \(error)")
            } else {
                totalSuppliers = snapshot?.count ?? 0
            }
        }
    }

    private func fetchItems() {
        db.collection("items").getDocuments { snapshot, error in
            if let error = error {
                print("Error fetching items: \(error)")
            } else {
                viewModel.items = snapshot?.documents.compactMap { document in
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

    private func logout() {
        do {
            try Auth.auth().signOut()
            isLoggedIn = false
        } catch let error {
            print("Error during logout: \(error)")
        }
    }
}



// Preview untuk DashboardView
struct DashboardView_Previews: PreviewProvider {
    static var previews: some View {
        let mockViewModel = InventoryViewModel()
        
        // Menambahkan data mock untuk preview, termasuk supplierId
        mockViewModel.items = [
            Item(id: "1", name: "Item 1", description: "Description 1", price: 100.0, category: "Category 1", stock: 10, photoPath: "", supplierId: "supplier_1"),
            Item(id: "2", name: "Item 2", description: "Description 2", price: 150.0, category: "Category 2", stock: 20, photoPath: "", supplierId: "supplier_2")
        ]
        mockViewModel.histories = [
            History(id: "1", itemId: "1", type: "purchase", quantity: 5, date: Date())
        ]
        
        // Simulasi State untuk isLoggedIn
        @State var isLoggedIn = true
        
        return DashboardView(viewModel: mockViewModel, isLoggedIn: $isLoggedIn)
    }
}




