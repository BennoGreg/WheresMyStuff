//
//  CustomViewModifier.swift
//  WhereIsMyStuff
//
//  Created by Benedikt Langer on 07.10.21.
//  Copyright © 2021 Benedikt. All rights reserved.
//

import SwiftUI

@available(iOS 14, *)
struct ToolbarModifier<T: View>: ViewModifier {
    var view: T
    
    func body(content: Content) -> some View {
        content.toolbar {
            view
        }
    }
}

struct NavigationBarItemModifier<T: View>: ViewModifier {
    var leadingView: T?
    var trailingView: T?
    
    func body(content: Content) -> some View {
        if let leadingView = leadingView {
            content.navigationBarItems(leading: leadingView)
        }
        if let trailingView = trailingView {
            content.navigationBarItems(trailing: trailingView)
        }
    }
}

extension View {
    
    @ViewBuilder
    func adaptiveNavigationBarItem<T: View>(with item: @escaping () -> T, trailing: Bool = true) -> some View {
        if #available(iOS 14, *) {
            self.modifier(ToolbarModifier(view: item()))
        } else {
            if trailing {
                self.modifier(NavigationBarItemModifier(trailingView: item()))
            } else {
                self.modifier(NavigationBarItemModifier(leadingView: item()))
            }
        }
    }
    
}
