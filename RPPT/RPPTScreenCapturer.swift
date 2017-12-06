//
//  RPPTScreenCapturer.swift
//  RTTF
//
//  Created by Roberto Perez Cubero on 23/09/2016.
//  Copyright © 2016 tokbox. All rights reserved.
//

import ReplayKit

@available(iOS 11.0, *)
class RPPTScreenCapturer: NSObject, OTVideoCapture {

    // MARK: - Properties

    var videoCaptureConsumer: OTVideoCaptureConsumer?

    private var format: OTVideoFormat = {
        let format = OTVideoFormat()
        format.pixelFormat = .ARGB
        return format
    }()

    // MARK: - Initalization

    override init() {
        super.init()

        let sharedRecorder = RPScreenRecorder.shared()
        sharedRecorder.startCapture(handler: { sampleBuffer, bufferType, error in

            if let error = error {

            }

            guard bufferType == .video else {
                fatalError()
            }

            guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {
                fatalError()
            }

            CVPixelBufferLockBaseAddress(pixelBuffer, CVPixelBufferLockFlags(rawValue: 0))

            self.updateFormat(for: pixelBuffer)
            let frame = OTVideoFrame(format: self.format)
            frame.planes?.addPointer(CVPixelBufferGetBaseAddress(pixelBuffer))

            CVPixelBufferUnlockBaseAddress(pixelBuffer, CVPixelBufferLockFlags(rawValue: 0))

        }) { _ in

        }

    }

    private func updateFormat(for pixelBuffer: CVPixelBuffer) {
        format.imageWidth = UInt32(CVPixelBufferGetWidth(pixelBuffer))
        format.imageHeight = UInt32(CVPixelBufferGetHeight(pixelBuffer))
        format.bytesPerRow = [NSNumber(value: format.imageWidth * 4)]
    }

    // MARK: - OTVideoCapture (lol what kind of API is this)

    func initCapture() {

    }

    func releaseCapture() {

    }

    func start() -> Int32 {
        return 0
    }

    func stop() -> Int32 {
        return 0
    }

    func isCaptureStarted() -> Bool {
        return true
    }

    func captureSettings(_ videoFormat: OTVideoFormat) -> Int32 {
        return 0
    }

}
