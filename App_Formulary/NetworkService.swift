//
//  NetworkService.swift
//  App_FormularioNativa
//
//  Created by Victor Tejeda on 20/12/24.
//

import Foundation
import Combine

protocol NetworkService {
    func fetchForms() -> AnyPublisher<[FormModel], Error>
    func createForm(_ form: FormModel) -> AnyPublisher<FormModel, Error>
    func updateForm(_ form: FormModel) -> AnyPublisher<FormModel, Error>
    func deleteForm(_ form: FormModel) -> AnyPublisher<Void, Error>
}

class URLSessionNetworkService: NetworkService {
    private let baseURL = URL(string: "https://api.example.com/v1/")!
    private let session: URLSession
    private let decoder: JSONDecoder
    
    init(session: URLSession = .shared, decoder: JSONDecoder = JSONDecoder()) {
        self.session = session
        self.decoder = decoder
    }
    
    func fetchForms() -> AnyPublisher<[FormModel], Error> {
        let url = baseURL.appendingPathComponent("forms")
        return session.dataTaskPublisher(for: url)
            .map(\.data)
            .decode(type: [FormModel].self, decoder: decoder)
            .eraseToAnyPublisher()
    }
    
    func createForm(_ form: FormModel) -> AnyPublisher<FormModel, Error> {
        let url = baseURL.appendingPathComponent("forms")
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            request.httpBody = try JSONEncoder().encode(form)
        } catch {
            return Fail(error: error).eraseToAnyPublisher()
        }
        
        return session.dataTaskPublisher(for: request)
            .map(\.data)
            .decode(type: FormModel.self, decoder: decoder)
            .eraseToAnyPublisher()
    }
    
    func updateForm(_ form: FormModel) -> AnyPublisher<FormModel, Error> {
        let url = baseURL.appendingPathComponent("forms/\(form.id)")
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            request.httpBody = try JSONEncoder().encode(form)
        } catch {
            return Fail(error: error).eraseToAnyPublisher()
        }
        
        return session.dataTaskPublisher(for: request)
            .map(\.data)
            .decode(type: FormModel.self, decoder: decoder)
            .eraseToAnyPublisher()
    }
    
    func deleteForm(_ form: FormModel) -> AnyPublisher<Void, Error> {
        let url = baseURL.appendingPathComponent("forms/\(form.id)")
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        
        return session.dataTaskPublisher(for: request)
            .map { _ in () }
            .mapError { $0 as Error }
            .eraseToAnyPublisher()
    }
}

