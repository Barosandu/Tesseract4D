import SwiftUI
import MetalKit

func getInitMak() -> matrix_float3x4 {
    var mak = matrix_float3x4(0)
    mak[2].z = -3
    return mak
}

@main
struct MyApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
//                .preferredColorScheme(.dark)
                .environmentObject(MatrixPublisher(matrix: getInitMak(), primitive: .cube, color: [0, 1, 1, 1], swipeValue: 0.0, power: 2, booleanMatrix: [[false, false, false, false],
                                    [false, false, false, false],
                                    [false, false, false, false],
                                    [false, false, false, false]]))
                
        }
    }
}
