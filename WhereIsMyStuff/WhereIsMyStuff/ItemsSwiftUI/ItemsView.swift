//
//  ItemsView.swift
//  WhereIsMyStuff
//
//  Created by Benedikt Langer on 20.09.21.
//  Copyright © 2021 Benedikt. All rights reserved.
//

import SwiftUI

struct ItemsView: View {
    
    let mockData = ItemLocationClass.instance.loadMockData()
    
    var body: some View {
        NavigationView{
            VStack {
                List(0..<mockData.1.count) { index in
                    Section(header: Text(mockData.1[index]).bold()) {
                        ForEach(mockData.0[index]) { itemLocation in
                            HStack{
                                Text(itemLocation.item?.itemName ?? "Not available")
                                Spacer()
                                Text("\(itemLocation.amount) Piece(s)")
                            }
                        }
                    }
                }
            }
            .navigationBarTitle("Items", displayMode: .inline).adaptiveNavigationBarItem(with: {
                Button("Next") {
                    print("clicked Next")
                }
            })
        }
    
    }
    
}

struct ItemsView_Previews: PreviewProvider {
    static var previews: some View {
        ItemsView()
    }
}
