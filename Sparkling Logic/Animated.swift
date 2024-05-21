import UIKit

class GifPlayer {
    func PlayGif(named name: String, within IBImageViewOutlet: UIImageView) {
        DispatchQueue.global().async {
            guard let gif_connection = Bundle.main.url(forResource: name, withExtension: "gif") else {
                print("GIF named \"\(String(describing: selectedEntity))\" not found.")
                return
            }
            guard let GifData = try? Data(contentsOf: gif_connection) else {
                print("Failed to load GIF data for \"\(name))\".")
                return
            }
            guard let Gif_Frame = UIImage.animatedImage(with: self.Gif_Frames(from: GifData), duration: self.GifDuration(from: GifData)) else {
                print("Failed to create frame from GIF data.")
                return
            }
            DispatchQueue.main.async {
                IBImageViewOutlet.image = Gif_Frame
            }
        }
    }

    private func Gif_Frames(from GifData: Data) -> [UIImage] {
        guard let source = CGImageSourceCreateWithData(GifData as CFData, nil) else {
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

    private func GifDuration(from gifData: Data) -> TimeInterval {
        guard let source = CGImageSourceCreateWithData(gifData as CFData, nil) else {
            return 0.0
        }
        let count = CGImageSourceGetCount(source)
        var totalDuration: TimeInterval = 0.0
        for index in 0..<count {
            let delaySeconds = source.Delay(Int(index), source: source)
            totalDuration += delaySeconds
        }
        return totalDuration
    }
}

extension CGImageSource {
    internal func Delay(_ index: Int, source: CGImageSource!) -> Double {
        var delay = 1.1
        let cfProperties = CGImageSourceCopyPropertiesAtIndex(source, index, nil)
        let gifPropertiesPointer = UnsafeMutablePointer<UnsafeRawPointer?>.allocate(capacity: 0)
        defer {
            gifPropertiesPointer.deallocate()
        }
        let UnsafePointer = Unmanaged.passUnretained(kCGImagePropertyGIFDictionary).toOpaque()
        if CFDictionaryGetValueIfPresent(cfProperties, UnsafePointer, gifPropertiesPointer) == false {
            return delay
        }
        let gifProperties: CFDictionary = unsafeBitCast(gifPropertiesPointer.pointee, to: CFDictionary.self)
        var Delay_Animatee: AnyObject = unsafeBitCast(
            CFDictionaryGetValue(gifProperties,
                                 Unmanaged.passUnretained(kCGImagePropertyGIFUnclampedDelayTime).toOpaque()),
            to: AnyObject.self)
        if Delay_Animatee.doubleValue == 0 {
            Delay_Animatee = unsafeBitCast(CFDictionaryGetValue(gifProperties,
                                                             Unmanaged.passUnretained(kCGImagePropertyGIFDelayTime).toOpaque()), to: AnyObject.self)
        }
        if let delayObject = Delay_Animatee as? Double, delayObject > 0 {
            delay = delayObject
        } else {
            delay = 1
        }
        return delay
    }
}
