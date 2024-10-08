import Cocoa
import Testing
@testable import Waifu2x

extension NSImage {
    var pngData: Data? {
        guard let tiffRepresentation = tiffRepresentation, let bitmapImage = NSBitmapImageRep(data: tiffRepresentation) else { return nil }
        return bitmapImage.representation(using: .png, properties: [:])
    }

    func pngWrite(to url: URL, options: Data.WritingOptions = .atomic) throws {
        try pngData?.write(to: url, options: options)
    }
}

@Test func testModel() async throws {
    let bundle = Bundle.module
    let path = bundle.path(forResource: "white", ofType: "png")!
    let data = NSData(contentsOfFile: path)
    let image = NSImage(data: data! as Data)!
    let waifu2x = Waifu2x(model: Waifu2xModel.photo_noise2_scale2x)
    _ = try! await waifu2x.run(image)
}

@Test func testAllModels() async throws {
    await withTaskGroup(of: Void.self) { group in
        for model in Waifu2xModel.allCases {
            group.addTask {
                print(model)
                let bundle = Bundle.module
                let path = bundle.path(forResource: "white", ofType: "png")!
                let data = NSData(contentsOfFile: path)
                let image = NSImage(data: data! as Data)!
                let waifu2x = Waifu2x(model: model)
                _ = try! await waifu2x.run(image)
            }
        }
    }
}

@Test func testGCD() throws {
    let group = DispatchGroup()
    group.enter()
    Task {
        let bundle = Bundle.module
        let path = bundle.path(forResource: "white", ofType: "png")!
        let data = NSData(contentsOfFile: path)
        let image = NSImage(data: data! as Data)!
        let waifu2x = Waifu2x(model: Waifu2xModel.photo_noise2_scale2x)
        _ = try! await waifu2x.run(image)
        group.leave()
    }
    group.wait()
}
