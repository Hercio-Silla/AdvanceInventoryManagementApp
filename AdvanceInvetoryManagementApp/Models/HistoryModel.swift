//
//  HistoryModel.swift
//  AdvanceInvetoryManagementApp
//
//  Created by Hercio Venceslau Silla on 23/12/24.
//

import Foundation

struct History: Identifiable {
    var id: String 
    var itemId: String
    var type: String
    var quantity: Int
    var date: Date
}

