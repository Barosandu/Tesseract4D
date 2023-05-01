//
//  ContentView.swift
//  ObjectsIn4DAritonAlexandru
//
//  Created by Alexandru Ariton on 07.04.2022.
//

import SwiftUI
#if os(iOS)
import UIKit
#endif
import MetalKit

#if os(iOS)
var WIDTH: CGFloat = min(350, min(UIScreen.main.bounds.width - 0, UIScreen.main.bounds.height - 0))
var HEIGHT: CGFloat = min(350, min(UIScreen.main.bounds.width - 0, UIScreen.main.bounds.height - 0))
#elseif os(macOS)

var WIDTH: CGFloat = 700
var HEIGHT: CGFloat = 700
#endif

#if os(iOS)
struct _BlurView: UIViewRepresentable {
    var style: UIBlurEffect.Style = .systemMaterial
    func makeUIView(context: Context) -> UIVisualEffectView {
        return UIVisualEffectView(effect: UIBlurEffect(style: style))
    }
    func updateUIView(_ uiView: UIVisualEffectView, context: Context) {
        uiView.effect = UIBlurEffect(style: style)
    }
}
#elseif os(macOS)
struct _BlurView: NSViewRepresentable {
    func makeNSView(context: Context) -> NSVisualEffectView {
        var a = NSVisualEffectView()
        a.blendingMode = .withinWindow
        return a
    }
    func updateNSView(_ nsView: NSVisualEffectView, context: Context) {
        
    }
}
#endif

struct BlurView: View {
    @Environment(\.colorScheme) var colorScheme
    var body: some View {
        ZStack {
            
            _BlurView()
             
        }
    }
}

prefix operator ^
prefix func ^(rhs: Float) -> CGFloat {
    return CGFloat(rhs)
}

import Foundation
#if os(iOS)
import UIKit
#elseif os(macOS)
import AppKit
#endif
import SwiftUI
import MetalKit
#if os(iOS)
class AnduMTKView: MTKView {
    
}
#elseif os(macOS)

class AnduMTKView: MTKView {
    
}

#endif


struct TintModifier: ViewModifier {
    var color: SIMD4<Float> = [0,1,1,1]
    func body(content: Content) -> some View {
        if #available(iOS 15.0, *) {
            content
#if os(iOS)
                .foregroundColor(Color(uiColor: UIColor(red: ^color[0], green: ^color[1], blue: ^color[2], alpha: ^color[3])))
#endif
//                .background(BlurView().clipShape(RoundedRectangle(cornerRadius: 10)))
                .padding(3)
        } else {
            content
//                .background(BlurView().clipShape(RoundedRectangle(cornerRadius: 10)))
                .padding(3)
        }
    }
}

struct ToggleMod: ViewModifier {
    func body(content: Content) -> some View {
        if #available(iOS 15.0, *), #available(macOS 12.0, *) {
            content.toggleStyle(ButtonToggleStyle())
        } else {
            content
        }
    }
    
    
}

struct HorizontalMenu<MenuContent: View>: View {
    var content: (Int) -> MenuContent
    @State var selection: Int = 0
    var body: some View {
        content(selection)
    }
}

struct HighlightModifier: ViewModifier {
    var condition: () -> Bool
    var color: Color
    func body(content: Content) -> some View {
        ZStack {
            if self.condition() == true {
                content
                    
                    .background(Color.white.clipShape(RoundedRectangle(cornerRadius: 10)).opacity(0.5))
            } else {
                content
            }
        }
    }
}

extension Color {
    init(_ arr: SIMD4<Float>) {
        self = Color(.displayP3, red: Double(arr[0]), green: Double(arr[1]), blue: Double(arr[2]), opacity: Double(arr[3]))
    }
}


infix operator %==
func %== (lhs: Float, rhs: Float) -> Bool {
    if abs(fmod(lhs, 360)) == rhs {
        return true
    }
    return false
}

infix operator %!=
func %!= (lhs: Float, rhs: Float) -> Bool {
    if abs(fmod(lhs, 360)) == rhs {
        return false
    }
    return true
}

struct SelectiveRoundedRectangle: Shape {
    var cornerRadius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners
    init(cornerRadius: CGFloat, rounding corners: UIRectCorner) {
        self.cornerRadius = cornerRadius
        self.corners = corners
    }
    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: cornerRadius, height: cornerRadius))
        return Path(path.cgPath)
    }
}


struct ContentView: View {
    var x: Float = 0.0
    var xypointer: UnsafeMutablePointer<Float>!
    @Environment(\.colorScheme) var colorScheme
    @State var isLandscape = false
    @EnvironmentObject var matrixPublisher: MatrixPublisher
    @State var inputVars = false
    var sliderViews: some View {
        HStack {
            
            SliderViews(inputVars: self.$inputVars)
                
            
        }
    }
    var FRAMEWIDTH: CGFloat = 43
    
