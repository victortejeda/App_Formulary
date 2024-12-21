//
//  FormDetailView.swift
//  App_FormularioNativa
//
//  Created by Victor Tejeda on 20/12/24.
//

//
//  FormDetailView.swift
//  App_FormularioNativa
//
//  Created by Victor Tejeda on 20/12/24.
//

import SwiftUI

/// Vista para editar los detalles de un formulario.
struct FormDetailView: View {
    @ObservedObject var viewModel: FormViewModel  // ViewModel para manejar la lógica del formulario
    @State var form: FormModel                   // Modelo del formulario que se está editando
    @State private var showingAddQuestion = false // Estado para controlar la visibilidad del modal para agregar preguntas
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Campo de texto para editar el título del formulario
                TextField("Title", text: $form.title)
                    .font(.title)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                
                // Campo de texto para editar la descripción del formulario
                TextField("Description", text: $form.description)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                
                // Lista de preguntas del formulario
                ForEach(form.questions.indices, id: \.self) { index in
                    QuestionView(
                        question: form.questions[index],
                        onUpdate: { updatedQuestion in
                            form.questions[index] = updatedQuestion
                        },
                        onDelete: {
                            form.questions.remove(at: index)
                        }
                    )
                }
                
                // Botón para agregar una nueva pregunta
                Button(action: { showingAddQuestion = true }) {
                    Label("Add Question", systemImage: "plus.circle")
                }
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(8)
                
                // Botón para guardar los cambios
                Button(action: saveForm) {
                    Text("Save Changes")
                }
                .padding()
                .background(Color.green)
                .foregroundColor(.white)
                .cornerRadius(8)
            }
            .padding()
        }
        .navigationTitle("Edit Form")
        .sheet(isPresented: $showingAddQuestion) {
            AddQuestionView { newQuestion in
                form.questions.append(newQuestion)
            }
        }
    }
    
    /// Actualiza una pregunta existente en el formulario.
    private func updateQuestion(_ updatedQuestion: QuestionModel) {
        if let index = form.questions.firstIndex(where: { $0.id == updatedQuestion.id }) {
            form.questions[index] = updatedQuestion
        }
    }
    
    /// Elimina una pregunta específica del formulario.
    private func deleteQuestion(_ question: QuestionModel) {
        form.questions.removeAll { $0.id == question.id }
    }
    
    /// Guarda los cambios realizados en el formulario a través del ViewModel.
    private func saveForm() {
        viewModel.updateForm(form)
    }
}

/// Vista para mostrar y editar una pregunta específica dentro de un formulario.
struct QuestionView: View {
    @State var question: QuestionModel                   // Modelo de la pregunta
    let onUpdate: (QuestionModel) -> Void                // Closure para manejar actualizaciones
    let onDelete: () -> Void                             // Closure para manejar eliminación
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Campo de texto para editar el contenido de la pregunta
            TextField("Question", text: $question.text)
                .font(.headline)
            
            // Selector para el tipo de pregunta
            Picker("Type", selection: $question.type) {
                ForEach(QuestionType.allCases, id: \.self) { type in
                    Text(type.rawValue.capitalized).tag(type)
                }
            }
            .pickerStyle(SegmentedPickerStyle())
            
            // Opciones adicionales para preguntas de tipo múltiple
            if question.type == .multipleChoice || question.type == .checkboxes {
                if let options = question.options {
                    ForEach(options.indices, id: \.self) { index in
                        TextField("Option \(index + 1)", text: Binding(
                            get: { options[index] },
                            set: { newValue in
                                question.options?[index] = newValue
                            }
                        ))
                    }
                    Button("Add Option") {
                        question.options?.append("")
                    }
                }
            }
            
            // Toggle para marcar la pregunta como requerida
            Toggle("Required", isOn: $question.isRequired)
            
            // Botón para eliminar la pregunta
            HStack {
                Spacer()
                Button("Delete") {
                    onDelete()
                }
                .foregroundColor(.red)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(10)
        .onChange(of: question) { _ in
            onUpdate(question)
        }
    }
}

/// Vista para agregar una nueva pregunta al formulario.
struct AddQuestionView: View {
    @State private var questionText = ""                // Texto de la nueva pregunta
    @State private var questionType = QuestionType.shortAnswer // Tipo de la nueva pregunta
    @State private var isRequired = false               // Estado de si la pregunta es obligatoria
    @State private var options: [String] = []           // Opciones para preguntas múltiples
    @Environment(\.presentationMode) var presentationMode // Control de la presentación de la vista
    var onSave: (QuestionModel) -> Void                 // Closure para manejar el guardado
    
    var body: some View {
        NavigationView {
            Form {
                // Detalles de la pregunta
                Section(header: Text("Question Details")) {
                    TextField("Question Text", text: $questionText)
                    Picker("Question Type", selection: $questionType) {
                        ForEach(QuestionType.allCases, id: \.self) { type in
                            Text(type.rawValue.capitalized).tag(type)
                        }
                    }
                    Toggle("Required", isOn: $isRequired)
                }
                
                // Opciones para preguntas de tipo múltiple
                if questionType == .multipleChoice || questionType == .checkboxes {
                    Section(header: Text("Options")) {
                        ForEach(options.indices, id: \.self) { index in
                            TextField("Option \(index + 1)", text: $options[index])
                        }
                        Button("Add Option") {
                            options.append("")
                        }
                    }
                }
                
                // Botón para guardar la nueva pregunta
                Section {
                    Button("Save Question") {
                        let newQuestion = QuestionModel(
                            type: questionType,
                            text: questionText,
                            options: options.isEmpty ? nil : options,
                            isRequired: isRequired
                        )
                        onSave(newQuestion)
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
            .navigationTitle("Add Question")
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

