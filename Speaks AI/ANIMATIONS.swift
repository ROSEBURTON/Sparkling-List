import UIKit
import ImageIO

class GifPlayer {
    func playGif(named name: String, in imageView: UIImageView) {
        DispatchQueue.global().async {
            guard let gifUrl = Bundle.main.url(forResource: name, withExtension: "gif") else {
                print("GIF named \"\(name)\" not found.")
                return
            }

            guard let gifData = try? Data(contentsOf: gifUrl) else {
                print("Failed to load GIF data for \"\(name)\".")
                return
            }

            guard let gifImage = UIImage.animatedImage(with: self.gifFrames(from: gifData), duration: self.gifDuration(from: gifData)) else {
                print("Failed to create UIImage from GIF data.")
                return
            }

            DispatchQueue.main.async {
                // Set the GIF image to the UIImageView
                imageView.image = gifImage
            }
        }
    }

    private func gifFrames(from gifData: Data) -> [UIImage] {
        guard let source = CGImageSourceCreateWithData(gifData as CFData, nil) else {
            return []
        }

        var frames: [UIImage] = []
        let count = CGImageSourceGetCount(source)

        for index in 0..<count {
            if let cgImage = CGImageSourceCreateImageAtIndex(source, index, nil) {
                let image = UIImage(cgImage: cgImage)
                frames.append(image)
            }
        }

        return frames
    }

    private func gifDuration(from gifData: Data) -> TimeInterval {
        guard let source = CGImageSourceCreateWithData(gifData as CFData, nil) else {
            return 0.0
        }

        let count = CGImageSourceGetCount(source)
        var totalDuration: TimeInterval = 0.0

        for index in 0..<count {
            let delaySeconds = source.delayForImageAtIndex(Int(index), source: source)
            totalDuration += delaySeconds
        }

        return totalDuration
    }
}

extension CGImageSource {
    internal func delayForImageAtIndex(_ index: Int, source: CGImageSource!) -> Double {
        var delay = 0.1

        // Get dictionaries
        let cfProperties = CGImageSourceCopyPropertiesAtIndex(source, index, nil)
        let gifPropertiesPointer = UnsafeMutablePointer<UnsafeRawPointer?>.allocate(capacity: 0)
        defer {
            gifPropertiesPointer.deallocate()
        }
        let unsafePointer = Unmanaged.passUnretained(kCGImagePropertyGIFDictionary).toOpaque()
        if CFDictionaryGetValueIfPresent(cfProperties, unsafePointer, gifPropertiesPointer) == false {
            return delay
        }

        let gifProperties: CFDictionary = unsafeBitCast(gifPropertiesPointer.pointee, to: CFDictionary.self)

        // Get delay time
        var delayObject: AnyObject = unsafeBitCast(
            CFDictionaryGetValue(gifProperties,
                                 Unmanaged.passUnretained(kCGImagePropertyGIFUnclampedDelayTime).toOpaque()),
            to: AnyObject.self)
        if delayObject.doubleValue == 0 {
            delayObject = unsafeBitCast(CFDictionaryGetValue(gifProperties,
                                                             Unmanaged.passUnretained(kCGImagePropertyGIFDelayTime).toOpaque()), to: AnyObject.self)
        }

        if let delayObject = delayObject as? Double, delayObject > 0 {
            delay = delayObject
        } else {
            delay = 0.1 // Make sure they're not too fast
        }

        return delay
    }
}
