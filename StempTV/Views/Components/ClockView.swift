//
//  ClockView.swift
//  pontoapp
//
//  Created by Erick Costa Reimberg de Lima on 30/04/26.
//

import SwiftUI
import Combine

struct ClockView: View {
    @State private var now = Date()
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    var body: some View {
        Text(now.formatted(.dateTime.hour().minute().second()))
            .font(.system(size: 56, weight: .semibold, design: .rounded))
            .foregroundStyle(.white)
            .contentTransition(.numericText())
            .animation(.easeInOut(duration: 0.2), value: now)
            .onReceive(timer) { now = $0 }
    }
}
