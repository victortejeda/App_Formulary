//
//  FormModels.swift
//  App_FormularioNativa
//
//  Created by Victor Tejeda on 20/12/24.
//

import Foundation

struct FormModel: Identifiable, Codable, Equatable {
    let id: UUID
    var title: String
    var description: String
    var questions: [QuestionModel]
    var createdAt: Date
    var updatedAt: Date
    var responses: Int
    var isPublished: Bool
    
    init(id: UUID = UUID(), title: String, description: String, questions: [QuestionModel] = [], responses: Int = 0, isPublished: Bool = false) {
        self.id = id
        self.title = title
        self.description = description
        self.questions = questions
        self.createdAt = Date()
        self.updatedAt = Date()
        self.responses = responses
        self.isPublished = isPublished
    }
}

struct QuestionModel: Identifiable, Codable, Equatable {
    let id: UUID
    var type: QuestionType
    var text: String
    var options: [String]?
    var isRequired: Bool
    var responses: [String]
    
    init(id: UUID = UUID(), type: QuestionType, text: String, options: [String]? = nil, isRequired: Bool = false, responses: [String] = []) {
        self.id = id
        self.type = type
        self.text = text
        self.options = options
        self.isRequired = isRequired
        self.responses = responses
    }
}

enum QuestionType: String, Codable, CaseIterable {
    case shortAnswer
    case paragraph
    case multipleChoice
    case checkboxes
    case date
    case time
    case linearScale
    case fileUpload
}


