//
//  ContentView.swift
//  Dots
//
//  Created by Jack Zhao on 1/8/21.
//

import SwiftUI

struct ContentView: View {
    @Binding var mainData: DotsData
    @Environment(\.scenePhase) private var scenePhase
    let saveAction: () -> Void

    var body: some View {
        Text("Hello, world!")
            .padding()
            .onChange(of: scenePhase) { phase in
                if phase == .inactive {
                    saveAction()
                }
            }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {

        ContentView(mainData: .constant(DotsData.sample), saveAction: {})

    }
}