//
//  ContentView.swift
//  XCAnita
//
//  Created by anitafitrizia on 1/18/25.
//

import SwiftUI
import SwiftData

struct LoginView: View {
    @State private var username: String = ""
    @State private var password: String = ""
    @State private var alertMessage: String = ""
    @State private var showAlert: Bool = false

    var body: some View {
        VStack(spacing: 20) {
            TextField("Username", text: $username)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.horizontal, 40)

            SecureField("Password", text: $password)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.horizontal, 40)

            Button(action: {
                handleLogin()
            }) {
                Text("Login")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                    .padding(.horizontal, 40)
            }
        }
        .alert(isPresented: $showAlert) {
            Alert(title: Text("Message"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
        }
    }

    private func handleLogin() {
        if username.isEmpty || password.isEmpty {
            alertMessage = "Please enter both username and password."
        } else if username == "test" && password == "password" {
            alertMessage = "Login successful!"
        } else {
            alertMessage = "Invalid username or password."
        }
        showAlert = true
    }
}
