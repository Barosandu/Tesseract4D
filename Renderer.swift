import Foundation
import Combine
import MetalKit
import SwiftUI

enum Primitives: Int {
    case cube = 0
    case box = 1
    case sphere = 2
    case smoothBox = 3
    case torus = 4
    case smoothCube = 5
    case cubeThatTurnsIntoSphere = 6
    case cubeThatTurnsIntoTorus = 7
}

class MatrixPublisher: ObservableObject {
    var didChange = PassthroughSubject<MatrixPublisher, Never>()
    @Published var matrix: matrix_float3x4 {
        didSet {
            didChange.send(self)
        }
    }
    @Published var primitive: Primitives
    @Published var color: SIMD4<Float>
    @Published var swipeValue: Float
    @Published var powerNecalibrat: Float
    @Published var booleanMatrix: [[Bool]]
    
    
    init(matrix: matrix_float3x4, primitive: Primitives, color: SIMD4<Float>, swipeValue: Float, power: Float, booleanMatrix: [[Bool]]) {
        self.matrix = matrix
        self.primitive = primitive
        self.color = color
        self.swipeValue = swipeValue
        self.powerNecalibrat = power
        self.booleanMatrix = booleanMatrix
    }
    
}

infix operator ^%
func ^%(lhs: Float, rhs: Float) -> Float {
    return lhs.truncatingRemainder(dividingBy: rhs)
}

public class Renderer: NSObject, MTKViewDelegate {
    @EnvironmentObject var matrixPublisher: MatrixPublisher
    func setMatrixPublisher(_ mp: EnvironmentObject<MatrixPublisher>) {
        self._matrixPublisher = mp
    }
    public var device: MTLDevice!
    var queue: MTLCommandQueue!
    var computeState: MTLComputePipelineState!
    var time: Float = 0
    var totalMak = matrix_float3x4(SIMD4<Float>(30, 30, 0, 0), // rotation
                                   SIMD4<Float>(0, 0, 0, 0), // wrotation
                                   SIMD4<Float>(0, 0, 0.5, 0)) // transf
    var primitive: Int = Primitives.cube.rawValue
    var color = SIMD4<Float>(0, 1, 1, 1)
    var cosineRotmak: matrix_float2x3!
    
    var timeBuffer: MTLBuffer!
    var totalMakBuffer: MTLBuffer!
    var primitiveBuffer: MTLBuffer!
    var colorBuffer: MTLBuffer!
    
    var resolutionBuffer: MTLBuffer!
    var resolution: Int = 1
    
    
    override public init() {
        super.init()
        registerShaders()
    }
    
    
    func registerShaders() {
        self.device = MTLCreateSystemDefaultDevice()!
        self.queue = device.makeCommandQueue()
        let library = try device.makeDefaultLibrary()!
        let kernel = library.makeFunction(name: "compute")!
        computeState = try! device.makeComputePipelineState(function: kernel)
        timeBuffer = device!.makeBuffer(length: MemoryLayout<Float>.size, options: [])
        totalMakBuffer = device!.makeBuffer(length: MemoryLayout<matrix_float3x4>.size, options: [])
        primitiveBuffer = device!.makeBuffer(length: MemoryLayout<Int>.size, options: [])
        colorBuffer = device!.makeBuffer(length: MemoryLayout<SIMD4<Float>>.size, options: [])
        resolutionBuffer = device!.makeBuffer(length: MemoryLayout<Int>.size, options: [])
        
    }
    
    public func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {}
    var incrementX: Float = 0
    var incrementY: Float = 0
    var incrementZ: Float = 0
    var incrementW: Float = 0
    var swXY: Float = 0;
    var swYZ: Float = 0;
    var swZX: Float = 0;
    var swWX: Float = 0;
    var swWY: Float = 0;
    var swWZ: Float = 0;
    
