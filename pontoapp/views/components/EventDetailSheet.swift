//
//  EventDetailSheet.swift
//  pontoapp
//
//  Created by Erick Costa Reimberg de Lima on 02/04/26.
//

import SwiftUI

struct EventDetailSheet: View {
    let event: EventDetail
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationView {
            ZStack {
                Color.bg950.ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 24) {

                        // Header
                        HStack(spacing: 14) {
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color(hex: event.colorHex).opacity(0.15))
                                .frame(width: 56, height: 56)
                                .overlay(
                                    Image(systemName: event.icon)
                                        .font(.system(size: 24))
                                        .symbolRenderingMode(.monochrome)
                                        .symbolEffect(.wiggle, options: .nonRepeating)
                                        .foregroundColor(Color(hex: event.colorHex))
                                )

                            VStack(alignment: .leading, spacing: 4) {
                                Text(event.name)
                                    .font(.title2).fontWeight(.bold)
                                    .foregroundColor(.white)
                                Text(event.formattedDateTime)
                                    .font(.subheadline)
                                    .foregroundColor(.white.opacity(0.5))
                            }
                        }

                        // Descrição
                        if let desc = event.description, !desc.isEmpty {
                            VStack(alignment: .leading, spacing: 8) {
                                Label("Descrição", systemImage: "text.alignleft")
                                    .font(.caption)
                                    .foregroundColor(.white.opacity(0.4))
                                Text(descAttributed(from: desc))
                                    .font(.body)
                                    .foregroundColor(.white.opacity(0.85))
                                    .lineSpacing(4)
                            }
                            .padding()
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color.white.opacity(0.06))
                            .cornerRadius(12)
                        }

                        // Material de Apoio
                        if let materials = event.supportMaterial, !materials.isEmpty {
                            VStack(alignment: .leading, spacing: 10) {
                                Label("Material de Apoio", systemImage: "folder")
                                    .font(.caption)
                                    .foregroundColor(.white.opacity(0.4))

                                ForEach(materials, id: \.id) { item in
                                    AttachmentRow(
                                        filename: item.filename,
                                        url: item.url,
                                        color: Color(hex: event.colorHex)
                                    )
                                }
                            }
                            .padding()
                            .background(Color.white.opacity(0.06))
                            .cornerRadius(12)
                        }

                        // Links de Entrega
                        if let links = event.deliverableLinks {
                            let treatment = LinksTreatement(rawValue: links)
                            
                            VStack(alignment: .leading, spacing: 10) {
                                Label("Links de Entrega", systemImage: "arrow.up.doc")
                                    .font(.caption)
                                    .foregroundColor(.white.opacity(0.4))

                                ForEach(treatment.linksTreated, id: \.self){ links in
                                    LinksRow(
                                        linkTreated: links,
                                        color: Color(hex: event.colorHex)
                                    )
                                    
                                    if links != treatment.linksTreated.last {
                                        RoundedRectangle(cornerRadius: 10)
                                            .frame(height: 2)
                                            .foregroundStyle(Color.white.opacity(0.06))
                                    }
                                }
                            }
                            .padding()
                            .background(Color.white.opacity(0.06))
                            .cornerRadius(12)
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("Detalhes")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Fechar") { dismiss() }
                        .foregroundColor(.white)
                }
            }
        }
    }
    
    private func descAttributed(from raw: String) -> AttributedString {
        let options = AttributedString.MarkdownParsingOptions(
            interpretedSyntax: .inlineOnlyPreservingWhitespace
        )
        return (try? AttributedString(markdown: raw, options: options)) ?? AttributedString(raw)
    }
}

struct LinksTreated: Hashable {
    let title: String
    let link: String
    let date: String
}

struct LinksTreatement {
    let rawValue: String
    let linksTreated: [LinksTreated]
    
    init(rawValue: String) {
        self.rawValue = rawValue
        self.linksTreated = Self.treatRawValue(from: rawValue)
    }
    
    private static func treatRawValue(from rawValue: String) -> [LinksTreated]{
        let itens = rawValue.split(separator: ",")
        var linksTreated: [LinksTreated] = []
        
        for item in itens {
            let value = item.split(separator: "-", maxSplits: 2, omittingEmptySubsequences: true).map{
                $0.trimmingCharacters(in: .whitespacesAndNewlines)
            }
            
            guard value.count == 3 else { continue }
            
            let title = value[0]
            let date = value[1]
            let link = value[2].trimmingCharacters(in: CharacterSet(charactersIn: "<>"))
            
            linksTreated.append(LinksTreated(title: title, link: link, date: date))
        }
        
        return linksTreated
    }
}

struct LinksRow: View {
    let linkTreated: LinksTreated
    let color: Color
    
    var body: some View {
        if let link = URL(string: linkTreated.link) {
            Link(destination: link) {
                VStack(spacing: 15){
                    HStack(spacing: 10) {
                        Text(linkTreated.title)
                            .font(.headline)
                            .foregroundColor(color)
                            .lineLimit(1)
                        
                        Spacer()
                        
                        Text("Entrega: \(linkTreated.date)")
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(0.4))
                            .lineLimit(1)
                        
                    }
                    
                    HStack(spacing: 10) {
                        Image(systemName: "arrow.down.circle")
                            .font(.system(size: 18))
                            .foregroundColor(color)

                        Text("Link do entregável")
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(0.85))
                            .lineLimit(1)

                        Spacer()

                        Image(systemName: "arrow.up.right")
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.3))
                    }
                    
                }
                .padding(.vertical, 6)
            }
        }
    }
}

struct AttachmentRow: View {
    let filename: String
    let url: String
    let color: Color

    var body: some View {
        if let link = URL(string: url) {
            Link(destination: link) {
                HStack(spacing: 10) {
                    Image(systemName: "arrow.down.circle")
                        .font(.system(size: 18))
                        .foregroundColor(color)

                    Text(filename)
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.85))
                        .lineLimit(1)

                    Spacer()

                    Image(systemName: "arrow.up.right")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.3))
                }
                .padding(.vertical, 6)
            }
        }
    }
}

//#Preview {
//    let event = EventDetail(
//        id: "1",
//        name: "Challenge",
//        typeEvent: "Challenge",
//        time: Date.now,
//        icon: ["star.fill"],
//        colorHex: ["#4067D0"],
//        description: "Lorem Ipsum",
//        supportMaterial: [],
//        deliverableLinks: "Code - 28/05/2026 - https://iosda.link/CH2-Code, Keynote - 28/05/2026 - https://iosda.link/CH2-Keynote")
//
//    EventDetailSheet(event: event)
//}
