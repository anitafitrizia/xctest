//
//  ContentView.swift
//  XCAnita
//
//  Created by anitafitrizia on 1/18/25.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @State private var isLoggedIn: Bool = false // Tracks whether the user is logged in
        
    var body: some View {
        if isLoggedIn {
            HomePageView(isLoggedIn: $isLoggedIn) // Show HomePageView after successful login
        } else {
            LoginView(isLoggedIn: $isLoggedIn) // Pass login state to LoginView
        }
    }
}

struct LoginView: View {
    @State private var username: String = "" //"email": "eve.holt@reqres.in"
    @State private var password: String = "" //"password": "cityslicka"
    @State private var alertMessage: String = ""
    @State private var showAlert: Bool = false
    @Binding var isLoggedIn: Bool // Binding to update login state
    
    var body: some View {
        VStack(spacing: 20) {
            TextField("Username", text: $username)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.horizontal, 40)
                .accessibilityIdentifier("usernameInput")

            SecureField("Password", text: $password)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.horizontal, 40)
                .accessibilityIdentifier("passwordInput")

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
                    .accessibilityIdentifier("loginButton")
            }
        }
        .alert(isPresented: $showAlert) {
            Alert(title: Text("Message"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
        }
    }

    private func handleLogin() {
        if username.isEmpty || password.isEmpty {
            alertMessage = "Please enter both username and password."
            showAlert = true
        } else {
            // Prepare the request data
            let loginDetails = [
                "email": username,
                "password": password
            ]
            
            // Convert dictionary to JSON
            guard let jsonData = try? JSONSerialization.data(withJSONObject: loginDetails) else {
                alertMessage = "Error creating JSON data."
                showAlert = true
                return
            }

            // Create the request
            guard let url = URL(string: "https://reqres.in/api/login") else {
                alertMessage = "Invalid URL."
                showAlert = true
                return
            }

            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.httpBody = jsonData
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")

            // Send the request
            URLSession.shared.dataTask(with: request) { data, response, error in
                if let error = error {
                    DispatchQueue.main.async {
                        alertMessage = "Request failed: \(error.localizedDescription)"
                        showAlert = true
                    }
                    return
                }

                guard let data = data else {
                    DispatchQueue.main.async {
                        alertMessage = "No data received."
                        showAlert = true
                    }
                    return
                }

                // Parse the response (example: check if login is successful)
                if let responseString = String(data: data, encoding: .utf8) {
                    DispatchQueue.main.async {
                        if responseString.contains("token") {
                            alertMessage = "Login successful!"
                            isLoggedIn = true // Update state to show HomePageView
                        } else {
                            alertMessage = "Invalid username or password."
                        }
                        showAlert = true
                    }
                }
            }.resume()
        }
    }
}

struct HomePageView: View {
    @Binding var isLoggedIn: Bool // Binding to update login state
    @State private var singleUser: User? = nil // Holds data for a single user
    @State private var users: [User] = [] // Holds data for the list of users
    @State private var isLoadingSingleUser: Bool = false
    @State private var isLoadingUsers: Bool = false
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    Text("Welcome to the Home Page!")
                        .font(.largeTitle)
                        .padding()
                        .accessibilityIdentifier("welcomePage")
                    