    var sw = 0
    public func draw(in view: MTKView) {
        if let drawable = view.currentDrawable,
           let commandBuffer = queue.makeCommandBuffer(),
           let commandEncoder = commandBuffer.makeComputeCommandEncoder() {
            
            commandEncoder.setComputePipelineState(computeState)
            commandEncoder.setTexture(drawable.texture, index: 0)
            commandEncoder.setBuffer(timeBuffer, offset: 0, index: 0)
            commandEncoder.setBuffer(totalMakBuffer, offset: 0, index: 1)
            commandEncoder.setBuffer(primitiveBuffer, offset: 0, index: 2)
            commandEncoder.setBuffer(colorBuffer, offset: 0, index: 3)
            commandEncoder.setBuffer(resolutionBuffer, offset: 0, index: 4)
            
            
            if matrixPublisher.matrix[0].w == 1 {
                sw = 0
                totalMak[0].x = self.matrixPublisher.matrix[0].x
                totalMak[0].y = self.matrixPublisher.matrix[0].y
                totalMak[0].z = self.matrixPublisher.matrix[0].z
                totalMak[1].x = self.matrixPublisher.matrix[1].x
                totalMak[1].y = self.matrixPublisher.matrix[1].y
                totalMak[1].z = self.matrixPublisher.matrix[1].z
                totalMak[2].x = self.matrixPublisher.matrix[2].x
                totalMak[2].y = self.matrixPublisher.matrix[2].y
                totalMak[2].z = self.matrixPublisher.matrix[2].z
                totalMak[2].w = self.matrixPublisher.matrix[2].w
            } else {
                if sw == 0 {
                    // print("Alef")
                    totalMak[0].x = self.matrixPublisher.matrix[0].x
                    totalMak[0].y = self.matrixPublisher.matrix[0].y
                    totalMak[0].z = self.matrixPublisher.matrix[0].z
                    totalMak[1].x = self.matrixPublisher.matrix[1].x
                    totalMak[1].y = self.matrixPublisher.matrix[1].y
                    totalMak[1].z = self.matrixPublisher.matrix[1].z
                    totalMak[2].x = self.matrixPublisher.matrix[2].x
                    totalMak[2].y = self.matrixPublisher.matrix[2].y
                    totalMak[2].z = self.matrixPublisher.matrix[2].z
                    totalMak[2].w = self.matrixPublisher.matrix[2].w
                    incrementX = asin(totalMak[2].x)
                    incrementY = asin(totalMak[2].y)
                    incrementZ = asin(totalMak[2].z + 3)
                    incrementW = asin(totalMak[2].w)
                    
                }
                sw += 1
                if self.matrixPublisher.booleanMatrix[1][0] {
                    totalMak[0].x += 1
                    totalMak[0].x = totalMak[0].x.truncatingRemainder(dividingBy: 360)
                }
                //print(self.matrixPublisher.matrix[0][0])
                if self.matrixPublisher.booleanMatrix[1][1] {
                    totalMak[0].y += 1
                    totalMak[0].y = totalMak[0].y.truncatingRemainder(dividingBy: 360)
                }
                
                if self.matrixPublisher.booleanMatrix[1][2] {
                    totalMak[0].z += 1
                    totalMak[0].z = totalMak[0].z.truncatingRemainder(dividingBy: 360)
                }
                
                if self.matrixPublisher.booleanMatrix[2][0] {
                    totalMak[1].x += 1
                    totalMak[1].x = totalMak[1].x.truncatingRemainder(dividingBy: 360)
                }
                
                if self.matrixPublisher.booleanMatrix[2][1] {
                    totalMak[1].y += 1
                    totalMak[1].y = totalMak[1].y.truncatingRemainder(dividingBy: 360)
                }
                
                if self.matrixPublisher.booleanMatrix[2][2] {
                    totalMak[1].z += 1
                    totalMak[1].z = totalMak[1].z.truncatingRemainder(dividingBy: 360)
                }
                
                if self.matrixPublisher.booleanMatrix[0][0] {
                    totalMak[2].x = sin(incrementX)
                    incrementX += 0.015
                }
                
                if self.matrixPublisher.booleanMatrix[0][1] {
                    totalMak[2].y = sin(incrementY)
                    incrementY += 0.015
                }
                
                if self.matrixPublisher.booleanMatrix[0][2] {
                    incrementZ += 0.015
                }
                if matrixPublisher.matrix[0].w != 1 {
                    totalMak[2].z = sin(incrementZ) - 3
                }
                
                if self.matrixPublisher.booleanMatrix[0][3] {
                    totalMak[2].w = sin(incrementW)
                    incrementW += 0.015
                }
                
                self.matrixPublisher.matrix[0].x = totalMak[0].x
                self.matrixPublisher.matrix[0].y = totalMak[0].y
                self.matrixPublisher.matrix[0].z = totalMak[0].z
                self.matrixPublisher.matrix[1].x = totalMak[1].x
                self.matrixPublisher.matrix[1].y = totalMak[1].y
                self.matrixPublisher.matrix[1].z = totalMak[1].z
                self.matrixPublisher.matrix[2].x = totalMak[2].x
                self.matrixPublisher.matrix[2].y = totalMak[2].y
                self.matrixPublisher.matrix[2].z = totalMak[2].z
                self.matrixPublisher.matrix[2].w = totalMak[2].w
            }
            self.primitive = self.matrixPublisher.primitive.rawValue
            self.color = self.matrixPublisher.color
            if matrixPublisher.matrix[0].w != 1 {
                if false {
                    time += 0.02
                    time = time.truncatingRemainder(dividingBy: 2 * 5 * Float.pi)
                    self.matrixPublisher.powerNecalibrat = time
                }
            } else {
                time = self.matrixPublisher.powerNecalibrat
            }
            
            // print(dragGesture)
            //rotation.x += 1
            //print(time)
            let bufferPointer = timeBuffer.contents()
            memcpy(bufferPointer, &time, MemoryLayout<Float>.size)
            
            let total_bufferPointer = totalMakBuffer.contents()
            memcpy(total_bufferPointer, &totalMak, MemoryLayout<matrix_float3x4>.size)
            
            let primitive_bufferPointer = primitiveBuffer.contents()
            memcpy(primitive_bufferPointer, &primitive, MemoryLayout<Int>.size)
            
            let color_bufferPointer = colorBuffer.contents()
            memcpy(color_bufferPointer, &color, MemoryLayout<SIMD4<Float>>.size)
            
            let resolution_bufferPointer = resolutionBuffer.contents()
            memcpy(resolution_bufferPointer, &resolution, MemoryLayout<Int>.size)
            
            
            let threadGroupCount = MTLSizeMake(10, 10, 1)
            let threadGroups = MTLSizeMake(drawable.texture.width / threadGroupCount.width + 1, drawable.texture.height / threadGroupCount.height + 1, 1)
            commandEncoder.dispatchThreadgroups(threadGroups, threadsPerThreadgroup: threadGroupCount)
            commandEncoder.endEncoding()
            commandBuffer.present(drawable)
            commandBuffer.commit()
        }
    }
}
