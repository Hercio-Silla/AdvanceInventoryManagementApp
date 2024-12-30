//
//  AddHistoryView.swift
//  AdvanceInvetoryManagementApp
//
//  Created by Hercio Venceslau Silla on 23/12/24.
//

import SwiftUI
import FirebaseFirestore

struct AddHistoryView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var viewModel: InventoryViewModel
    var item: Item
    @State private var type = "Masuk"
    @State private var quantity = ""
    @State private var date = Date()
    private let db = Firestore.firestore()
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Jenis Transaksi")) {
                    Picker("Pilih Jenis", selection: $type) {
                        Text("Masuk").tag("Masuk")
                        Text("Keluar").tag("Keluar")
                    }
                    .pickerStyle(SegmentedPickerStyle())
                }
                
                Section(header: Text("Jumlah")) {
                    TextField("Masukkan jumlah", text: $quantity)
                        .keyboardType(.numberPad)
                }
                
                Section(header: Text("Tanggal")) {
                    DatePicker("Pilih tanggal", selection: $date, displayedComponents: .date)
                }
                
                Button(action: saveHistory) {
                    Text("Simpan")
                        .bold()
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
                .disabled(quantity.isEmpty || Int(quantity) == nil)
            }
            .navigationTitle("Tambah Riwayat")
        }
    }
    
    func saveHistory() {
        guard let quantityInt = Int(quantity) else { return }
        let adjustedQuantity = type == "Masuk" ? quantityInt : -quantityInt

        // Update stok barang di Firestore dan lokal
        viewModel.updateStock(for: item, amount: adjustedQuantity, type: type, date: date)
        
        // Perbarui Firestore
        let historyData: [String: Any] = [
            "itemId": item.id, // id sekarang String
            "type": type,
            "quantity": abs(adjustedQuantity),
            "date": Timestamp(date: date)
        ]
        
        db.collection("histories").addDocument(data: historyData) { error in
            if let error = error {
                print("Error adding history: \(error)")
            } else {
                // Sinkronkan history ke lokal
//                viewModel.addHistory(itemId: item.id, type: type, quantity: abs(adjustedQuantity), date: date)
                dismiss()
            }
        }
    }
}


struct AddHistoryView_Previews: PreviewProvider {
    static var previews: some View {
        let mockItem = Item(id: "1" , name: "Item A", description: "Deskripsi barang A", price: 150.0, category: "Kategori A", stock: 10, photoPath: "https://example.com/image.jpg", supplierId: "supplier_1")
        let mockViewModel = InventoryViewModel()
        AddHistoryView(viewModel: mockViewModel, item: mockItem)
    }
}
