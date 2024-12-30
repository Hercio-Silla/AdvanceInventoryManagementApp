//
//  SupplierDetailView.swift
//  AdvanceInvetoryManagementApp
//
//  Created by Hercio Venceslau Silla on 23/12/24.
//

import SwiftUI
import MapKit

struct SupplierDetailView: View {
    let supplier: Supplier

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Detail Supplier")
                .font(.largeTitle)
                .bold()

            Text("Nama: \(supplier.name)")
                .font(.headline)

            Text("Alamat: \(supplier.address)")
                .font(.body)

            Text("Kontak: \(supplier.contact)")
                .font(.body)

            Text("Koordinat:")
                .font(.body)
            Text("Lat: \(supplier.location.latitude), Lon: \(supplier.location.longitude)")
                .font(.caption)
                .foregroundColor(.gray)

            Button(action: openGoogleMaps) {
                Text("Lihat di Google Maps")
                    .foregroundColor(.blue)
                    .padding()
                    .background(RoundedRectangle(cornerRadius: 8).stroke(Color.blue, lineWidth: 2))
            }

            Spacer()

            MapView(coordinate: CLLocationCoordinate2D(
                latitude: supplier.location.latitude,
                longitude: supplier.location.longitude
            ))
                .frame(height: 300)
                .cornerRadius(12)
        }
        .padding()
//        .navigationTitle("Detail Supplier")
    }

    func openGoogleMaps() {
        let url = URL(string: "https://www.google.com/maps?q=\(supplier.location.latitude),\(supplier.location.longitude)")!
        if UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url)
        }
    }
}

struct MapView: UIViewRepresentable {
    let coordinate: CLLocationCoordinate2D

    func makeUIView(context: Context) -> MKMapView {
        return MKMapView()
    }

    func updateUIView(_ uiView: MKMapView, context: Context) {
        let region = MKCoordinateRegion(
            center: coordinate,
            span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
        )
        uiView.setRegion(region, animated: true)
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate
        uiView.addAnnotation(annotation)
    }
}


struct SupplierDetailView_Previews: PreviewProvider {
    static var previews: some View {
        // Contoh supplier dengan lokasi
        let exampleSupplier = Supplier(
            id: "1",
            name: "Supplier A",
            address: "Jl. Example No. 10",
            contact: "081234567890",
            location: Supplier.Location(latitude: -6.1751, longitude: 106.8650)
        )
        SupplierDetailView(supplier: exampleSupplier)
    }
}
