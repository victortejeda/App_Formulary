//
//  FormListView.swift
//  App_FormularioNativa
//
//  Created by Victor Tejeda on 20/12/24.
//

import SwiftUI

struct AlertItem: Identifiable {
    let id = UUID()
    let message: String
}


struct FormListView: View {
    @ObservedObject var viewModel: FormViewModel
    @State private var showingCreateForm = false
    
    var body: some View {
        NavigationView {
            List {
                ForEach(viewModel.forms) { form in
                    NavigationLink(destination: FormDetailView(viewModel: viewModel, form: form)) {
                        FormListItem(form: form)
                    }
                }
                .onDelete(perform: deleteForms)
            }
            .listStyle(InsetGroupedListStyle())
            .navigationTitle("My Forms")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingCreateForm = true }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingCreateForm) {
                CreateFormView(viewModel: viewModel)
            }
        }
        .onAppear {
            viewModel.fetchForms()
        }
        .overlay(Group {
            if viewModel.isLoading {
                ProgressView()
            }
        })
        .alert(item: Binding<AlertItem?>(
            get: { viewModel.errorMessage.map { AlertItem(message: $0) } },
            set: { _ in viewModel.errorMessage = nil }
        )) { alertItem in
            Alert(title: Text("Error"), message: Text(alertItem.message))
        }
    }
    
    private func deleteForms(at offsets: IndexSet) {
        offsets.forEach { index in
            viewModel.deleteForm(viewModel.forms[index])
        }
    }
}

struct FormListItem: View {
    let form: FormModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(form.title)
                .font(.headline)
            Text(form.description)
                .font(.subheadline)
                .foregroundColor(.secondary)
            HStack {
                Text("Responses: \(form.responses)")
                    .font(.caption)
                    .foregroundColor(.blue)
                Spacer()
                Text(formattedDate(form.updatedAt))
                    .font(.caption)
                    .foregroundColor(.gray)
            }
        }
        .padding(.vertical, 8)
    }
    
    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

struct CreateFormView: View {
    @ObservedObject var viewModel: FormViewModel
    @State private var title = ""
    @State private var description = ""
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Form Details")) {
                    TextField("Title", text: $title)
                    TextField("Description", text: $description)
                }
                
                Section {
                    Button("Create Form") {
                        viewModel.createForm(title: title, description: description)
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
            .navigationTitle("Create New Form")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
        }
    }
}


