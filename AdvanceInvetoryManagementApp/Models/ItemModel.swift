//
//  ItemModel.swift
//  AdvanceInvetoryManagementApp
//
//  Created by Hercio Venceslau Silla on 23/12/24.
//

import Foundation

struct Item: Identifiable, Codable {
    var id: String
    var name: String
    var description: String
    var price: Double
    var category: String
    var stock: Int
    var photoPath: String
    var supplierId: String 
}

