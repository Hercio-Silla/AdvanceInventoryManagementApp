//
//  ItemDetailView.swift
//  AdvanceInvetoryManagementApp
//
//  Created by Hercio Venceslau Silla on 23/12/24.
//

import SwiftUI

struct ItemDetailView: View {
    let item: Item
    @ObservedObject var viewModel: InventoryViewModel
    @State private var supplier: Supplier?
    @State private var isShowingAddHistoryView = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Foto Barang
                if let url = URL(string: item.photoPath) {
                    AsyncImage(url: url) { image in
                        image
                            .resizable()
                            .scaledToFit()
                            .frame(maxHeight: 250)
                    } placeholder: {
                        ProgressView()
                    }
                } else {
                    Text("Gambar tidak tersedia")
                        .foregroundColor(.gray)
                }

                // Informasi Item
                Group {
                    Text("Nama Barang: \(item.name)")
                        .font(.headline)
                    Text("Deskripsi: \(item.description)")
                        .font(.body)
                    Text("Harga: \(item.price, specifier: "%.2f")")
                    Text("Stok: \(item.stock)")
                    Text("Kategori: \(item.category)")
//                    Text("Supplier ID: \(item.supplierId)")
//                        .font(.headline)

                }
                
                Divider()

                if let supplier = supplier {
                    Group {
                        Text("Supplier: \(supplier.name)")
                            .font(.headline)
                        NavigationLink(
                            destination: SupplierDetailView(supplier: supplier),
                            label: {
                                Text("Lihat Detail Supplier")
                                    .foregroundColor(.blue)
                                    .underline()
                            }
                        )
                    }
                } else {
                    Text("Memuat informasi supplier...")
                        .foregroundColor(.gray)
                }


                Divider()

                // Daftar Riwayat Barang
                Group {
                    Text("Riwayat Transaksi")
                        .font(.headline)

                    List {
                        ForEach(viewModel.histories.filter { $0.itemId == item.id }, id: \.id) { history in
                            HStack {
                                Text(history.type)
                                    .font(.headline)
                                    .foregroundColor(history.type == "Masuk" ? .green : .red)
                                Spacer()
                                Text("\(history.quantity)")
                                Text(history.date, style: .date)
                                    .foregroundColor(.gray)
                                    .font(.subheadline)
                            }
                        }
                    }
                    .frame(height: 200) // Batasi tinggi list agar scrollable
                }

                // Tombol untuk menambah riwayat
                Button(action: {
                    isShowingAddHistoryView = true
                }) {
                    Text("Tambah Riwayat")
                        .bold()
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
                .padding()
            }
            .padding()
        }
        .onAppear {
            viewModel.getSupplier(for: item) { fetchedSupplier in
                supplier = fetchedSupplier
            }
        }
        .sheet(isPresented: $isShowingAddHistoryView) {
            AddHistoryView(viewModel: viewModel, item: item)
        }
        .navigationTitle("Detail Barang")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct ItemDetailView_Previews: PreviewProvider {
    static var previews: some View {
        let mockItem = Item(
            id: "1",
            name: "Item A",
            description: "Deskripsi barang A",
            price: 150.0,
            category: "Kategori A",
            stock: 10,
            photoPath: "https://example.com/image.jpg",
            supplierId: "supplier1"
        )
        let mockViewModel = InventoryViewModel()
        ItemDetailView(item: mockItem, viewModel: mockViewModel)
    }
}



