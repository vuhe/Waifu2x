//
//  Waifu2xTests.swift
//  Waifu2x
//
//  Created by vuhe on 2024/9/25.
//  Copyright © 2024 vuhe. All rights reserved.
//

import Foundation
import Testing
import Waifu2xCore
import Waifu2xModels

@Test func testModel() async throws {
    let url = Bundle.module.url(forResource: "white", withExtension: "png")!
    let waifu2x = Waifu2x(srcnn: .anime_noise3_scale2x)
    _ = try await waifu2x.run(Data(contentsOf: url))
}

@Test func testAllModels() async throws {
    await withTaskGroup(of: Void.self) { group in
        let url = Bundle.module.url(forResource: "white", withExtension: "png")!
        for model in Waifu2xSrcnnModel.allCases {
            group.addTask {
                let startTime = CFAbsoluteTimeGetCurrent()
                let waifu2x = Waifu2x(srcnn: model)
                _ = try! await waifu2x.run(Data(contentsOf: url))
                let endTime = CFAbsoluteTimeGetCurrent()
                print("\(model) handled \(endTime - startTime) sec")
            }
        }
    }
}

@Test func testGCD() throws {
    let url = Bundle.module.url(forResource: "white", withExtension: "png")!
    let waifu2x = Waifu2x(srcnn: .photo_noise2_scale2x)
    _ = try! waifu2x.runAndWait(Data(contentsOf: url))
}
