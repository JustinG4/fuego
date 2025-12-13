//
//  FuegoWidgetBundle.swift
//  FuegoWidget
//
//  Created by Justin Greenfield on 12/11/25.
//

import WidgetKit
import SwiftUI

@main
struct FuegoWidgetBundle: WidgetBundle {
    var body: some Widget {
        FuegoWidget()
        FuegoWidgetControl()
        FuegoWidgetLiveActivity()
    }
}
