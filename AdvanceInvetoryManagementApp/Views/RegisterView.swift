//
//  RegisterView.swift
//  AdvanceInvetoryManagementApp
//
//  Created by Hercio Venceslau Silla on 23/12/24.
//

import SwiftUI
import FirebaseAuth

struct RegisterView: View {
    @Binding var isLoggedIn: Bool
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var errorMessage = ""
    @State private var isRegistered = false
    @State private var isLoading = false
    @State private var showSuccessAlert = false
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        VStack(spacing: 20) {
            // Header
            Image(systemName: "person.badge.plus")
                .resizable()
                .frame(width: 100, height: 100)
                .foregroundColor(.blue)
                .padding(.top, 50)
            
            Text("Membuat Akun")
                .font(.title)
                .fontWeight(.bold)
            
            // Registration Form
            VStack(spacing: 15) {
                TextField("Email", text: $email)
                    .modifier(AuthTextFieldStyle())
                    .textInputAutocapitalization(.never)
                    .keyboardType(.emailAddress)
                
                SecureField("Password", text: $password)
                    .modifier(AuthTextFieldStyle())
                
                SecureField("Konfirmasi Password", text: $confirmPassword)
                    .modifier(AuthTextFieldStyle())
            }
            .padding(.top, 20)
            
            // Error or Success Message
            if !errorMessage.isEmpty {
                Text(errorMessage)
                    .foregroundColor(isRegistered ? .green : .red)
                    .font(.footnote)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }
            
            // Register Button
            Button(action: registerUser) {
                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                } else {
                    Text("Daftar")
                        .fontWeight(.semibold)
                }
            }
            .modifier(AuthButtonStyle())
            .disabled(isLoading)
            
            // Back to Login
            if isRegistered {
                Button(action: { presentationMode.wrappedValue.dismiss() }) {
                    Text("Kembali ke halaman masuk")
                        .fontWeight(.semibold)
                        .foregroundColor(.blue)
                }
                .padding(.top)
            } else {
                Button(action: { presentationMode.wrappedValue.dismiss() }) {
                    Text("Sudah punya akun? Masuk")
                        .foregroundColor(.blue)
                }
                .padding(.top)
            }
            
            Spacer()
        }
        .padding()
        .navigationBarHidden(true)
        .alert(isPresented: $showSuccessAlert) {
            Alert(
                title: Text("Sukses"),
                message: Text("Akun anda sudah terdaftar. Silahkan Masuk."),
                dismissButton: .default(Text("OK"), action: {
                    presentationMode.wrappedValue.dismiss()
                })
            )
        }
    }
    
    private func registerUser() {
        guard !email.isEmpty && !password.isEmpty && !confirmPassword.isEmpty else {
            errorMessage = "Please fill in all fields"
            return
        }
        
        guard password == confirmPassword else {
            errorMessage = "Passwords do not match"
            return
        }
        
        guard password.count >= 6 else {
            errorMessage = "Password must be at least 6 characters"
            return
        }
        
        isLoading = true
        Auth.auth().createUser(withEmail: email, password: password) { result, error in
            isLoading = false
            
            if let error = error {
                errorMessage = error.localizedDescription
            } else {
                isRegistered = true
                email = ""
                password = ""
                confirmPassword = ""
                errorMessage = ""
                showSuccessAlert = true
            }
        }
    }
}

// Preview Provider
struct RegisterView_Previews: PreviewProvider {
    static var previews: some View {
        RegisterView(isLoggedIn: .constant(false))
    }
}




