//
//  DismissKeyboard.swift
//  CurrencyExchange
//
//  Created by Artem Manakov on 10.12.2022.
//

import Foundation
import SwiftUI

extension View {
    func dissmisKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
