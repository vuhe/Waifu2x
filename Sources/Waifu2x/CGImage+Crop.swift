//
//  CGImage+Crop.swift
//  waifu2x-mac
//
//  Created by xieyi on 2020/3/7.
//  Copyright © 2020 xieyi. All rights reserved.
//

import CoreML

extension CGImage {
    func getCropRects(_ block_size: Int) -> ([CGRect]) {
        let num_w = width / block_size
        let num_h = height / block_size
        let ex_w = width % block_size
        let ex_h = height % block_size
        var rects: [CGRect] = []
        for i in 0 ..< num_w {
            for j in 0 ..< num_h {
                let x = i * block_size
                let y = j * block_size
                let rect = CGRect(x: x, y: y, width: block_size, height: block_size)
                rects.append(rect)
            }
        }
        if ex_w > 0 {
            let x = width - block_size
            for i in 0 ..< num_h {
                let y = i * block_size
                let rect = CGRect(x: x, y: y, width: block_size, height: block_size)
                rects.append(rect)
            }
        }
        if ex_h > 0 {
            let y = height - block_size
            for i in 0 ..< num_w {
                let x = i * block_size
                let rect = CGRect(x: x, y: y, width: block_size, height: block_size)
                rects.append(rect)
            }
        }
        if ex_w > 0, ex_h > 0 {
            let x = width - block_size
            let y = height - block_size
            let rect = CGRect(x: x, y: y, width: block_size, height: block_size)
            rects.append(rect)
        }
        return rects
    }
}
