//
//  MetalBicubic.swift
//  waifu2x
//
//  Created by xieyi on 2018/1/23.
//  Copyright © 2018年 xieyi. All rights reserved.
//

import Metal
import MetalKit

struct MetalBicubic {
    let device: MTLDevice!
    let library: MTLLibrary!
    let commandQueue: MTLCommandQueue!

    init() throws {
        device = MTLCreateSystemDefaultDevice()
        guard device != nil else {
            throw Waifu2xError.metalNotAvailable
        }
        library = try device.makeDefaultLibrary(bundle: Bundle.module)
        commandQueue = device.makeCommandQueue()
    }

    func maxTextureSize() -> Int {
        return 16384
    }

    func resizeSingle(_ input: [UInt8], _ width: Int, _ height: Int, _ factor: Float = 1.0) -> [UInt8]? {
        // Get image size
        var inW = width
        var inH = height
        var sf = factor
        // Convert to metal texture
        let inTextureDescriptor = MTLTextureDescriptor.texture2DDescriptor(pixelFormat: MTLPixelFormat.r8Unorm, width: inW, height: inH, mipmapped: true)
        let inTexture = device.makeTexture(descriptor: inTextureDescriptor)
        let inRegion = MTLRegionMake2D(0, 0, inW, inH)
        inTexture?.replace(region: inRegion, mipmapLevel: 0, withBytes: input, bytesPerRow: width)
        // Prepare output texture
        var outW = Int(Float(inW) * factor)
        var outH = Int(Float(inH) * factor)
        var outP = outW
        let outTextureDescriptor = MTLTextureDescriptor.texture2DDescriptor(pixelFormat: MTLPixelFormat.r8Unorm, width: outW, height: outH, mipmapped: false)
        outTextureDescriptor.usage = .shaderWrite
        guard let outTexture = device.makeTexture(descriptor: outTextureDescriptor) else {
            return nil
        }
        // Set constants
        let constants = MTLFunctionConstantValues()
        constants.setConstantValue(&sf, type: MTLDataType.float, index: 0)
        constants.setConstantValue(&inW, type: MTLDataType.uint, index: 1)
        constants.setConstantValue(&inH, type: MTLDataType.uint, index: 2)
        constants.setConstantValue(&outW, type: MTLDataType.uint, index: 3)
        constants.setConstantValue(&outH, type: MTLDataType.uint, index: 4)
        constants.setConstantValue(&outP, type: MTLDataType.uint, index: 5)
        let sampleMain = try! library.makeFunction(name: "BicubicSingleMain", constantValues: constants)
        let pipelineState = try! device.makeComputePipelineState(function: sampleMain)
        // Invoke kernel function
        let commandBuffer = commandQueue.makeCommandBuffer()
        let commandEncoder = commandBuffer?.makeComputeCommandEncoder()
        commandEncoder?.setComputePipelineState(pipelineState)
        commandEncoder?.setTexture(inTexture, index: 0)
        commandEncoder?.setTexture(outTexture, index: 1)
        let threadGroupCount = MTLSize(width: 1, height: 1, depth: 1)
        let threadGroups = MTLSize(width: outW / threadGroupCount.width, height: outH / threadGroupCount.height, depth: 1)
        commandEncoder?.dispatchThreadgroups(threadGroups, threadsPerThreadgroup: threadGroupCount)
        commandEncoder?.endEncoding()
        commandBuffer?.commit()
        commandBuffer?.waitUntilCompleted()
        // Get output texture
        let outByteCount = outW * outH
        let outBytesPerRow = outW
        var outBytes = [UInt8](repeating: 0, count: outByteCount)
        let outRegion = MTLRegionMake2D(0, 0, outW, outH)
        outTexture.getBytes(&outBytes, bytesPerRow: outBytesPerRow, from: outRegion, mipmapLevel: 0)
        return outBytes
    }
}
