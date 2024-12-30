//
//  ContentView.swift
//  AdvanceInvetoryManagementApp
//
//  Created by Hercio Venceslau Silla on 22/12/24.
//

import SwiftUI

struct ContentView: View {
    @StateObject var viewModel = InventoryViewModel()
    @State private var isLoggedIn = false

    var body: some View {
        Group {
            if isLoggedIn {
                DashboardView(viewModel: viewModel, isLoggedIn: $isLoggedIn)
            } else {
                LoginView(isLoggedIn: $isLoggedIn)
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}



