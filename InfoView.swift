//
//  File.swift
//  ObjectsIn4DAritonAlexandru
//
//  Created by Alexandru Ariton on 07.04.2022.
//

import Foundation
import SwiftUI

#if os(iOS)
import UIKit
#endif

extension View {
    @ViewBuilder func leftParagraph() -> some View {
        HStack {
            self
            Spacer()
        }
    }
}

struct InfoView: View {
    @Environment(\.colorScheme) var colorScheme
    var body: some View {
        ScrollView {
            LazyVStack {
            Text("About this app")
                .font(.title)
                .bold()
                .padding()
            LazyVStack(alignment: .leading, spacing: 10) {
                Text("This app presents 3D sections of 4D objects. It's what a 3D being would see if a 4D object were to cross in its dimension.")
                
                Text("3D Analogy")
                    .font(.title)
                    .leftParagraph()
                
                Text("Imagine you were a ") +
                Text("2D square ").bold().foregroundColor(.blue) +
                Text(Image(systemName: "square")).bold().foregroundColor(.blue) +
                Text(" moving in 2D, on an ") +
                Text("X Axis").foregroundColor(.blue) +
                Text(" and a ") +
                Text("Y Axis").foregroundColor(.blue)
                
                Text("If a ") +
                Text("3D Sphere ").bold().foregroundColor(.blue) +
                Text(Image(systemName: "rotate.3d")).bold().foregroundColor(.blue) +
                Text(" were to cross into the Square's plane, the Square would see a ") +
                Text("dissappearing and reappearing circle which changes its size.")
                
                Text("The same would happen when a 4D being crosses into our 3D space. We would see an irregular 3D shape")
                
                Text("How to use the app")
                    .font(.title)
                    .leftParagraph()
                
                
                Text("You can move the object using the sliders in the ") +
                Text("Rotation, W Rotation ").foregroundColor(.blue) +
                Text("and ") +
                Text("Transform").foregroundColor(.blue) + Text(" tab, ")
                Text("or you can do it using the toggles in the ") +
                Text("Auto ").foregroundColor(.blue) +
                Text("tab.")
                
                Text("You can change the object by clicking one of the icons in the bottom of the screen, or in the left if you are in landscape.")
            }
            }.padding(.horizontal)
        }
    }
}

struct CustomSliderView<Content: View>: View {
    
    @Binding var sliderValue: Float
    var range: ClosedRange<Float>
    var cnt: () -> Content
    init(value: Binding<Float>, in range: ClosedRange<Float>, label: @escaping () -> Content) {
        self._sliderValue = value
        self.range = range
        self.cnt = label
    }
    
    init(value: Binding<Float>, in range: ClosedRange<Int>, label: @escaping () -> Content) {
        self._sliderValue = value
        self.range = Float(range.lowerBound)...Float(range.upperBound)
        self.cnt = label
    }
    var body: some View {
        Slider(value: self.$sliderValue, in: range)
    }
}

