//
//  Supplier.swift
//  AdvanceInvetoryManagementApp
//
//  Created by Hercio Venceslau Silla on 23/12/24.
//

import Foundation

struct Supplier: Identifiable {
    var id: String 
    var name: String
    var address: String
    var contact: String
    var location: Location

    struct Location {
        var latitude: Double
        var longitude: Double
    }
}

