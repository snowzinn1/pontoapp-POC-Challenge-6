//
//  CalendarView.swift
//  pontoapp
//
//  Created by Erick Costa on 06/12/25.
//

import SwiftUI

struct CalendarView: View {
    @Binding var currentDate: Date
    @State private var selectedDate: Date = Date()
    
    @Binding var daysCheckedIn: [Int: RecordStatus]
    @Binding var daysWithEvents: [Int]
    
    @State private var displayedDate: Date = Date()
    
    var seeRecords: ((_ month: Int, _ year: Int) -> Void)
    var onDateSelected: ((_ date: Date) -> Void)? = nil
    
    var body: some View {
            VStack(spacing: 15) {
                
                HStack(spacing: 15) {
                    Button {
                        withAnimation(.easeInOut) {
                            changeMonthAnimated(by: -1)
                        }
                    } label: {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundStyle(.white)
                            .frame(width: 32, height: 32)
                            .background(Color.white.opacity(0.1))
                            .clipShape(Circle())
                    }
                   
                    Text(currentDate.formatMonthAndYear().capitalized)
                        .font(.system(size: 18, weight: .bold))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                        .background(Color.white.opacity(0.05))
                        .clipShape(Capsule())
                    
                    Button {
                        withAnimation(.easeInOut) {
                            changeMonthAnimated(by: 1)
                        }
                    } label: {
                        Image(systemName: "chevron.right")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundStyle(.white)
                            .frame(width: 32, height: 32)
                            .background(Color.white.opacity(0.1))
                            .clipShape(Circle())
                    }
                }
                .padding(.bottom, 5)
                
                VStack(spacing: 8){
                    HStack(spacing: 0) {
                        ForEach(["Dom", "Seg", "Ter", "Qua", "Qui", "Sex", "Sáb"], id: \.self) { day in
                            Text(day)
                                .font(.system(size: 12, weight: .semibold))
                                .frame(maxWidth: .infinity)
                                .foregroundColor(.gray)
                        }
                    }
                    .padding(.horizontal, 7)
                    
                    let columns = Array(repeating: GridItem(.flexible(), spacing: 8), count: 7)

                    LazyVGrid(columns: columns, spacing: 8) {
                        ForEach(currentDate.daysOfMonth()) { value in
                            if value.day != -1 {
                                let isSelected = Calendar.academy.isDate(value.date, inSameDayAs: selectedDate)
                                let status = daysCheckedIn[value.day]
                                
                                ZStack {
                                    if value.isDisabledDay {
                                        RoundedRectangle(cornerRadius: 6)
                                            .fill(getBackgroundColor(status: .holiday))
                                    } else {
                                        RoundedRectangle(cornerRadius: 6)
                                            .fill(getBackgroundColor(status: status))
                                    }
                                    
                                    if isSelected {
                                        RoundedRectangle(cornerRadius: 6)
                                            .stroke(Color.white, lineWidth: 1.5)
                                    }
                                    
                                    Text("\(value.day)")
                                        .font(.system(size: 14, weight: .bold))
                                        .foregroundColor(getTextColor(status: status))
                                    
                                    if daysWithEvents.contains(value.day) && !value.isDisabledDay {
                                        Circle()
                                            .fill(Color.white)
                                            .frame(width: 5, height: 5)
                                            .offset(x: 12, y: -12)
                                    }
                                }
                                .aspectRatio(1, contentMode: .fit)
                                .onTapGesture {
                                    withAnimation {
                                        self.selectedDate = value.date
                                    }
                                    onDateSelected?(value.date)
                                }
                            } else {
                                RoundedRectangle(cornerRadius: 6)
                                    .fill(Color.white.opacity(0.03))
                                    .aspectRatio(1, contentMode: .fit)
                            }
                        }
                    }
                    .padding(.horizontal, 10)

                }
                .id(currentDate.month)
                .transition(.scale(scale: 0.88).combined(with: .opacity))
                .clipped()
                
                RoundedRectangle(cornerRadius: 10)
                    .frame(maxWidth: .infinity)
                    .frame(height: 3)
                    .foregroundStyle(.gray.opacity(0.3))
                    .padding(.horizontal, 8)
                    .padding(.top, 5)
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Legenda:")
                        .fontWeight(.bold)
                        .font(.system(size: 14))
                    
                    HStack(spacing: 12) {
                        LegendItem(color: .green, label: "Presença")
                        LegendItem(color: .orange, label: "Atraso")
                        LegendItem(color: .red, label: "Ausência")
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.bottom, 4)
                }
                .foregroundStyle(.white)
                .padding(.horizontal, 10)
            }
            .padding(.vertical, 16)
            .padding(.horizontal, 16)
            .background(Color.bg900)
            .cornerRadius(15)
            .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: 5)
            .padding(.horizontal, 15)            .padding(.bottom)
        }
        
    func changeMonth(by offset: Int) {
        if let newDate = Calendar.academy.date(byAdding: .month, value: offset, to: currentDate) {
            currentDate = newDate
        }
    }
    
    func changeMonthAnimated(by offset: Int) {
        guard let nextDate = Calendar.academy.date(byAdding: .month, value: offset, to: currentDate) else { return }
            
        seeRecords(nextDate.month, nextDate.year)
        
        withAnimation(.spring(response: 0.7, dampingFraction: 0.5)) {
            currentDate = nextDate
        }
    }
    
    func getBackgroundColor(status: RecordStatus?) -> Color {
        guard let status = status else {
            return Color.blue.opacity(0.2)
        }
        switch status {
        case .absent: return .red.opacity(0.8)
        case .lated: return .orange.opacity(0.9)
        case .present: return .green.opacity(0.8)
        case .holiday: return .white.opacity(0.15)
        }
    }
    
    func getTextColor(status: RecordStatus?) -> Color {
        if status != nil {
            return .white
        }
        return .white.opacity(0.7)
    }
}

#Preview {
    ZStack {
        Color.black.ignoresSafeArea()
        
        CalendarView(
            currentDate: .constant(Date.now), daysCheckedIn: .constant([
                2: .present,
                3: .present,
                4: .present,
                5: .present,
                6: .present,
                
                9: .present,
                10: .lated,
                11: .absent,
                12: .present,
                13: .present,
                
                16: .present,
                17: .present,
                28: .present
            ]), daysWithEvents: .constant([]),
        ) { month, year in
            print("Setinha clicada! Buscando dados de: \(month)/\(year)")
        }
    }
}
