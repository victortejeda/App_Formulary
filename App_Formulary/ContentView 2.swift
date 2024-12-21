//
//  ContentView.swift
//  App_FormularioNativa
//
//  Created by Victor Tejeda on 20/12/24.
//

import SwiftUI// trate de agregarle depedencias de tercero pero me ah estado hiendo mal 

struct ContentView: View {
    @StateObject private var viewModel = FormViewModel()
    
    var body: some View {
        TabView {
            FormListView(viewModel: viewModel)
                .tabItem {
                    Label("Forms", systemImage: "list.bullet")
                }
            
            if let currentForm = viewModel.currentForm {
                FormDetailView(viewModel: viewModel, form: currentForm)
                    .tabItem {
                        Label("Edit Form", systemImage: "square.and.pencil")
                    }
            }
            
            AccountView()
                .tabItem {
                    Label("Account", systemImage: "person.circle")
                }
        }
    }
}

struct AccountView: View {
    @State private var username = ""
    @State private var email = ""
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Profile Information")) {
                    TextField("Username", text: $username)
                    TextField("Email", text: $email)
                }
                
                Section {
                    Button("Save Changes") {
                        // Implement save functionality
                    }
                }
                
                Section {
                    Button("Log Out") {
                        // Implement logout functionality
                    }
                    .foregroundColor(.red)
                }
            }
            .navigationTitle("Account")
        }
    }
}

