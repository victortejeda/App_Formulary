//
//  FormViewModel.swift
//  App_FormularioNativa
//
//  Created by Victor Tejeda on 20/12/24.
//

import Foundation
import Combine

class FormViewModel: ObservableObject {
    @Published var forms: [FormModel] = []
    @Published var currentForm: FormModel?
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private var cancellables = Set<AnyCancellable>()
    private let networkService: NetworkService
    
    init(networkService: NetworkService = URLSessionNetworkService()) {
        self.networkService = networkService
        loadFormsFromDisk()
    }
    
    func fetchForms() {
        isLoading = true
        errorMessage = nil
        
        networkService.fetchForms()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                self?.isLoading = false
                if case .failure(let error) = completion {
                    self?.errorMessage = error.localizedDescription
                }
            } receiveValue: { [weak self] forms in
                self?.forms = forms
                self?.saveFormsToDisk()
            }
            .store(in: &cancellables)
    }
    
    func createForm(title: String, description: String) {
        let newForm = FormModel(title: title, description: description)
        
        networkService.createForm(newForm)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                if case .failure(let error) = completion {
                    self?.errorMessage = error.localizedDescription
                }
            } receiveValue: { [weak self] createdForm in
                self?.forms.append(createdForm)
                self?.currentForm = createdForm
                self?.saveFormsToDisk()
            }
            .store(in: &cancellables)
    }
    
    func updateForm(_ form: FormModel) {
        networkService.updateForm(form)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                if case .failure(let error) = completion {
                    self?.errorMessage = error.localizedDescription
                }
            } receiveValue: { [weak self] updatedForm in
                if let index = self?.forms.firstIndex(where: { $0.id == updatedForm.id }) {
                    self?.forms[index] = updatedForm
                }
                self?.currentForm = updatedForm
                self?.saveFormsToDisk()
            }
            .store(in: &cancellables)
    }
    
    func deleteForm(_ form: FormModel) {
        networkService.deleteForm(form)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                if case .failure(let error) = completion {
                    self?.errorMessage = error.localizedDescription
                }
            } receiveValue: { [weak self] _ in
                self?.forms.removeAll { $0.id == form.id }
                if self?.currentForm?.id == form.id {
                    self?.currentForm = nil
                }
                self?.saveFormsToDisk()
            }
            .store(in: &cancellables)
    }
    
    private func loadFormsFromDisk() {
        if let data = UserDefaults.standard.data(forKey: "cachedForms"),
           let decodedForms = try? JSONDecoder().decode([FormModel].self, from: data) {
            self.forms = decodedForms
        }
    }
    
    private func saveFormsToDisk() {
        if let encodedForms = try? JSONEncoder().encode(forms) {
            UserDefaults.standard.set(encodedForms, forKey: "cachedForms")
        }
    }
}


