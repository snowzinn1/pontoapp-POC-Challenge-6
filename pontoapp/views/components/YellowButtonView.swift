//
//  YellowButtonView.swift
//  pontoapp
//
//  Created by Erick Costa Reimberg de Lima on 23/03/26.
//

import SwiftUI

struct YellowButtonView: View {
    @Binding var disabled: Bool
    let text: String
    let iconImage: String?
    let action: () -> Void
    private let gradientColors: LinearGradient = LinearGradient(gradient: Gradient(colors: [
            Color.gradientStart,
            Color.gradientEnd]),
            startPoint: .leading,
            endPoint: .trailing
    )
    
    private let gradientDisabled: LinearGradient = LinearGradient(gradient: Gradient(
        colors: [
            Color.gray.opacity(0.3),
            Color.gray.opacity(0.3)]),
            startPoint: .leading,
            endPoint: .trailing
    )
    
    var body: some View {
        Button{
            action()
        } label: {
            HStack{
                if let icon = iconImage {
                    Image(systemName: icon)
                }
                Text(text)
            }
            .font(.system(size: 20))
            .fontWeight(.semibold)
            .foregroundColor(disabled ? .gray : .black)
            .padding()
            .frame(maxWidth: .infinity, minHeight: 50)
            .background(disabled ? gradientDisabled : gradientColors)
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .padding(.horizontal, 20)

        }
        .disabled(disabled)
    }
}

#Preview {
    YellowButtonView(disabled: .constant(false), text: "Permitir", iconImage: "person.fill.checkmark"){
        
    }
}
