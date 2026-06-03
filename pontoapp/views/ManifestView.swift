//
//  ManifestView.swift
//  pontoapp
//
//  Created by Erick Costa Reimberg de Lima on 10/04/26.
//

import SwiftUI

struct ManifestView: View {

    private let items: [ManifestPrinciple] = [
        ManifestPrinciple(number: 1, text: "Não toleramos preconceitos e discriminação."),
        ManifestPrinciple(number: 2, text: "Integridade: saber identificar, não repetir e corrigir o erro alheio."),
        ManifestPrinciple(number: 3, text: "É prazeroso trabalhar em um ambiente leve e descontraído, porém sempre manter a seriedade e o profissionalismo."),
        ManifestPrinciple(number: 4, text: "A privacidade e o espaço interpessoal são imprescindíveis. Cuidado com o espaço do outro."),
        ManifestPrinciple(number: 5, text: "Coragem e abertura para errar e superar as dificuldades."),
        ManifestPrinciple(number: 6, text: "Cada um possui sua própria cadência de aprendizado. Respeite o tempo do próximo e suas limitações."),
        ManifestPrinciple(number: 7, text: "Lembrar que somos pessoas e corpos diferentes, com histórias diferentes. Uma verdade para você pode não ser verdade para outra pessoa."),
        ManifestPrinciple(number: 8, text: "Responsabilidade e compromisso com a qualidade do nosso trabalho."),
        ManifestPrinciple(number: 9, text: "Fazer críticas construtivas sempre com sugestões, respeitando o processo do outro e com foco em somar, nunca em criticar."),
        ManifestPrinciple(number: 10, text: "Zelar pelo ambiente de trabalho."),
    ]

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {

                ManifestImageCard()

                VStack(alignment: .leading, spacing: 4) {
                    Text("Os 10 princípios")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.white)
                    Text("Valores que guiam nossa convivência na Academy")
                        .font(.system(size: 13))
                        .foregroundColor(.white.opacity(0.45))
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 4)

                VStack(spacing: 0) {
                    ForEach(items) { principle in
                        ManifestPrincipleRow(principle: principle)
                    }
                }
                .background(Color.white.opacity(0.05))
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.white.opacity(0.08), lineWidth: 0.5)
                )
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 20)
        }
        .background(Color.bg950)
        .navigationTitle("Manifesto")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarColorScheme(.dark, for: .navigationBar)
    }
}

struct ManifestImageCard: View {
    var body: some View {
        VStack(spacing: 0) {
            Image("Manifest")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(maxWidth: .infinity)
                .clipShape(RoundedRectangle(cornerRadius: 14))
        }
        .padding(3)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color(hex: "#1D9E75").opacity(0.25), lineWidth: 0.5)
        )
    }
}

struct ManifestPrinciple: Identifiable {
    let id = UUID()
    let number: Int
    let text: String
}

struct ManifestPrincipleRow: View {
    let principle: ManifestPrinciple

    var body: some View {
        HStack(alignment: .top, spacing: 14) {
            Text("\(principle.number)")
                .font(.system(size: 11, weight: .bold))
                .foregroundColor(Color(hex: "#1D9E75"))
                .frame(width: 24, height: 24)
                .background(Color(hex: "#1D9E75").opacity(0.12))
                .clipShape(Circle())
                .padding(.top, 1)

            Text(principle.text)
                .font(.system(size: 14))
                .foregroundColor(.white.opacity(0.85))
                .lineSpacing(4)
                .fixedSize(horizontal: false, vertical: true)

            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .overlay(alignment: .bottom) {
            if principle.number < 10 {
                Rectangle()
                    .fill(Color.white.opacity(0.06))
                    .frame(height: 0.5)
            }
        }
    }
}

#Preview {
    NavigationStack {
        ManifestView()
    }
}