    func resetCoordinates(transformation: Bool, rotation: Bool) {
        self.matrixPublisher.matrix[2] = [0, 0, -3, 0]
        self.matrixPublisher.matrix[0] = [0, 0, 0, 1]
        self.matrixPublisher.matrix[1] = [0, 0, 0, 0]
    }
    @ViewBuilder
    private var pickerViewItems: some View {
        Button(action: {
            self.matrixPublisher.primitive = .cube
        }) {
            Image(systemName: "cube")
                .padding(10)
            //                            .background(Color.black.opacity(0.3).clipShape(Circle()))
        }
        .buttonStyle(PlainButtonStyle())
        .modifier(HighlightModifier(condition: {self.matrixPublisher.primitive == .cube}, color: Color(self.matrixPublisher.color)))
        Button(action: {
            self.matrixPublisher.primitive = .box
        }) {
            Image(systemName: "shippingbox")
                .padding(10)
            //                            .background(Color.black.opacity(0.3).clipShape(Circle()))
        }
        .buttonStyle(PlainButtonStyle())
        .modifier(HighlightModifier(condition: {self.matrixPublisher.primitive == .box}, color: Color(self.matrixPublisher.color)))
        Button(action: {
            self.matrixPublisher.primitive = .sphere
        }) {
            Image(systemName: "rotate.3d")
                .padding(10)
            //                            .background(Color.black.opacity(0.3).clipShape(Circle()))
        }
        .buttonStyle(PlainButtonStyle())
        .modifier(HighlightModifier(condition: {self.matrixPublisher.primitive == .sphere}, color: Color(self.matrixPublisher.color)))
        Button(action: {
            self.matrixPublisher.primitive = .smoothBox
        }) {
            Image(systemName: "shippingbox.fill")
                .padding(10)
            //                            .background(Color.black.opacity(0.3).clipShape(Circle()))
        }
        .buttonStyle(PlainButtonStyle())
        .modifier(HighlightModifier(condition: {self.matrixPublisher.primitive == .smoothBox}, color: Color(self.matrixPublisher.color)))
        Button(action: {
            self.matrixPublisher.primitive = .smoothCube
        }) {
            Image(systemName: "cube.fill")
                .padding(10)
            //                            .background(Color.black.opacity(0.3).clipShape(Circle()))
        }
        .buttonStyle(PlainButtonStyle())
        .modifier(HighlightModifier(condition: {self.matrixPublisher.primitive == .smoothCube}, color: Color(self.matrixPublisher.color)))
        
        Button(action: {
            self.matrixPublisher.primitive = .torus
        }) {
            Image(systemName: "torus")
                .padding(10)
            //                            .background(Color.black.opacity(0.3).clipShape(Circle()))
        }
        .buttonStyle(PlainButtonStyle())
        .modifier(HighlightModifier(condition: {self.matrixPublisher.primitive == .torus}, color: Color(self.matrixPublisher.color)))
        
        
    }
    @ViewBuilder
    var pickerView: some View {
        if self.isLandscape && (self.horizontalSizeClass != .compact || UIDevice.current.userInterfaceIdiom == .phone)  {
            ScrollView(.vertical, showsIndicators: false) {
                VStack {
                    self.pickerViewItems
                }
            }.modifier(TintModifier(color: [1,1,1,1]))
        } else {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack {
                    self.pickerViewItems
                }
            }.modifier(TintModifier(color: [1,1,1,1]))
            
        }
//        HStack {
//            VStack {
//                ScrollView(self.isLandscape ? .vertical : .horizontal, showsIndicators: false) {
//                    if self.isLandscape && (self.horizontalSizeClass != .compact || UIDevice.current.userInterfaceIdiom == .phone) {
//                        VStack {
//                            Spacer(minLength: 20)
//                            self.pickerViewItems
//
//                        }
//                    } else {
//                        VStack {
////                            Spacer()
//                            HStack {
//                                self.pickerViewItems
//                            }
//                        }
//                    }
//                }
//#if os(macOS)
//
//                .padding(5)
//                .menuStyle(BorderlessButtonMenuStyle(showsMenuIndicator: true))
//
//#else
//                .font(.system(size: 13))
//
//#endif
//                .modifier(TintModifier(color: [1,1,1,1]))
//
//
//            }
//
//        }
//        .padding(1)
////        .background(Color(.systemBlue))
            
    }
    
    var valuesView: some View {
        HStack {
            VStack(alignment: .leading, spacing: 5) {
                    HStack {
                        Image(systemName: "rotate.3d")
                        Text("YZ: \(String(format: "%.0f", self.matrixPublisher.matrix[0].x)) ")
                            //.frame(width: FRAMEWIDTH, alignment: .leading)
                            
                        Text("ZX: \(String(format: "%.0f", self.matrixPublisher.matrix[0].y)) ")//.frame(width: FRAMEWIDTH, alignment: .leading)
                        Text("XY: \(String(format: "%.0f", self.matrixPublisher.matrix[0].z)) ")//.frame(width: FRAMEWIDTH, alignment: .leading)
                        Text("WX: \(String(format: "%.0f", self.matrixPublisher.matrix[1].x)) ")//.frame(width: FRAMEWIDTH, alignment: .leading)
                        Text("WY: \(String(format: "%.0f", self.matrixPublisher.matrix[1].y)) ")//.frame(width: FRAMEWIDTH, alignment: .leading)
                        Text("WZ: \(String(format: "%.0f", self.matrixPublisher.matrix[1].z)) ")//.frame(width: FRAMEWIDTH, alignment: .leading)
                    }
                
                    HStack {
                        Image(systemName: "cube.fill")
                        Text("X: \(String(format: "%.2f", self.matrixPublisher.matrix[2].x)) ")//.frame(width: FRAMEWIDTH, alignment: .leading)
                        Text("Y: \(String(format: "%.2f", self.matrixPublisher.matrix[2].y)) ")//.frame(width: FRAMEWIDTH, alignment: .leading)
                        Text("Z: \(String(format: "%.2f", self.matrixPublisher.matrix[2].z)) ")//.frame(width: FRAMEWIDTH, alignment: .leading)
                        
                        Text("W: \(String(format: "%.2f", self.matrixPublisher.matrix[2].w)) ")//.frame(width: FRAMEWIDTH, alignment: .leading)
                        
                    }
            }
            
            .font(.system(size: 9))
            .padding(3)
            .background(BlurView().clipShape(RoundedRectangle(cornerRadius: 10)))
            .padding(3)
            Spacer()
        }
    }
    
    var primitiveRawValues = ["Tesseract", "4D Box", "4D Sphere", "Rounded 4D Box", "Torus", "Rounded Tesseract", "Sphere - Cube", "Cube - Torus"]
    
    @State var showInfoSheet = false
    var helpButton: some View {
        Button {
            self.showInfoSheet = true
        } label: {
            Image(systemName: "questionmark.circle.fill")
                .foregroundColor(.white)
                .padding(5)
                .background(Color.blue)
                .clipShape(Circle())
                .padding()
        }.buttonStyle(.plain)
            .sheet(isPresented: self.$showInfoSheet) {
                NavigationView {
                    InfoView()
                        .navigationBarTitleDisplayMode(.inline)
                        .navigationBarItems(leading:
                        Button {
                            self.showInfoSheet = false
                        } label: {
                            Text("Close")
                        }
                                        
                        )
                }
            }
    }
    
    @State var widthMic: CGFloat = 350
    @State var heightMic: CGFloat = 350
    
    var tesseractView: some View {
        VStack {

            
            ZStack(alignment: .center) {
                    
                
                if !self.showInfoSheet {
                    GeometryReader { geoReader in
                    TesseractView(matrixPublisher: self._matrixPublisher)
                        .frame(width: WIDTH - 10, height: HEIGHT - 10, alignment: .center)
                        .fixedSize()
                        .frame(width: geoReader.size.width, height: geoReader.size.height, alignment: .center)
                        .clipped()
                    }

                }


                HStack {
                    VStack() {
                        self.valuesView
                        Spacer()

                    }
                    Spacer()
                }
                //.frame(width: WIDTH - 10, height: HEIGHT - 10, alignment: .center)
//                .frame(maxWidth: WIDTH - 10, maxHeight: HEIGHT - 10)
                VStack {
                    Spacer()
                    Picker(selection: self.$matrixPublisher.primitive) {
                        ForEach([0,1,2,3,5,4], id: \.self) { ind in
                            Text(primitiveRawValues[ind])
                                .tag(Primitives(rawValue: ind) ?? .cube)
                        }
                    } label: {

                        Text("Choose")
                    }
                    .padding(5)
                    .background(BlurView())
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .padding(5)
                }
                //.frame(width: WIDTH - 10, height: HEIGHT - 10, alignment: .center)
//                .frame(maxWidth: WIDTH - 10, maxHeight: HEIGHT - 10)
                HStack {
                    VStack() {
                        Spacer()
                        self.helpButton


                    }
                    Spacer()
                }
//                .frame(maxWidth: WIDTH - 10, maxHeight: HEIGHT - 10)
                //.frame(width: WIDTH - 10, height: HEIGHT - 10, alignment: .center)

            }
            
                .frame(minWidth: 200, maxWidth: WIDTH - 10, minHeight: 200, maxHeight: HEIGHT - 10, alignment: .center)
                .clipShape(RoundedRectangle(cornerRadius: 10))
            //    .background(.blue)
            
            
        }
        .onAppear {
            if self.colorScheme == .dark {
                self.matrixPublisher.color = [1,0,0,1]

            } else if self.colorScheme == .light {
                self.matrixPublisher.color = [0,0,0,1]

            }
        }
    }
    @State var test: Float = 0
    var colorView: some View {
        VStack {
            
            HStack {
                HStack(spacing: 0) {
                    Color(.displayP3, red: 1, green: 0, blue: 0, opacity: 1)
                        .onTapGesture {
                            self.matrixPublisher.color = [1, 0, 0, 1]
                        }
                    Color(.displayP3, red: 1, green: 0.5, blue: 0, opacity: 1)
                        .onTapGesture {
                            self.matrixPublisher.color = [1, 0.5, 0, 1]
                        }
                    Color(.displayP3, red: 1, green: 1, blue: 0, opacity: 1)
                        .onTapGesture {
                            self.matrixPublisher.color = [1, 1, 0, 1]
                        }
                    Color(.displayP3, red: 0, green: 1, blue: 0, opacity: 1)
                        .onTapGesture {
                            self.matrixPublisher.color = [0, 1, 0, 1]
                        }
                    
                    Color(.displayP3, red: 0, green: 1, blue: 1, opacity: 1)
                        .onTapGesture {
                            self.matrixPublisher.color = [0, 1, 1, 1]
                        }
                    Color(.displayP3, red: 0, green: 0, blue: 1, opacity: 1)
                        .onTapGesture {
                            self.matrixPublisher.color = [0, 0, 1, 1]
                        }
                    
                    Color(.displayP3, red: 1, green: 1, blue: 1, opacity: 1)
                        .onTapGesture {
                            self.matrixPublisher.color = [1, 1, 1, 1]
                        }
                }
                .frame(height: 30, alignment: .center)
#if os(macOS)
                .frame(width: WIDTH)
#elseif os(iOS)
                .frame(width: WIDTH - 10)
#endif
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .padding(.horizontal)
                
            }
            .clipShape(RoundedRectangle(cornerRadius: 10))
        }
    }
    
    @State var showSliderViewsForSmallScreens = false
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    
    
    @ViewBuilder var backgroundColor: some View {
        if self.colorScheme == .dark {
            Color.black
        } else if self.colorScheme == .light {
            Color(.systemGray6)
        }
    }
    
    @ViewBuilder var compactViewPhonePortrait: some View {
        
        ZStack {
            Color(.systemBlue).edgesIgnoringSafeArea(.all)
            VStack {
                ZStack {
                    self.backgroundColor
                        .clipShape(SelectiveRoundedRectangle(cornerRadius: 20, rounding: [.bottomLeft, .bottomRight]))
                        .edgesIgnoringSafeArea(.all)
                    VStack {
                        self.tesseractView
                        Spacer()
                        self.sliderViews
                    }
                }
                Spacer()
                self.pickerView
                Spacer()
            }
        }
    }
    
    @ViewBuilder var compactViewPhoneLandscape: some View {
        ZStack {
            Color(.systemBlue).edgesIgnoringSafeArea(.all)
            HStack {
                self.pickerView
                ZStack {
                    self.backgroundColor
                        .clipShape(SelectiveRoundedRectangle(cornerRadius: 20, rounding: [.bottomLeft, .topLeft]))
                        .edgesIgnoringSafeArea(.all)
                    HStack {
                        self.tesseractView
                            .padding(5)
                        Spacer()
                        self.sliderViews
                    }
                }
                
                
            }
        }
    }
    
    @ViewBuilder var compactViewPhone: some View {
        VStack {
            if !self.isLandscape {
                self.compactViewPhonePortrait
            } else if self.isLandscape {
                self.compactViewPhoneLandscape
            }
        }
    }
    
    @ViewBuilder var regularViewIPadLandscape: some View {
        ZStack {
            Color(.systemBlue).edgesIgnoringSafeArea(.all)
            HStack {
                self.pickerView
                ZStack {
                    self.backgroundColor
                        .clipShape(SelectiveRoundedRectangle(cornerRadius: 20, rounding: [.bottomLeft, .topLeft]))
                        .edgesIgnoringSafeArea(.all)
                    HStack {
                        
                        InfoView()
                            .padding()
                            .background(self.secondBackgroundColor.clipShape(RoundedRectangle(cornerRadius: 20)))
                            .padding()
                        Spacer()
                        VStack {
                            self.tesseractView
                            Spacer()
                            self.sliderViews
                        }
                    }
                }
                
                
            }
        }
    }
    
    @ViewBuilder var secondBackgroundColor: some View {
        if self.colorScheme == .dark {
            Color(.systemGray6)
        } else if self.colorScheme == .light {
            Color.white
        }
    }
    
    @ViewBuilder var regularViewIPadPortrait: some View {
        ZStack {
            Color(.systemBlue).edgesIgnoringSafeArea(.all)
            VStack {
                ZStack {
                    self.backgroundColor
                        .clipShape(SelectiveRoundedRectangle(cornerRadius: 20, rounding: [.bottomLeft, .bottomRight]))
                        .edgesIgnoringSafeArea(.all)
                    VStack {
                        self.tesseractView
                        Spacer()
                        self.sliderViews
                        InfoView()
                            .padding()
                            .background(self.secondBackgroundColor.clipShape(RoundedRectangle(cornerRadius: 20)))
                            .padding()
                    }
                }
                
                self.pickerView
            }
        }
    }
    
    @ViewBuilder var regularViewIPad: some View {
        if self.isLandscape {
            self.regularViewIPadLandscape
        } else {
            self.regularViewIPadPortrait
        }
    }
    
    var body: some View {
#if os(iOS)
        
        Group {
            
            if self.horizontalSizeClass == .compact {
                if UIDevice.current.userInterfaceIdiom == .phone {
                    self.compactViewPhone
                } else if UIDevice.current.userInterfaceIdiom == .pad {
                    self.compactViewPhonePortrait
                }
            } else if self.horizontalSizeClass == .regular {
                if UIDevice.current.userInterfaceIdiom == .phone {
                    self.compactViewPhone
                } else {
                    self.regularViewIPad
                }
            }
        }
//
//        .background((self.colorScheme == .dark ? Color(.systemGray6) : Color(.systemGray6)))
            .onReceive(NotificationCenter.default.publisher(for: UIDevice.orientationDidChangeNotification)) { _ in
                guard let scene = UIApplication.shared.windows.first?.windowScene else { return }
                self.isLandscape = scene.interfaceOrientation.isLandscape
                if !self.isLandscape {
                    //   self.isLeftLandscape = false
                }
                /*
                 if scene.interfaceOrientation == .landscapeLeft {
                 self.isLeftLandscape = true
                 } else {
                 self.isLeftLandscape = false
                 }*/
            }
            .onChange(of: self.colorScheme) { newValue in
                if newValue == .dark {
                    self.matrixPublisher.color = [1,0,0,1]
                } else if newValue == .light {
                    self.matrixPublisher.color = [0,0,0,1]
                }
            }
            
            
#elseif os(macOS)
        NavigationView {
            self.sliderViews
                .frame(minWidth: 350)
            VStack {
                Spacer()
                self.tesseractView
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                
                    .buttonStyle(PlainButtonStyle())
                    .padding()
               
                Spacer()
            }
            
        }
        
        //  .background(VisualEffectView(material: .sidebar, blendingMode: .behindWindow))
        .edgesIgnoringSafeArea(.all)
#endif
    }
}

