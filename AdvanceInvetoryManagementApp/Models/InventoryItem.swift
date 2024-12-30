//
//  InventoryItem.swift
//  AdvanceInvetoryManagementApp
//
//  Created by Hercio Venceslau Silla on 23/12/24.
//

import Foundation

struct InventoryItem: Identifiable {
    var id: String?
    var name: String
    var description: String
    var quantity: Int
    var supplierId: String
}

