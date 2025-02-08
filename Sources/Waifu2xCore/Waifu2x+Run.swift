//
//  Waifu2x+Run.swift
//  Waifu2x
//
//  Created by vuhe on 2025/1/1.
//  Copyright © 2025 vuhe. All rights reserved.
//

import CoreImage

public extension Waifu2x {
    func run(_ data: Data) async throws -> Waifu2xData {
        guard let imageSource = CGImageSourceCreateWithData(data as CFData, nil),
              let cgimg = CGImageSourceCreateImageAtIndex(imageSource, 0, nil)
        else { throw Waifu2xError.getCGImageFailed }
        return try await run(cgimg)
    }
}

#if swift(<6.0)
    public extension Waifu2x {
        /// Processing method applicable to GCD.
        ///
        /// This method will block the thread. Do not call it in the Task context.
        func runAndWait(_ data: Data) throws -> Waifu2xData {
            guard let imageSource = CGImageSourceCreateWithData(data as CFData, nil),
                  let cgimg = CGImageSourceCreateImageAtIndex(imageSource, 0, nil)
            else { throw Waifu2xError.getCGImageFailed }
            return try runAndWait(cgimg)
        }

        /// Processing method applicable to GCD.
        ///
        /// This method will block the thread. Do not call it in the Task context.
        func runAndWait(_ image: CGImage) throws -> Waifu2xData {
            var result: Result<Waifu2xData, any Error> = .failure(Waifu2xError.blockRunFailed)
            let group = DispatchGroup()
            group.enter()
            Task {
                do {
                    result = try await .success(run(image))
                } catch {
                    result = .failure(error)
                }
                group.leave()
            }
            group.wait()
            return try result.get()
        }
    }
#endif