#if os(iOS)
struct TesseractView: UIViewControllerRepresentable {
    @EnvironmentObject public var matrixPublisher: MatrixPublisher
    
    func makeUIViewController(context: Context) -> UITesseractGameViewController {
        var a = UITesseractGameViewController()
        
        a.setMatrixPublisher(self._matrixPublisher)
        return a;
    }
    
    func updateUIViewController(_ uiViewController: UITesseractGameViewController, context: Context) {
        
    }
    
    typealias UIViewControllerType = UITesseractGameViewController
}
#elseif os(macOS)

struct TesseractView: NSViewControllerRepresentable {
    @EnvironmentObject public var matrixPublisher: MatrixPublisher
    
    func makeNSViewController(context: Context) -> UITesseractGameViewController {
        var a = UITesseractGameViewController()
        a.setMatrixPublisher(self._matrixPublisher)
        return a;
    }
    
    func updateNSViewController(_ uiViewController: UITesseractGameViewController, context: Context) {
        
    }
    
    typealias NSViewControllerType = UITesseractGameViewController
}
#endif

#if os(iOS)
typealias XViewController = UIViewController
typealias XColor = UIColor
typealias XList = List
#elseif os(macOS)
typealias XViewController = NSViewController
typealias XColor = NSColor
typealias XList = ScrollView
#endif


