//
//  LoginView.swift
//  AdvanceInvetoryManagementApp
//
//  Created by Hercio Venceslau Silla on 23/12/24.
//

import SwiftUI
import FirebaseAuth

// Common styles that can be shared between views
struct AuthButtonStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding()
            .frame(maxWidth: .infinity)
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(10)
            .padding(.horizontal)
    }
}

struct AuthTextFieldStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(8)
            .padding(.horizontal)
    }
}

struct LoginView: View {
    @Binding var isLoggedIn: Bool  // Binding to isLoggedIn from ContentView
    @State private var email = ""
    @State private var password = ""
    @State private var errorMessage = ""
    @State private var isAuthenticated = false
    @State private var isLoading = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // Header
                Image(systemName: "person.circle.fill")
                    .resizable()
                    .frame(width: 100, height: 100)
                    .foregroundColor(.blue)
                    .padding(.top, 50)
                
                Text("Selamat Datang!")
                    .font(.title)
                    .fontWeight(.bold)
                
                // Login Form
                VStack(spacing: 15) {
                    TextField("Email", text: $email)
                        .modifier(AuthTextFieldStyle())
                        .textInputAutocapitalization(.never)
                        .keyboardType(.emailAddress)
                    
                    SecureField("Password", text: $password)
                        .modifier(AuthTextFieldStyle())
                }
                .padding(.top, 20)
                
                // Error Message
                if !errorMessage.isEmpty {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .font(.footnote)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
                
                // Login Button
                Button(action: loginUser) {
                    if isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    } else {
                        Text("Masuk")
                            .fontWeight(.semibold)
                    }
                }
                .modifier(AuthButtonStyle())
                .disabled(isLoading)
                
                // Register Navigation Link
                NavigationLink(destination: RegisterView(isLoggedIn: $isLoggedIn)) {
                    Text("Belum punya akun? Daftar")
                        .foregroundColor(.blue)
                }
                
                Spacer()
            }
            .padding()
            .navigationBarHidden(true)
            .fullScreenCover(isPresented: $isAuthenticated) {
                DashboardView(viewModel: InventoryViewModel(), isLoggedIn: $isLoggedIn)
            }

        }
    }
    
    private func loginUser() {
        // Input validation
        guard !email.isEmpty, !password.isEmpty else {
            errorMessage = "Please fill in all fields"
            return
        }
        
        isLoading = true
        Auth.auth().signIn(withEmail: email, password: password) { result, error in
            isLoading = false
            
            if let error = error {
                errorMessage = error.localizedDescription
            } else {
                isAuthenticated = true
                isLoggedIn = true  // Update isLoggedIn when authentication succeeds
                email = ""
                password = ""
                errorMessage = ""
            }
        }
    }
}

// Preview Provider
struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView(isLoggedIn: .constant(false))  // Passing a default value for preview
    }
}




