//
//  EventItem.swift
//  pontoapp
//
//  Created by Joao Carlos Lima on 30/10/25.
//

import SwiftUI

struct EventItem: View {
    let eventInfos: EventDetail
    let isNew: Bool
    let openEventDetail: () -> Void
    @State private var showDetail = false
    @State private var opacity: Bool = false
    
    var body: some View {
        HStack{
            Rectangle()
                .foregroundStyle(Color(hex: eventInfos.colorHex))
                .frame(width: 7)
                
                
            VStack(alignment: .leading){
                Text(eventInfos.typeEvent)
                    .font(.title2)
                    .bold()
                    .foregroundStyle(.white)
                Text(eventInfos.formattedDateTime)
                    .foregroundStyle(Color.white.opacity(0.5))
            }
            .padding(.leading, 5)
                
            Spacer()
                    
            Image(systemName: eventInfos.icon)
                .font(.title)
                .symbolRenderingMode(.monochrome)
                .symbolEffect(.wiggle, options: .nonRepeating)
                .foregroundStyle(Color(hex: eventInfos.colorHex))
                
            Image(systemName: "chevron.right")
                .font(.title3)
                .foregroundStyle(Color.white.opacity(0.5))
                .padding(.leading, 10)
        }
        .overlay(alignment: .topTrailing){
            if isNew {
                Text("Novo")
                    .bold()
                    .foregroundStyle(Color.white)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 2)
                    .background(Color.red)
                    .opacity(opacity ? 1 : 0.4)
                    .clipShape(Capsule())
                    .offset(y: -28.5)
                    .animation(.easeOut(duration: 1.0).repeatForever(autoreverses: true),
                        value: opacity
                    )
            }
        }
        .padding()
        .fixedSize(horizontal: false, vertical: true)
        .background(
            RoundedRectangle(cornerRadius: 15).foregroundStyle(Color.bg900)
        )
        .padding(.horizontal, 5)
        .contentShape(Rectangle())
        .onAppear{
            opacity = true
        }
        .onTapGesture {
            showDetail = true
            openEventDetail()
        }
        .sheet(isPresented: $showDetail) {
            EventDetailSheet(event: eventInfos)
        }

    }
}

#Preview {
    var isNew = true
    let events = [
        EventDetail(
        id: "1",
        name: "Challenge",
        typeEvent: "Challenge",
        time: Date.now,
        icon: "sparkle.text.clipboard.fill",
        colorHex: "#EF9F27",
        description: "Lorem Ipsum",
        supportMaterial: [],
        deliverableLinks: "teste"
    ),
     EventDetail(
         id: "2",
         name: "Workshop",
         typeEvent: "Workshop",
         time: Date.now,
         icon: "book.and.wrench.fill",
         colorHex: "#378ADD",
         description: "Lorem Ipsum",
         supportMaterial: [],
         deliverableLinks: "teste"
     ),
     EventDetail(
         id: "3",
         name: "Apresentação",
         typeEvent: "Apresentação",
         time: Date.now,
         icon: "play.tv",
         colorHex: "#7F77DD",
         description: "Lorem Ipsum",
         supportMaterial: [],
         deliverableLinks: "teste"
     ),
      EventDetail(
          id: "4",
          name: "Bridge",
          typeEvent: "Bridge",
          time: Date.now,
          icon: "ruler.fill",
          colorHex: "#1D9E75",
          description: "Lorem Ipsum",
          supportMaterial: [],
          deliverableLinks: "teste"
      ),
      EventDetail(
          id: "5",
          name: "Integration",
          typeEvent: "Integration",
          time: Date.now,
          icon: "figure.socialdance.circle.fill",
          colorHex: "#639922",
          description: "Lorem Ipsum",
          supportMaterial: [],
          deliverableLinks: "teste"
      ),
      EventDetail(
          id: "6",
          name: "Eventos",
          typeEvent: "Eventos",
          time: Date.now,
          icon: "apple.logo",
          colorHex: "#E98049",
          description: "Lorem Ipsum",
          supportMaterial: [],
          deliverableLinks: "teste"
      ),
      EventDetail(
          id: "7",
          name: "Reflection",
          typeEvent: "Reflection",
          time: Date.now,
          icon: "brain.head.profile.fill",
          colorHex: "#DF537E",
          description: "Lorem Ipsum",
          supportMaterial: [],
          deliverableLinks: "teste"
      )
    
    ]
    
    ZStack{
        Color.bg950.ignoresSafeArea()
        
        VStack(spacing: 20){
            ForEach(events.indices, id: \.self) { index in
                EventItem(eventInfos: events[index], isNew: index % 2 == 0) {
                    
                }
            }
        }
    }
}