class UITesseractGameViewController: XViewController {
    @EnvironmentObject var matrixPublisher: MatrixPublisher
    func setMatrixPublisher(_ mp: EnvironmentObject<MatrixPublisher>) {
        self._matrixPublisher = mp
    }
    var renderer: Renderer!
    var mtkView: MTKView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mtkView = AnduMTKView(frame: CGRect(x: 0, y: 0, width: WIDTH - 10, height: HEIGHT - 10))
#if os(iOS)
        mtkView.backgroundColor = XColor.black
#endif
        let mdevice = MTLCreateSystemDefaultDevice()
        mtkView.device = mdevice
        renderer = Renderer()
        renderer.setMatrixPublisher(self._matrixPublisher)
        mtkView.framebufferOnly = false
        mtkView.delegate = renderer
        self.view.addSubview(mtkView)
        self.mtkView.topAnchor.constraint(equalTo: self.view.topAnchor).isActive = true
        self.mtkView.centerYAnchor.constraint(equalTo: self.view.centerYAnchor).isActive = true
    }
    
    override func loadView() {
        self.view = AnduMTKView(frame: CGRect(x: 0, y: 0, width: WIDTH - 10, height: HEIGHT - 10))
    }
}

class TabTransformSelection: ObservableObject {
    @Published var selection: Int
    init(selection: Int) {
        self.selection = selection
    }
}

