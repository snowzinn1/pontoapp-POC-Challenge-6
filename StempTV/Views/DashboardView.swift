import SwiftUI

struct DashboardView: View {
    @StateObject var viewModel = DashboardViewModel()

    let columns = Array(repeating: GridItem(.flexible(), spacing: 24), count: 8)

    private let gradientColors = LinearGradient(
        gradient: Gradient(colors: [Color.gradientStart, Color.gradientEnd]),
        startPoint: .leading,
        endPoint: .trailing
    )

    var body: some View {
        ZStack {
            Color.bg950.ignoresSafeArea()

            if viewModel.isLoading {
                ProgressView()
                    .tint(.white)
                    .scaleEffect(1.5)
            } else {
                VStack(alignment: .leading, spacing: 0) {
                    headerView
                        .padding(.horizontal, 60)
                        .padding(.top, 20)

                    // Divisor gradiente
                    RoundedRectangle(cornerRadius: 10)
                        .fill(gradientColors)
                        .frame(height: 10)
                        .padding(.vertical, 20)
                        .padding(.horizontal, 60)

                    statsRow
                        .padding(.horizontal, 60)
                        .padding(.bottom, 24)

                    GeometryReader { proxy in
                        ScrollView {
                            studentsGrid(cardWidth: cardWidth(in: proxy.size.width))
                                .padding(.horizontal, horizontalPadding)
                                .padding(.bottom, 40)
                        }
                    }
                }
            }
        }
        .onAppear{
            UIApplication.shared.isIdleTimerDisabled = true
        }
        .task { await viewModel.start() }
        .onDisappear { viewModel.stop() }
    }

    // MARK: - Header

    private var headerView: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 4) {
                Text("Apple Developer Academy | Senac")
                    .font(.system(.caption2, design: .rounded, weight: .medium))
                    .foregroundStyle(.secondary)
                    .textCase(.uppercase)

                HStack(spacing: 24) {
                    Text("Registros de hoje")
                        .font(.system(.title2, design: .rounded, weight: .semibold))
                        .foregroundStyle(.white)

                    Image("StempLogo")
                        .resizable()
                        .scaledToFit()
                        .frame(height: 64)
                        .padding(.horizontal, 9)
                        .padding(.vertical, 6)
                        .clipShape(RoundedRectangle(cornerRadius: 6))
                }

                Text(formattedDate)
                    .font(.system(.caption, design: .rounded))
                    .foregroundStyle(Color.white.opacity(0.3))
                    .padding(.top, 2)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 4) {
                ClockView()

                HStack(spacing: 6) {
                    Circle()
                        .fill(Color.green)
                        .frame(width: 6, height: 6)
                        .opacity(0.8)

                    if let updated = viewModel.lastUpdated {
                        Text("Última atualização: \(updated.formatted(.dateTime.hour().minute().second()))")
                            .font(.system(.caption2, design: .rounded))
                            .foregroundStyle(Color.white.opacity(0.3))
                    } else {
                        Text("Aguardando registros...")
                            .font(.system(.caption2, design: .rounded))
                            .foregroundStyle(Color.white.opacity(0.3))
                    }
                }
            }
        }
    }

    // MARK: - Stats

    private var statsRow: some View {
        HStack(spacing: 45) {
            StatChipView(count: viewModel.countPresent, label: "Presentes",  color: .green)
            StatChipView(count: viewModel.countLated,   label: "Atrasados",  color: .yellow)
            StatChipView(count: viewModel.countAbsent,  label: "Ausentes",   color: .red)
            StatChipView(count: viewModel.countPending, label: "Sem Registro", color: Color.white.opacity(0.3))
        }
    }
    
    private var formattedDate: String {
        let now = Date()
        let locale = Locale(identifier: "pt_BR")
        
        let weekday = now.formatted(.dateTime.weekday(.wide).locale(locale)).capitalized
        let rest = now.formatted(.dateTime.day().month(.wide).year().locale(locale))
        
        return "\(weekday), \(rest)"
    }
    
    private let columnsPerRow = 8
    private let rowSpacing: CGFloat = 28
    private let columnSpacing: CGFloat = 24
    private let horizontalPadding: CGFloat = 60

    private func cardWidth(in totalWidth: CGFloat) -> CGFloat {
        let availableWidth = totalWidth - (horizontalPadding * 2)
        let totalGaps = columnSpacing * CGFloat(columnsPerRow - 1)
        return max(0, (availableWidth - totalGaps) / CGFloat(columnsPerRow))
    }

    private func studentsGrid(cardWidth: CGFloat) -> some View {
        let students = viewModel.studentStatuses
        let rows = stride(from: 0, to: students.count, by: columnsPerRow).map { startIndex in
            Array(students[startIndex..<min(startIndex + columnsPerRow, students.count)])
        }
        
        return VStack(spacing: rowSpacing) {
            ForEach(Array(rows.enumerated()), id: \.offset) { rowIndex, rowStudents in
                HStack(spacing: columnSpacing) {
                    ForEach(Array(rowStudents.enumerated()), id: \.element.id) { columnIndex, student in
                        let absoluteIndex = rowIndex * columnsPerRow + columnIndex
                        StudentCardView(student: student, index: absoluteIndex)
                            .frame(width: cardWidth)
                    }
                }
                .frame(maxWidth: .infinity)
            }
        }
    }
}


#Preview {
    let vm = DashboardMock()
    
    DashboardView(viewModel: vm.viewModel)
}
