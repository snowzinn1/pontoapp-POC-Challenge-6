//
//  DayDetailSheet.swift
//  pontoapp
//
//  Created by Erick Costa Reimberg de Lima on 25/03/26.
//

import SwiftUI

struct DayDetailSheet: View {
    let detail: DayDetail

    private var formattedDate: String {
        let fmt = DateFormatter()
        fmt.locale = Locale(identifier: "pt_BR")
        fmt.dateFormat = "EEEE, d 'de' MMMM"
        return fmt.string(from: detail.date).capitalized
    }

    private var isEmpty: Bool {
        detail.checkIn == nil && detail.events.isEmpty
            && detail.holiday == nil && detail.vacation == nil
    }
    
    private var hasJustification: Bool {
        detail.checkIn?.justifyText != nil
    }

    var body: some View {
        ZStack {
            Color.bg950.ignoresSafeArea()

            if isEmpty {
                emptyState
            } else {
                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        
                        //indicador de sheet
                        RoundedRectangle(cornerRadius: 3)
                            .fill(Color.white.opacity(0.3))
                            .frame(width: 68, height: 4)
                            .frame(maxWidth: .infinity)
                            .padding(.top, 24)
                        
                        header

                        if let holiday = detail.holiday {
                            HolidayBanner(name: holiday)
                        }
                        
                        if let vacation = detail.vacation {
                            VacationBanner(interval: vacation)
                        }

                        if detail.vacation == nil && detail.holiday == nil {
                            checkInSection
                        }
                        
                        if let checkIn = detail.checkIn, let justify = checkIn.justifyText {
                            justifySection(text: justify)
                        }

                        if !detail.events.isEmpty {
                            eventsSection
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 32)
                }
            }
        }
        .presentationDragIndicator(.hidden)
        .presentationDetents([.medium, .large])
    }

    // MARK: - Header

    private var header: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(formattedDate)
                .font(.system(size: 22, weight: .bold))
                .foregroundStyle(.white)
        }
        .padding(.top, 10)
        .padding(.horizontal, 14)
    }

    // MARK: - Empty State

    private var emptyState: some View {
        VStack(spacing: 12) {
            Image(systemName: "clock.badge.xmark.fill")
                .font(.system(size: 48))
            Text("Nenhuma informação\npara este dia")
                .font(.system(size: 17, weight: .medium))
                .foregroundStyle(.white.opacity(0.5))
                .multilineTextAlignment(.center)
        }
    }

    // MARK: - CheckIn Section

    private var checkInSection: some View {
        SectionCard(title: "Registro de Ponto", icon: "clock.fill") {
            if let checkIn = detail.checkIn {
                HStack(alignment: .center) {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Horário")
                            .font(.system(size: 13))
                            .foregroundStyle(.white.opacity(0.4))
                        Text(checkIn.time)
                            .font(.system(size: 32, weight: .bold, design: .rounded))
                            .foregroundStyle(.white)
                    }
                    Spacer()
                    StatusBadge(status: checkIn.status)
                }
            } else {
                HStack(spacing: 12) {
                    Image(systemName: "minus.circle.fill")
                        .font(.system(size: 28))
                    Text("Nenhum registro\nneste dia")
                        .font(.system(size: 15))
                        .foregroundStyle(.white.opacity(0.4))
                }
                .padding(.vertical, 4)
            }
        }
    }
    
    //MARK: - Justify Section
    private func justifySection(text: String) -> some View {
        SectionCard(title: "Justificativa", icon: "text.bubble.fill") {
            Text(text)
                .font(.system(size: 15))
                .foregroundStyle(.white.opacity(0.75))
                .lineLimit(nil)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    // MARK: - Events Section

    private var eventsSection: some View {
        SectionCard(title: "Eventos", icon: "sparkles") {
            VStack(spacing: 14) {
                ForEach(detail.events) { event in
                    EventRow(event: event)
                    if event.id != detail.events.last?.id {
                        Divider()
                            .background(Color.white.opacity(0.08))
                    }
                }
            }
        }
    }
}


private struct VacationBanner: View {
    let interval: VacationInterval

    private var periodo: String {
        let fmt = DateFormatter()
        fmt.locale = Locale(identifier: "pt_BR")
        fmt.dateFormat = "d 'de' MMM"
        return "\(fmt.string(from: interval.start)) até \(fmt.string(from: interval.end))"
    }

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: "sun.max.fill")
                .font(.system(size: 18))
            VStack(alignment: .leading, spacing: 2) {
                Text("Férias")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(.teal.opacity(0.8))
                Text(interval.title)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(.white)
                Text(periodo)
                    .font(.system(size: 13))
                    .foregroundStyle(.white.opacity(0.5))
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.teal.opacity(0.12))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.teal.opacity(0.25), lineWidth: 1)
        )
    }
}

// MARK: - Subviews

private struct HolidayBanner: View {
    let name: String
    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: "star.fill")
                .font(.system(size: 18))
            VStack(alignment: .leading, spacing: 2) {
                Text("Feriado")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(.yellow.opacity(0.7))
                Text(name)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(.white)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.yellow.opacity(0.12))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.yellow.opacity(0.25), lineWidth: 1)
        )
    }
}

private struct SectionCard<Content: View>: View {
    let title: String
    let icon: String
    @ViewBuilder let content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {

            // Título da seção
            HStack(spacing: 7) {
                Image(systemName: icon)
                    .font(.system(size: 13, weight: .semibold))
                Text(title)
                    .font(.system(size: 13, weight: .semibold))
                    .textCase(.uppercase)
                    .tracking(0.5)
            }
            .foregroundStyle(.white.opacity(0.4))

            // Divisor
            Rectangle()
                .fill(Color.white.opacity(0.06))
                .frame(height: 1)

            content
        }
        .padding(18)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.white.opacity(0.05))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

private struct StatusBadge: View {
    let status: RecordStatus

    var label: String {
        switch status {
        case .present: return "Presente"
        case .lated:   return "Atrasado"
        case .absent:  return "Ausente"
        case .holiday: return "Feriado"
        }
    }

    var color: Color {
        switch status {
        case .present: return .green
        case .lated:   return .orange
        case .absent:  return .red
        case .holiday: return .white
        }
    }

    var body: some View {
        Text(label)
            .font(.system(size: 14, weight: .semibold))
            .padding(.horizontal, 14)
            .padding(.vertical, 7)
            .background(color.opacity(0.18))
            .foregroundStyle(color)
            .clipShape(Capsule())
            .overlay(
                Capsule()
                    .stroke(color.opacity(0.3), lineWidth: 1)
            )
    }
}

private struct EventRow: View {
    let event: EventDetail

    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: event.icon)
                .font(.system(size: 17))
                .foregroundStyle(.blue)
                .frame(width: 38, height: 38)
                .background(Color.blue.opacity(0.15))
                .clipShape(RoundedRectangle(cornerRadius: 10))

            VStack(alignment: .leading, spacing: 3) {
                Text(event.name)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(.white)
                Text(event.formattedTime)
                    .font(.system(size: 14))
                    .foregroundStyle(.white.opacity(0.4))
            }

            Spacer()
        }
    }
}