struct SliderViews: View {
    @EnvironmentObject var matrixPublisher: MatrixPublisher
    @Binding var inputVars: Bool
    
    @ViewBuilder
    var toggleViews: some View {
        Group {
        
            Section(header: HStack {
                Image(systemName: "rotate.3d")
                Text("Rotation")
            }) {
                
                HStack {
                    
                    Toggle(isOn: self.$matrixPublisher.booleanMatrix[1][0], label: {
                        Text("XY")
                    })
                    .modifier(ToggleMod())
                    
                }
                HStack {
                    
                    Toggle(isOn: self.$matrixPublisher.booleanMatrix[1][1], label: {
                        Text("YZ")
                    })
                    .modifier(ToggleMod())
                }
                
                HStack {
                    Toggle(isOn: self.$matrixPublisher.booleanMatrix[1][2], label: {
                        Text("ZX")
                    }).modifier(ToggleMod())
                }
                
                HStack {
                    Toggle(isOn: self.$matrixPublisher.booleanMatrix[2][0], label: {
                        Text("WX")
                    }).modifier(ToggleMod())
                        
                }
                
                HStack {
                    Toggle(isOn: self.$matrixPublisher.booleanMatrix[2][1], label: {
                        Text("WY")
                    }).modifier(ToggleMod())
                        
                }
                
                HStack {
                    Toggle(isOn: self.$matrixPublisher.booleanMatrix[2][2], label: {
                        Text("WZ")
                    }).modifier(ToggleMod())

                }
                
                
                
            }
        
        Section(header: HStack {
            Image(systemName: "cube.fill")
            Text("Transformation")
            
        }) {
            HStack {
                Toggle(isOn: self.$matrixPublisher.booleanMatrix[0][0], label: {
                    Text("X")
                }).modifier(ToggleMod())
                    
            }
            
            HStack {
                Toggle(isOn: self.$matrixPublisher.booleanMatrix[0][1], label: {
                    Text("Y")
                }).modifier(ToggleMod())
                   
            }
            
            HStack {
                Toggle(isOn: self.$matrixPublisher.booleanMatrix[0][2], label: {
                    Text("Z")
                }).modifier(ToggleMod())
                    
            }
                HStack {
                    Toggle(isOn: self.$matrixPublisher.booleanMatrix[0][3], label: {
                        Text("W")
                    }).modifier(ToggleMod())
                        
                }
            
        }
        }
    }
    
