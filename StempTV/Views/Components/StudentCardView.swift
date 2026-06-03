//
//  StudentCardView.swift
//  pontoapp
//
//  Created by Erick Costa Reimberg de Lima on 30/04/26.
//

import SwiftUI

struct StudentCardView: View {
    let student: DashboardViewModel.StudentStatus
    let index: Int

    @State private var appeared = false
    @State private var previousStatus: AttendanceStatus = .pending

    var body: some View {
        VStack(spacing: 8) {
            ZStack(alignment: .center) {
                Circle()
                    .strokeBorder(statusColor, lineWidth: 4)
                    .frame(width: 96, height: 96)

                AsyncImage(url: student.memojiURL) { image in
                    image.resizable().scaledToFill()
                } placeholder: {
                    Image(systemName: "person.fill")
                        .font(.system(size: 40))
                        .foregroundStyle(Color.white.opacity(0.3))
                }
                .frame(width: 80, height: 80)
                .clipShape(Circle())
                .grayscale(student.status == .pending ? 1 : 0)
                .opacity(student.status == .pending ? 0.45 : 1)
            }
            .overlay(alignment: .bottom) {
                if student.status != .pending {
                    Image(systemName: statusSymbol)
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(.white)
                        .frame(width: 28, height: 28)
                        .background(statusColor)
                        .clipShape(Circle())
                        .offset(y: 10)
                        .transition(.scale.combined(with: .opacity))
                }
            }
            .padding(.bottom, 12)

            Text(getFirstAndLastName(fullName: student.name))
                .font(.system(size: 16, weight: .medium, design: .rounded))
                .foregroundStyle(Color.white.opacity(0.7))
                .lineLimit(1)
                .truncationMode(.tail)
                .frame(maxWidth: 110)

            if let time = student.checkinTime {
                Text(time.formatted(.dateTime.hour().minute()))
                    .font(.system(size: 13, weight: .regular, design: .monospaced))
                    .foregroundStyle(Color.white.opacity(0.4))
            } else {
                Text(" ")
                    .font(.system(size: 13))
            }
            
        }
        .opacity(appeared ? 1 : 0)
        .scaleEffect(appeared ? 1 : 0.6)
        .animation(.spring(response: 0.4, dampingFraction: 0.7), value: student.status)
        .onAppear {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.7).delay(Double(index) * 0.03)) {
                appeared = true
            }
        }
    }

    private var statusColor: Color {
        switch student.status {
        case .present: .green
        case .lated:   .yellow
        case .absent:  .red
        case .pending: Color.white.opacity(0.1)
        }
    }

    private var statusSymbol: String {
        switch student.status {
        case .present: "checkmark"
        case .lated:   "clock"
        case .absent:  "xmark"
        case .pending: ""
        }
    }
    
    func getFirstAndLastName(fullName: String) -> String {
        let name = fullName.split(separator: " ")
        return "\(name.first?.capitalized ?? "") \(name.last?.capitalized ?? "")"
    }
}
