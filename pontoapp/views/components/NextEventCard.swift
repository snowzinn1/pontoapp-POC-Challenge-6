//
//  NextEventCard.swift
//  pontoapp
//
//  Created by Erick Costa Reimberg de Lima on 02/04/26.
//

import SwiftUI

struct NextEventCard: View {
    let event: EventDetail
    
    @State private var visible = false
    @State private var showDetail = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Próximo evento")
                .font(.caption)
                .bold()
                .foregroundColor(.white)

            Divider()
            
            HStack(spacing: 12) {
                RoundedRectangle(cornerRadius: 6)
                    .fill(Color(hex: event.colorHex).opacity(0.15))
                    .frame(width: 44, height: 44)
                    .overlay(
                        Image(systemName: event.icon)
                            .font(.title2)
                            .symbolRenderingMode(.monochrome)
                            .symbolEffect(.wiggle, options: .nonRepeating)
                            .foregroundColor(Color(hex: event.colorHex))
                    )

                VStack(alignment: .leading, spacing: 3) {
                    Text(event.name)
                        .font(.subheadline).fontWeight(.medium)
                        .foregroundColor(.white)
                    Text(event.formattedDateTime)
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.45))
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.25))
            }
        }
        .padding()
        .background(Color.white.opacity(0.06))
        .cornerRadius(16)
        .opacity(visible ? 1 : 0)
        .offset(y: visible ? 0 : 12)
        .onAppear {
            withAnimation(.easeOut(duration: 0.5).delay(0.15)) {
                visible = true
            }
        }
        .onTapGesture { showDetail = true }
        .sheet(isPresented: $showDetail) {
            EventDetailSheet(event: event)
        }

    }
}

#Preview {
    let event = EventDetail(
        id: "1",
        name: "Challenge",
        typeEvent: "Challenge",
        time: Date.now,
        icon: "star.fill",
        colorHex: "#4067D0",
        description: "Lorem Ipsum",
        supportMaterial: [],
        deliverableLinks: "teste")
    
    ZStack {
        Color.bg950.ignoresSafeArea()
        
        NextEventCard(event: event)

    }
}