    @StateObject var tabViewSelection = TabTransformSelection(selection: 3);
    
    var tabViewNames = ["Rotation", "W Rotation", "Transform", "Auto"]
    
    @Environment(\.colorScheme) var colorScheme
    
    @ViewBuilder var backgroundColor: some View {
        if self.colorScheme == .dark {
            Color(.systemGray5)
        } else {
            Color(.white)
        }
    }
    
    @ViewBuilder var highlightedBackgroundColor: some View {
        Color(.systemBlue)
    }
    
    @ViewBuilder var secondBackgroundColor: some View {
        if self.colorScheme == .dark {
            Color(.systemGray5)
        } else {
            Color(.systemGray5)
        }
    }
    
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    
    @ViewBuilder
    var sliderViews: some View {
        VStack {
            HStack {
                HStack(spacing: 2) {
                     
                        ForEach(0..<4) { ind in
                            Button {
                                self.tabViewSelection.selection = ind
                            } label: {
                                Text(tabViewNames[ind])
                                    .padding(5)
                                    .foregroundColor(
                                        self.tabViewSelection.selection == ind ? Color.white : Color(.systemBlue)
                                        
                                    )
                                    .background(
                                        Group {
                                            if self.tabViewSelection.selection == ind {
                                                self.highlightedBackgroundColor.cornerRadius(10)
                                            } else {
                                                self.backgroundColor.cornerRadius(10)
                                            }
                                        }
                                    )
                                    .font(.system(size: self.horizontalSizeClass != .compact && UIDevice.current.userInterfaceIdiom == .pad ? 20 : 13))
                            }
                        }
                    
                }
                .padding(2)
                .background(
                    self.colorScheme == .dark ? Color(.systemGray6) : Color(.white).opacity(0.5)
                )
                .clipShape(RoundedRectangle(cornerRadius: 10))
            }
            
            ScrollView {
                Group {
                if true {
    #if os(iOS)
                    
                    VStack {
                        Section(header: HStack {
                            Image(systemName: "rotate.3d")
                            Text("Rotation")
                        }) {
                            HStack {
    #if os(iOS)
                                Text("YZ")
    #endif
                                CustomSliderView(value: self.$matrixPublisher.matrix[0].x, in: 0...360) {
                                    Text("YZ")
                                }
                            }
                            HStack {
    #if os(iOS)
                                Text("ZX")
    #endif
                                CustomSliderView(value: self.$matrixPublisher.matrix[0].y, in: 0...360) {
                                    Text("ZX")
                                }
                            }
                            HStack {
    #if os(iOS)
                                Text("XY")
    #endif
                                CustomSliderView(value: self.$matrixPublisher.matrix[0].z, in: 0...360) {
                                    Text("XY")
                                }
                            }
                        }
                        Text("Modify the object's rotation by using the sliders")
                            .foregroundColor(Color(UIColor.secondaryLabel))
                        Spacer()
                    }
    //                .padding()
                    
                    .shown(tabViewSelection.selection == 0)
                    VStack {
                        Section(header: HStack {
                            Image(systemName: "circle")
                            Text("W Rotation")
                        }) {
                            HStack {
    #if os(iOS)
                                Text("WX")
    #endif
                                CustomSliderView(value: self.$matrixPublisher.matrix[1].x, in: 0...360) {
                                    Text("WX")
                                }
                            }
                            HStack {
    #if os(iOS)
                                Text("WY")
    #endif
                                CustomSliderView(value: self.$matrixPublisher.matrix[1].y, in: 0...360) {
                                    Text("WY")
                                }
                            }
                            
                            HStack {
    #if os(iOS)
                                Text("WZ")
    #endif
                                CustomSliderView(value: self.$matrixPublisher.matrix[1].z, in: 0...360) {
                                    Text("WZ")
                                }
                            }
                        }
                        Text("Modify the object's W rotation by using the sliders.")
                            .foregroundColor(Color(UIColor.secondaryLabel))
                        Spacer()
                    }
    //                .padding()
                    
                    .shown(tabViewSelection.selection == 1)
    #elseif os(macOS)
                    VStack {
                        Section(header: HStack {
                            Image(systemName: "rotate.3d")
                            Text("Rotation")
                        }) {
                            HStack {
    #if os(iOS)
                                Text("YZ")
    #endif
                                CustomSliderView(value: self.$matrixPublisher.matrix[0].x, in: 0...360) {
                                    Text("YZ")
                                }
                            }
                            HStack {
    #if os(iOS)
                                Text("ZX")
    #endif
                                CustomSliderView(value: self.$matrixPublisher.matrix[0].y, in: 0...360) {
                                    Text("ZX")
                                }
                            }
                            HStack {
    #if os(iOS)
                                Text("XY")
    #endif
                                CustomSliderView(value: self.$matrixPublisher.matrix[0].z, in: 0...360) {
                                    Text("XY")
                                }
                            }
                        }
                        Section(header: HStack {
                            Image(systemName: "circle")
                            Text("W Rotation")
                        }) {
                            HStack {
    #if os(iOS)
                                Text("WX")
    #endif
                                CustomSliderView(value: self.$matrixPublisher.matrix[1].x, in: 0...360) {
                                    Text("WX")
                                }
                            }
                            HStack {
    #if os(iOS)
                                Text("WY")
    #endif
                                CustomSliderView(value: self.$matrixPublisher.matrix[1].y, in: 0...360) {
                                    Text("WY")
                                }
                            }
                            
                            HStack {
    #if os(iOS)
                                Text("WZ")
    #endif
                                CustomSliderView(value: self.$matrixPublisher.matrix[1].z, in: 0...360) {
                                    Text("WZ")
                                }
                            }
                        }
                        Text("Modify the object's rotation and W rotation by using the sliders")
                            .foregroundColor(Color(UIColor.secondaryLabel))
                        Spacer()
                        
                    }
    //                .padding()
                    
                    .shown(tabViewSelection.selection == 0)
    #endif
                    
                }
                VStack {
                    Section(header: HStack {
                        Image(systemName: "cube.fill")
                        Text("Transformation")
                        
                    }) {
                        HStack {
    #if os(iOS)
                            Text("X")
    #endif
                            CustomSliderView(value: self.$matrixPublisher.matrix[2].x, in: -1...1) {
                                Text("X")
                            }
                        }
                        HStack {
    #if os(iOS)
                            Text("Y")
    #endif
                            CustomSliderView(value: self.$matrixPublisher.matrix[2].y, in: -1...1) {
                                Text("Y")
                            }
                        }
                        HStack {
    #if os(iOS)
                            Text("Z")
    #endif
                            CustomSliderView(value: self.$matrixPublisher.matrix[2].z, in: -4...(-2)) {
                                Text("Z")
                            }
                        }
                        HStack {
                            
#if os(iOS)
                            Text("W")
#endif
                            CustomSliderView(value: self.$matrixPublisher.matrix[2].w, in: -1...1) {
                                Text("W")
                            }
                            
                        }
                        
                    }
                    Text("Modify the object's transformation by using the sliders")
                        .foregroundColor(Color(UIColor.secondaryLabel))
                    Spacer()
                }
    //            .padding()
                
                .shown(tabViewSelection.selection == 2)
                
                VStack {
                    VStack {
                        
                        LazyVGrid(columns: [GridItem(.adaptive(minimum: 70, maximum: 100))]) {
                            self.toggleViews
                        }
                        Text("Toggle the rotation and transformation of the object by pressing the buttons")
                            .foregroundColor(Color(UIColor.secondaryLabel))
                        Spacer()
                    }
                }
    //            .padding()
                .shown(tabViewSelection.selection == 3)
                }
            }
            
        }
        
//        .background(.red)
//        .tabViewStyle(PageTabViewStyle())
        .onChange(of: self.tabViewSelection.selection, perform: { newValue in
            if newValue == 3 {
                self.inputVars = false
            } else {
                self.inputVars = true
            }
            matrixPublisher.matrix[0].w = self.inputVars ? 1 : 0
        })
        
        .onAppear {
            if self.tabViewSelection.selection == 3 {
                self.inputVars = false
            } else {
                self.inputVars = true
            }
            matrixPublisher.matrix[0].w = self.inputVars ? 1 : 0
        }
        
#if os(macOS)
        .padding()
#endif
        //.background(Color(.systemGray6).clipShape(RoundedRectangle(cornerRadius: 10)))
        
        
        
    }
    
    
    var body: some View {
        
        VStack {
            
                self.sliderViews
            
//                .scaleEffect(0.9)
        }
        .background(
            self.colorScheme == .dark ? Color.black : Color(.systemGray6)
        
        )
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .padding(5)
        
        //.clipShape(RoundedRectangle(cornerRadius: 10))
        
    }
}


