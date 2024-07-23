//
//  FilterVM.swift
//  KeyChatMac
//
//  Created by Mostafa Mazrouh on 2024-06-23.
//

import SwiftUI
import Metal
import MetalKit


class FilterVM: ObservableObject {
    private var device: MTLDevice!
    private var commandQueue: MTLCommandQueue!
    private var pipelineState: MTLComputePipelineState!
    private var ciContext: CIContext!
    
    @Published var filteredImage: NSImage?
    
    init() {
        device = MTLCreateSystemDefaultDevice()
        commandQueue = device.makeCommandQueue()
        ciContext = CIContext(mtlDevice: device)
        
        guard let defaultLibrary = device.makeDefaultLibrary(),
              let kernelFunction = defaultLibrary.makeFunction(name: "gaussianBlur") else {
            fatalError("Unable to set up Metal")
        }
        
        pipelineState = try! device.makeComputePipelineState(function: kernelFunction)
    }
    
    func applyBlur(to image: NSImage) {
        guard let inputImage = CIImage(data: image.tiffRepresentation!) else { return }
        let cgImage = ciContext.createCGImage(inputImage, from: inputImage.extent)!
        
        let inTexture = try! makeTexture(from: cgImage)
        let outTexture = makeEmptyTexture(width: inTexture.width, height: inTexture.height)
        
        let commandBuffer = commandQueue.makeCommandBuffer()!
        let commandEncoder = commandBuffer.makeComputeCommandEncoder()!
        commandEncoder.setComputePipelineState(pipelineState)
        commandEncoder.setTexture(inTexture, index: 0)
        commandEncoder.setTexture(outTexture, index: 1)
        
        let threadGroupCount = MTLSize(width: 16, height: 16, depth: 1)
        let threadGroups = MTLSize(width: (inTexture.width + 15) / 16,
                                   height: (inTexture.height + 15) / 16,
                                   depth: 1)
        commandEncoder.dispatchThreadgroups(threadGroups, threadsPerThreadgroup: threadGroupCount)
        commandEncoder.endEncoding()
        
        commandBuffer.commit()
        commandBuffer.waitUntilCompleted()
        
        let outputImage = CIImage(mtlTexture: outTexture, options: nil)!
        let finalCGImage = ciContext.createCGImage(outputImage, from: outputImage.extent)!
        
        filteredImage = NSImage(cgImage: finalCGImage, size: image.size)
    }
    
    private func makeTexture(from cgImage: CGImage) throws -> MTLTexture {
        let loader = MTKTextureLoader(device: device)
        return try loader.newTexture(cgImage: cgImage, options: nil)
    }
    
    private func makeEmptyTexture(width: Int, height: Int) -> MTLTexture {
        let descriptor = MTLTextureDescriptor.texture2DDescriptor(pixelFormat: .rgba8Unorm,
                                                                  width: width,
                                                                  height: height,
                                                                  mipmapped: false)
        descriptor.usage = [.shaderRead, .shaderWrite]
        return device.makeTexture(descriptor: descriptor)!
    }
}