                    // Fetch Single User Button
                    Button(action: fetchSingleUser) {
                        Text(isLoadingSingleUser ? "Fetching User..." : "Get Single User")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.green)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                            .padding(.horizontal, 40)
                            .accessibilityIdentifier("getSingleUser")
                    }
                    
                    // Display Single User
                    if let user = singleUser {
                        VStack(alignment: .leading) {
                            Text("Single User")
                                .font(.headline)
                                .padding(.top)
                            HStack {
                                AsyncImage(url: URL(string: user.avatar)) { image in
                                    image.resizable()
                                } placeholder: {
                                    ProgressView()
                                }
                                .frame(width: 50, height: 50)
                                .clipShape(Circle())
                                
                                VStack(alignment: .leading) {
                                    Text("\(user.firstName) \(user.lastName)")
                                        .font(.title2)
                                        .accessibilityIdentifier("userFullName")
                                    Text(user.email)
                                        .font(.subheadline)
                                        .foregroundColor(.gray)
                                        .accessibilityIdentifier("userEmail")
                                }
                            }
                        }
                        .padding()
                        
                        // Clear Single User Button
                        Button(action: {
                            singleUser = nil
                        }) {
                            Text("Clear Single User")
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.red)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                                .padding(.horizontal, 40)
                                .accessibilityIdentifier("clearSingleUser")
                        }
                    }
                    
                    // Fetch Users List Button
                    Button(action: fetchUsersList) {
                        Text(isLoadingUsers ? "Fetching Users..." : "List Users")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                            .padding(.horizontal, 40)
                            .accessibilityIdentifier("getListUsers")
                    }
                    
                    // Display List of Users
                    if !users.isEmpty {
                        VStack(alignment: .leading) {
                            Text("Users List")
                                .font(.headline)
                                .padding(.top)
                            ForEach(users, id: \.id) { user in
                                HStack {
                                    AsyncImage(url: URL(string: user.avatar)) { image in
                                        image.resizable()
                                    } placeholder: {
                                        ProgressView()
                                    }
                                    .frame(width: 50, height: 50)
                                    .clipShape(Circle())
                                    
                                    VStack(alignment: .leading) {
                                        Text("\(user.firstName) \(user.lastName)")
                                            .font(.title3)
                                        Text(user.email)
                                            .font(.subheadline)
                                            .foregroundColor(.gray)
                                    }
                                }
                                .padding(.vertical, 5)
                            }
                        }
                        .padding()
                        
                        // Clear User List Button
                        Button(action: {
                            users.removeAll()
                        }) {
                            Text("Clear Users List")
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.red)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                                .padding(.horizontal, 40)
                                .accessibilityIdentifier("clearListUsers")
                        }
                    }
                    
                    // Logout Button
                    Button(action: {
                        isLoggedIn = false // Set to false to navigate back to LoginView
                    }) {
                        Text("Logout")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.red)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                            .padding(.horizontal, 40)
                    }
                    
                    Divider()
                        .padding(.vertical)
                }
            }
            .navigationTitle("Home")
        }
    }
    
    // Fetch Single User Function
    private func fetchSingleUser() {
        isLoadingSingleUser = true
        guard let url = URL(string: "https://reqres.in/api/users/2") else { return }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            DispatchQueue.main.async {
                isLoadingSingleUser = false
                if let data = data {
                    do {
                        let decodedResponse = try JSONDecoder().decode(SingleUserResponse.self, from: data)
                        singleUser = decodedResponse.data
                    } catch {
                        print("Error decoding single user: \(error)")
                    }
                }
            }
        }.resume()
    }
    
// Fetch Users List Function
    private func fetchUsersList() {
        isLoadingUsers = true
        guard let url = URL(string: "https://reqres.in/api/users?page=1") else { return }

        URLSession.shared.dataTask(with: url) { data, response, error in
            DispatchQueue.main.async {
                isLoadingUsers = false
                if let data = data {
                    do {
                        let decodedResponse = try JSONDecoder().decode(UsersListResponse.self, from: data)
                        users = decodedResponse.data
                    } catch {
                        print("Error decoding users list: \(error)")
                    }
                }
            }
        }.resume()
    }
}

// Models for Decoding API Responses
struct SingleUserResponse: Codable {
    let data: User
}

struct UsersListResponse: Codable {
    let data: [User]
}

struct User: Codable, Identifiable {
    let id: Int
    let email: String
    let firstName: String
    let lastName: String
    let avatar: String

    enum CodingKeys: String, CodingKey {
        case id, email, avatar
        case firstName = "first_name"
        case lastName = "last_name"
    }
}