extension View {
    @ViewBuilder func hidden(_ condition: Bool) -> some View {
        if(!condition) {
            self
        }
    }
    
    @ViewBuilder func shown(_ condition: Bool) -> some View {
        if(condition) {
            self
        }
    }
}

struct ListMod: ViewModifier {
    func body(content: Content) -> some View {
#if os(iOS)
        content
            .listStyle(InsetGroupedListStyle())
        
            .padding(.top, 10)
            .background(Color.clear)
#elseif os(macOS)
        content
        //.listStyle(InsetGroupedListStyle())
        
            .padding(.top, 10)
            .background(Color.clear)
#endif
    }
    
    
}

#if os(macOS)
struct VisualEffectView: NSViewRepresentable
{
    let material: NSVisualEffectView.Material
    let blendingMode: NSVisualEffectView.BlendingMode
    
    func makeNSView(context: Context) -> NSVisualEffectView
    {
        let visualEffectView = NSVisualEffectView()
        visualEffectView.material = material
        visualEffectView.blendingMode = blendingMode
        visualEffectView.state = NSVisualEffectView.State.active
        return visualEffectView
    }
    
    func updateNSView(_ visualEffectView: NSVisualEffectView, context: Context)
    {
        visualEffectView.material = material
        visualEffectView.blendingMode = blendingMode
    }
}
#endif
