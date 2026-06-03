//
//  EventsView.swift
//  pontoapp
//
//  Created by Erick Costa Reimberg de Lima on 26/03/26.
//

import SwiftUI

struct EventsView: View {
    @EnvironmentObject private var viewModel: EventsViewModel
    
    var body: some View {
        NavigationView {
            ZStack{
                Color.bg950.ignoresSafeArea(edges: .all)
                                
                if !viewModel.events.isEmpty {
                    ScrollView(.vertical, showsIndicators: false) {
                        VStack(spacing: 25){
                            ForEach(viewModel.events, id: \.self.id) { event in
                                EventItem(
                                    eventInfos: event,
                                    isNew: viewModel.isNew(event),
                                    openEventDetail: { viewModel.markAsSeen(event) }
                                )
                            }
                        }
                    }
                } else {
                    ContentUnavailableView {
                        VStack{
                            Image(systemName: "star.slash.fill")
                                .font(.system(size: 70))
                                .foregroundStyle(.white)
                            Text("Sem eventos")
                                .font(.system(size: 30))
                                .bold()
                                .foregroundStyle(.white)
                        }
                    } description: {
                        VStack{
                            Text("Nenhum evento encontrado.")
                                .font(.system(size: 15))
                                .foregroundStyle(.white.opacity(0.4))
                            Text("Fique tranquilo, estamos sempre adicionando novos eventos para você!")
                                .font(.system(size: 15))
                                .foregroundStyle(.white.opacity(0.4))
                        }
                    }
                }
            }
            .refreshable {
                viewModel.fetchEvents()
            }
            .navigationTitle("Eventos")
            .toolbarColorScheme(.dark, for: .navigationBar)
        }
        
    }
}

#Preview {
    EventsView()
}
