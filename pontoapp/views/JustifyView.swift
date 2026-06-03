//
//  JustifyAbstenceView.swift
//  pontoapp
//
//  Created by Erick Costa on 03/11/25.
//

import SwiftUI

struct JustifyView: View {
    @State var titleText: String
    @State var subtitleText: String
    
    @State private var isImporting: Bool = false
    @State var text: String = ""
    
    private let characterLimit: Int = 1000
    
    let gradientColors: LinearGradient = LinearGradient(gradient: Gradient(colors: [.gradientStart, .gradientEnd]), startPoint: .leading, endPoint: .trailing)
    
    @State var selectedFiles: [URL] = []
    
    var sendJustify: (String, [URL]) -> Void
    
    @FocusState private var isFocused: Bool
    
    private var counterColor: Color {
        let remaining = characterLimit - text.count
        
        if remaining <= 0 {
            return .red
        } else if remaining <= 50 {
            return .orange
        } else {
            return .white.opacity(0.6)
        }
    }

    
    var body: some View {
        VStack(spacing: 25){
            Text(titleText)
                .font(.largeTitle.bold())
                .foregroundStyle(.white)
            
            VStack(alignment: .leading, spacing: 15){
                HStack(spacing: 5){
                    Text("\(subtitleText)")
                        .font(.headline.bold())
                        .foregroundStyle(.white.opacity(0.6))
                    Text("*")
                        .font(.headline.bold())
                        .foregroundStyle(.red.opacity(0.6))
                }
                .padding(.horizontal, 20)
                
                TextEditor(text: $text)
                    .focused($isFocused)
                    .padding(10)
                    .frame(maxHeight: 200)
                    .foregroundStyle(.white)
                    .scrollContentBackground(.hidden)
                    .background(.bg900)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .padding(.horizontal, 20)
                    .onChange(of: text) { _, newValue in
                        if newValue.count > characterLimit {
                            text = String(newValue.prefix(characterLimit))
                        }
                    }
                    
                
                HStack {
                    Spacer()
                    Text("\(text.count)/\(characterLimit)")
                        .font(.caption)
                        .foregroundStyle(counterColor)
                        .contentTransition(.numericText())
                        .animation(.easeInOut(duration: 0.2), value: text.count)
                }
                .padding(.horizontal, 20)
                
                HStack(spacing: 5){
                    Text("*")
                        .font(.headline.bold())
                        .foregroundStyle(.red.opacity(0.6))
                    Text("Campo obrigatório a ser preenchido")
                        .font(.callout)
                        .foregroundStyle(counterColor)
                        .contentTransition(.numericText())
                        .animation(.easeInOut(duration: 0.2), value: text.count)
                    Spacer()
                }
                .padding(.horizontal, 20)

            }
            
            Button{
                isImporting = true
            } label: {
                HStack(){
                    Image(systemName: "slider.horizontal.3")
                    Text("Adicionar Arquivos")
                }
                .foregroundStyle(gradientColors)
                .frame(maxWidth: .infinity, minHeight: 50)
                .overlay{
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(gradientColors, lineWidth: 1)
                }
                .padding(.horizontal, 20)
                
            }
            
            if !selectedFiles.isEmpty {
                VStack(alignment: .leading, spacing: 5){
                    Text("Arquivos Selecionados:")
                        .font(.headline.bold())
                        .foregroundStyle(.white.opacity(0.6))
                        .padding(.horizontal, 20)
                    
                    ScrollView(.vertical, showsIndicators: true) {
                        VStack(spacing: 8) {
                            ForEach(selectedFiles, id: \.self) { url in
                                FileRowView(url: url) {
                                    removeFile(url)
                                }
                            }
                        }
                        .padding(.vertical, 4)
                    }
                    .padding(.horizontal, 15)
                    .frame(maxHeight: 300)
                }
            }
            
            Spacer()
            
            
            YellowButtonView(disabled: .constant(text.trimmingCharacters(in: .whitespacesAndNewlines).count < 10), text: "Enviar para Análise", iconImage: "person.fill.checkmark"){
                sendJustify(text, selectedFiles)
            }
            .padding(.bottom, 15)
            
        }
        .onAppear{
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                isFocused = true
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(.bg950)
        .ignoresSafeArea(.keyboard)
        .onTapGesture {
            isFocused = false
        }
        .toolbar {
            ToolbarItemGroup(placement: .topBarTrailing) {
                if isFocused{
                    Button("Concluir") {
                        isFocused = false
                    }
                    .transition(.opacity.combined(with: .scale(scale: 0.85)))
                }
            }
        }
        .animation(.easeInOut(duration: 0.25), value: isFocused)
        .fileImporter(isPresented: $isImporting, allowedContentTypes: [.pdf, .image, .png, .jpeg, .text], allowsMultipleSelection: true){
            result in
            
            switch result {
            case .success(let urls):
                guard urls.isEmpty == false else { return }
                
                DispatchQueue.main.async {
                    self.selectedFiles.append(contentsOf: urls)
                }
                
            case .failure(let error):
                print("Erro ao adicionar os arquivos: \(error.localizedDescription)")
            }
        }
    }
    
    func removeFile(_ url: URL) {
        if let index = selectedFiles.firstIndex(of: url) {
            _ = withAnimation {
                selectedFiles.remove(at: index)
            }
        }
    }
}

#Preview {
    JustifyView(titleText: "Justificar Ausência", subtitleText: "MOTIVO DA SUA AUSÊNCIA", text: "Placeholder", selectedFiles: [URL(filePath: "alguma coisa"), URL(filePath: "alguma coisa"), URL(filePath: "alguma coisa")]){ text, file in
        
    }
}

