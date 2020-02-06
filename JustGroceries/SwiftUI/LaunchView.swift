//
//  LaunchView.swift
//  JustGroceries
//
//  Created by PaulLinck on 2/5/20.
//  Copyright © 2020 Paul Linck. All rights reserved.
//

import SwiftUI

struct LaunchView: View {
  @State private var image: Image?
  
  var body: some View {
    VStack {
      Image("LaunchViewImage")
        .resizable()
        .scaledToFill()
        .edgesIgnoringSafeArea(.all)
    }
  }
}

#if DEBUG
struct LaunchView_Previews: PreviewProvider {
  static var previews: some View {
    LaunchView()
  }
}
#endif
