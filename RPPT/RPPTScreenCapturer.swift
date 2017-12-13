////
////  RPPTScreenCapturer.swift
////  RTTF
////
////  Created by Roberto Perez Cubero on 23/09/2016.
////  Copyright © 2016 tokbox. All rights reserved.
////
//
//import ReplayKit
//import VideoToolbox
//import Accelerate
//
//@available(iOS 11.0, *)
//class RPPTScreenCapturer: NSObject, OTVideoCapture {
//
//    // MARK: - Properties
//
//    var videoCaptureConsumer: OTVideoCaptureConsumer?
//
//    private var format: OTVideoFormat = {
//        let format = OTVideoFormat()
//        format.pixelFormat = .ARGB
//        return format
//    }()
//
//    var frame = OTVideoFrame(format: OTVideoFormat(argbWithWidth: 896, height: 1920))
//
//    // MARK: - Initalization
//
//    override init() {
//        super.init()
//
//        var frames = 0
//
//        let assa = AScreenCapturer()
//
//        let sharedRecorder = RPScreenRecorder.shared()
//        sharedRecorder.startCapture(handler: { sampleBuffer, bufferType, error in
//
//            if let error = error {
//                // TODO: Something
//            }
//
//            guard bufferType == .video else {
//                return
//            }
//
//            guard let srcPixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {
//                fatalError()
//            }
//
////            CVPixelBufferLockBaseAddress(pixelBuffer, CVPixelBufferLockFlags(rawValue: 0))
////
////            let timeStamp = mach_absolute_time()
////            let time = CMTime(seconds: Double(timeStamp), preferredTimescale: 1000)
////
//////            self.frame.format?.imageWidth = UInt32(CVPixelBufferGetWidth(pixelBuffer))
//////            self.frame.format?.imageHeight = UInt32(CVPixelBufferGetHeight(pixelBuffer))
////            self.frame.format?.bytesPerRow = [NSNumber(value: self.format.imageWidth * 4)]
////
//////            var frame = OTVideoFrame(format: self.format)
//////            frame.timestamp = time
//////            frame.planes?.addPointer(CVPixelBufferGetBaseAddress(pixelBuffer))
////
////            var cgImage: CGImage?
////            VTCreateCGImageFromCVPixelBuffer(pixelBuffer, nil, &cgImage)
////
////            if let cgImage = cgImage {
////                let image = UIImage(cgImage: cgImage)
////                print(image)
////            } else {
////               print()
////            }
////
////            let ciImage = CIImage(cvPixelBuffer: pixelBuffer)
////            let resizedCIImage = ciImage.transformed(by: CGAffineTransform(scaleX: 896.0 / 886.0, y: 1.0))
////
////            let context = CIContext()
//////            if let image = context.createCGImage(resizedCIImage, from: resizedCIImage.extent) {
//////                return UIImage(cgImage: image)
//////            }
//
//            let cropX = 0
//            let cropY = 0
//            let cropHeight = 896
//            let cropWidth = 1920
//
//            let scaleWidth = 896
//            let scaleHeight = 1920
//
//
//            CVPixelBufferLockBaseAddress(srcPixelBuffer, CVPixelBufferLockFlags(rawValue: 0))
//            guard let srcData = CVPixelBufferGetBaseAddress(srcPixelBuffer) else {
//                print("Error: could not get pixel buffer base address")
//                return
//            }
//            let srcBytesPerRow = CVPixelBufferGetBytesPerRow(srcPixelBuffer)
//            let offset = cropY*srcBytesPerRow + cropX*4
//            var srcBuffer = vImage_Buffer(data: srcData.advanced(by: offset),
//                                          height: vImagePixelCount(cropHeight),
//                                          width: vImagePixelCount(cropWidth),
//                                          rowBytes: srcBytesPerRow)
//
//            let destBytesPerRow = scaleWidth*4
//            guard let destData = malloc(scaleHeight*destBytesPerRow) else {
//                print("Error: out of memory")
//                return
//            }
//            var destBuffer = vImage_Buffer(data: destData,
//                                           height: vImagePixelCount(scaleHeight),
//                                           width: vImagePixelCount(scaleWidth),
//                                           rowBytes: destBytesPerRow)
//
//            let error = vImageScale_ARGB8888(&srcBuffer, &destBuffer, nil, vImage_Flags(0))
//            CVPixelBufferUnlockBaseAddress(srcPixelBuffer, CVPixelBufferLockFlags(rawValue: 0))
//            if error != kvImageNoError {
//                print("Error:", error)
//                free(destData)
//                return
//            }
//
//            let releaseCallback: CVPixelBufferReleaseBytesCallback = { _, ptr in
//                if let ptr = ptr {
//                    free(UnsafeMutableRawPointer(mutating: ptr))
//                }
//            }
//
//            let pixelFormat = CVPixelBufferGetPixelFormatType(srcPixelBuffer)
//            var dstPixelBuffer: CVPixelBuffer?
//            let status = CVPixelBufferCreateWithBytes(nil, scaleWidth, scaleHeight,
//                                                      pixelFormat, destData,
//                                                      destBytesPerRow, releaseCallback,
//                                                      nil, nil, &dstPixelBuffer)
//            if status != kCVReturnSuccess {
//                print("Error: could not create new pixel buffer")
//                free(destData)
//                return
//            }
//
//            //self.frame.timestamp = time
//            //videoFrame?.format.estimatedFramesPerSecond =
//            self.frame.format?.estimatedCaptureDelay = 100
//            self.frame.orientation = .up
//
//            self.frame.clearPlanes()
//            self.frame.planes?.addPointer(CVPixelBufferGetBaseAddress(dstPixelBuffer!))
//
//            frames += 1
//            if frames % 15 == 0 {
//                self.videoCaptureConsumer?.consumeFrame(self.frame)
//               // self.videoCaptureConsumer!.consumeFrame(self.frame)
//            }
//
//
//            DispatchQueue.main.async {
////                self.videoCaptureConsumer?.consumeFrame(frame)
//            }
//
//
//
//           // CVPixelBufferUnlockBaseAddress(pixelBuffer, CVPixelBufferLockFlags(rawValue: 0))
//
//        }) { _ in
//
//        }
//
//    }
//
//    // MARK: - OTVideoCapture (lol what kind of API is this)
//
//    func initCapture() {
//        print(#function)
//    }
//
//    func releaseCapture() {
//        print(#function)
//    }
//
//    func start() -> Int32 {
//        print(#function)
//        return 0
//    }
//
//    func stop() -> Int32 {
//        print(#function)
//        return 0
//    }
//
//    func isCaptureStarted() -> Bool {
//        print(#function)
//        return true
//    }
//
//    func captureSettings(_ videoFormat: OTVideoFormat) -> Int32 {
//        print(#function)
//        return 0
//    }
//
//}
//
//class AScreenCapturer: NSObject {
//
//    //swiftlint:disable identifier_name
//    let MAX_EDGE_SIZE_LIMIT: CGFloat = 1280.0
//    let EDGE_DIMENSION_COMMON_FACTOR: CGFloat = 16.0
//
//    fileprivate var videoFrame = OTVideoFrame(format: OTVideoFormat(argbWithWidth: 0, height: 0))
//    fileprivate var pixelBuffer: CVPixelBuffer?
//
//
//    fileprivate func consume(frame: CGImage) -> OTVideoFrame {
//        checkSize(forImage: frame)
//
//
//        let timeStamp = mach_absolute_time()
//        let time = CMTime(seconds: Double(timeStamp), preferredTimescale: 1000)
//        let ref = pixelBuffer(fromCGImage: frame)
//
//        CVPixelBufferLockBaseAddress(ref, CVPixelBufferLockFlags(rawValue: 0))
//
//        videoFrame.timestamp = time
//        //videoFrame?.format.estimatedFramesPerSecond =
//        videoFrame.format?.estimatedCaptureDelay = 100
//        videoFrame.orientation = .up
//
//        videoFrame.clearPlanes()
//        videoFrame.planes?.addPointer(CVPixelBufferGetBaseAddress(ref))
//
//
//        CVPixelBufferUnlockBaseAddress(ref, CVPixelBufferLockFlags(rawValue: CVOptionFlags(0)))
//
//        return videoFrame
//    }
//
//}
//
//// MARK: - Image Utils
//extension AScreenCapturer {
//    fileprivate func pixelBuffer(fromCGImage img: CGImage) -> CVPixelBuffer {
//        let frameSize = CGSize(width: img.width, height: img.height)
//        CVPixelBufferLockBaseAddress(pixelBuffer!, CVPixelBufferLockFlags(rawValue: CVOptionFlags(0)))
//        let pxdata = CVPixelBufferGetBaseAddress(pixelBuffer!)
//
//        let rgbColorSpace = CGColorSpaceCreateDeviceRGB()
//        let context =
//            CGContext(data: pxdata,
//                      width: Int(frameSize.width),
//                      height: Int(frameSize.height),
//                      bitsPerComponent: 8,
//                      bytesPerRow: CVPixelBufferGetBytesPerRow(pixelBuffer!),
//                      space: rgbColorSpace,
//                      bitmapInfo: CGImageAlphaInfo.premultipliedFirst.rawValue | CGBitmapInfo.byteOrder32Little.rawValue)
//
//
//        context?.draw(img, in: CGRect(x: 0, y: 0, width: img.width, height: img.height))
//
//        CVPixelBufferUnlockBaseAddress(pixelBuffer!, CVPixelBufferLockFlags(rawValue: CVOptionFlags(0)))
//
//        return pixelBuffer!;
//    }
//
//    fileprivate func dimensions(forInputSize size: CGSize) -> (container: CGSize, rect: CGRect) {
//        let aspect = size.width / size.height
//
//        var destContainer = CGSize(width: size.width, height: size.height)
//        var destFrame = CGRect(origin: CGPoint(), size: CGSize(width: size.width, height: size.height))
//
//        // if image is wider than tall and width breaks edge size limit
//        if MAX_EDGE_SIZE_LIMIT < size.width && aspect >= 1.0 {
//            destContainer.width = MAX_EDGE_SIZE_LIMIT
//            destContainer.height = destContainer.width / aspect
//            if 0 != fmod(destContainer.height, EDGE_DIMENSION_COMMON_FACTOR) {
//                destContainer.height +=
//                    (EDGE_DIMENSION_COMMON_FACTOR - fmod(destContainer.height, EDGE_DIMENSION_COMMON_FACTOR))
//            }
//            destFrame.size.width = destContainer.width
//            destFrame.size.height = destContainer.width / aspect
//        }
//
//        // ensure the dimensions of the resulting container are safe
//        if (fmod(destContainer.width, EDGE_DIMENSION_COMMON_FACTOR) != 0) {
//            let remainder = fmod(destContainer.width,
//                                 EDGE_DIMENSION_COMMON_FACTOR);
//            // increase the edge size only if doing so does not break the edge limit
//            if (destContainer.width + (EDGE_DIMENSION_COMMON_FACTOR - remainder) >
//                MAX_EDGE_SIZE_LIMIT)
//            {
//                destContainer.width -= remainder;
//            } else {
//                destContainer.width += EDGE_DIMENSION_COMMON_FACTOR - remainder;
//            }
//        }
//        // ensure the dimensions of the resulting container are safe
//        if (fmod(destContainer.height, EDGE_DIMENSION_COMMON_FACTOR) != 0) {
//            let remainder = fmod(destContainer.height,
//                                 EDGE_DIMENSION_COMMON_FACTOR);
//            // increase the edge size only if doing so does not break the edge limit
//            if (destContainer.height + (EDGE_DIMENSION_COMMON_FACTOR - remainder) >
//                MAX_EDGE_SIZE_LIMIT)
//            {
//                destContainer.height -= remainder;
//            } else {
//                destContainer.height += EDGE_DIMENSION_COMMON_FACTOR - remainder;
//            }
//        }
//
//        destFrame.size.width = destContainer.width;
//        destFrame.size.height = destContainer.height;
//
//        // scale and recenter source image to fit in destination container
//        if (aspect > 1.0) {
//            destFrame.origin.x = 0;
//            destFrame.origin.y =
//                (destContainer.height - destContainer.width) / 2;
//            destFrame.size.width = destContainer.width;
//            destFrame.size.height =
//                destContainer.width / aspect;
//        } else {
//            destFrame.origin.x =
//                (destContainer.width - destContainer.width) / 2;
//            destFrame.origin.y = 0;
//            destFrame.size.height = destContainer.height;
//            destFrame.size.width =
//                destContainer.height * aspect;
//        }
//
//        return (destContainer, destFrame)
//    }
//
//    fileprivate func checkSize(forImage img: CGImage) {
//        if (videoFrame.format?.imageHeight == UInt32(img.height) &&
//            videoFrame.format?.imageWidth == UInt32(img.width))
//        {
//            // don't rock the boat. if nothing has changed, don't update anything.
//            return
//        }
//
//        videoFrame.format?.bytesPerRow.removeAllObjects()
//        videoFrame.format?.bytesPerRow.addObjects(from: [img.width * 4])
//        videoFrame.format?.imageWidth = UInt32(img.width)
//        videoFrame.format?.imageHeight = UInt32(img.height)
//
//        let frameSize = CGSize(width: img.width, height: img.height)
//        let options: Dictionary<String, Bool> = [
//            kCVPixelBufferCGImageCompatibilityKey as String: false,
//            kCVPixelBufferCGBitmapContextCompatibilityKey as String: false
//        ]
//
//        let status = CVPixelBufferCreate(kCFAllocatorDefault,
//                                         Int(frameSize.width),
//                                         Int(frameSize.height),
//                                         kCVPixelFormatType_32ARGB,
//                                         options as CFDictionary,
//                                         &pixelBuffer)
//
//        assert(status == kCVReturnSuccess && pixelBuffer != nil)
//    }
//}
//
