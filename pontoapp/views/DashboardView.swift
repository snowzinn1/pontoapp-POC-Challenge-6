//
//  DashboardView.swift
//  pontoapp
//
//  Created by Joao Carlos Lima on 30/10/25.
//

import SwiftUI

struct DashboardView: View {
    @StateObject var viewModel = DashboardViewModel()
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.bg950.ignoresSafeArea()
                
                VStack(spacing: 15) {
                    if viewModel.isLoading {
                        ProgressView()
                            .tint(.white)
                            .padding(.top, 60)
                    } else {
                        AttendanceProgressChart(
                            presences: viewModel.presences,
                            absences: viewModel.absences,
                            delays: viewModel.delays
                        )
                        
                        AttendanceStatusCard(
                            status: viewModel.attendanceStatus,
                            absences: viewModel.absences
                        )
                        
                        if let event = viewModel.nextEvent {
                            NextEventCard(event: event)
                        } else {
                            ContentUnavailableView {
                                VStack{
                                    Image(systemName: "star.slash.fill")
                                        .font(.system(size: 40))
                                        .foregroundStyle(.white)
                                    Text("Sem eventos. Novos eventos em breve!")
                                        .font(.system(size: 15))
                                        .foregroundStyle(.white.opacity(0.6))
                                }
                            }
                        }
                        
                        Spacer()
                    }
                }
                .padding(.horizontal)
                .padding(.top, 8)
            }
            .navigationTitle("Dashboard")
            .toolbarColorScheme(.dark, for: .navigationBar)
            .onAppear {
                viewModel.loadSummary()
            }
            .refreshable {
                viewModel.loadSummary()
            }
        }
    }
}

struct EventCard: View {
    let event: EventFields
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: event.icon ?? "calendar.fill")
                .font(.largeTitle)
                .foregroundColor(.blue)
                .frame(width: 60, height: 60)
                .background(Color.blue.opacity(0.2))
                .cornerRadius(12)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(event.name)
                    .font(.headline)
                    .foregroundColor(.white)
                
                Text(event.formattedDate)
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.7))
            }
            
            Spacer()
        }
        .padding()
        .background(Color.gray.opacity(0.2))
        .cornerRadius(12)
    }
}

#Preview {
    DashboardView()
}
