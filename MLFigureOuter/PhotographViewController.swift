//
//  PhotographViewController.swift
//  MLFigureOuter
//
//  Created by Kevin Malek on 6/25/18.
//  Copyright © 2018 The RealReal. All rights reserved.
//

import UIKit
import AVFoundation

class PhotographViewController: UIViewController, AVCapturePhotoCaptureDelegate {

    @IBOutlet weak var videoView: UIView!
    var captureSession: AVCaptureSession!
    var videoPreviewLayer: AVCaptureVideoPreviewLayer?
    let cameraOutput = AVCapturePhotoOutput()
    
    
    var capturedImage: UIImage?
    var predictionOutput: ShoesAndHandbagsPhase2Output?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let captureDevice = AVCaptureDevice.default(for: AVMediaType.video)
        
        do {
            guard let captureDevice = captureDevice else { return }
            let input = try AVCaptureDeviceInput(device: captureDevice)
            captureSession = AVCaptureSession()
            captureSession.sessionPreset = AVCaptureSession.Preset.photo
            captureSession.addInput(input)
        }
        catch {
            print(error)
        }

        captureSession.addOutput(cameraOutput)
        let videoLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        videoLayer.videoGravity = .resizeAspectFill
        videoLayer.frame = videoView.layer.bounds
        videoView.layer.addSublayer(videoLayer)
        videoPreviewLayer = videoLayer
        captureSession.startRunning()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        videoPreviewLayer?.frame = videoView.layer.bounds

    }
    
    @IBAction func takePhotoPressed(_ sender: UIButton) {
        let settings = AVCapturePhotoSettings()
        let previewPixelType = settings.availablePreviewPhotoPixelFormatTypes.first!
        let previewFormat = [kCVPixelBufferPixelFormatTypeKey as String: previewPixelType, kCVPixelBufferWidthKey as String: 160, kCVPixelBufferHeightKey as String: 160]
        settings.previewPhotoFormat = previewFormat

        cameraOutput.capturePhoto(with: settings, delegate: self)
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        if let productResultsVC = segue.destination as? ProductMLResultsViewController {
            productResultsVC.predictionOutput = predictionOutput
        }
        
    }

//    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
//        guard error == nil else {
//            print(error!.localizedDescription)
//            return
//        }
//
//        guard let data = photo.fileDataRepresentation() else { return }
//        let imageToDisplay = UIImage(data: data)
//        guard let pixelBuffer = photo.pixelBuffer else { return }
//
//        let predictionInput = ShoesAndHandbagsPhase2Input(image: pixelBuffer)
//        predictionOutput = try? ShoesAndHandbagsPhase2().prediction(input: predictionInput)
//        performSegue(withIdentifier: "showProductMLDetails", sender: nil)
//    }
    
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photoSampleBuffer: CMSampleBuffer?, previewPhoto previewPhotoSampleBuffer: CMSampleBuffer?, resolvedSettings: AVCaptureResolvedPhotoSettings, bracketSettings: AVCaptureBracketedStillImageSettings?, error: Error?) {
        
        guard error == nil, let photoSampleBuffer = photoSampleBuffer, let previewPhotoSampleBuffer = previewPhotoSampleBuffer else {
            print("error: \(error!.localizedDescription)")
            return
        }

        if let dataImage = AVCapturePhotoOutput.jpegPhotoDataRepresentation(forJPEGSampleBuffer: photoSampleBuffer, previewPhotoSampleBuffer: previewPhotoSampleBuffer), let dataProvider = CGDataProvider(data: dataImage as CFData), let cgImageRef = CGImage(jpegDataProviderSource: dataProvider, decode: nil, shouldInterpolate: true, intent: .defaultIntent) {

            let image = UIImage(cgImage: cgImageRef, scale: 1.0, orientation: UIImage.Orientation.right)

            capturedImage = image
            guard let pixelBuffer = buffer(from: image) else { return }

            if let output = try? ShoesAndHandbagsPhase2().prediction(image: pixelBuffer) {
                predictionOutput = output
                performSegue(withIdentifier: "showProductMLDetails", sender: nil)
            }
            else {
                print("error")
                return
            }
        }
        else {
            print("some error here")
        }

    }
    
    func buffer(from image: UIImage) -> CVPixelBuffer? {
        let attrs = [kCVPixelBufferCGImageCompatibilityKey: kCFBooleanTrue, kCVPixelBufferCGBitmapContextCompatibilityKey: kCFBooleanTrue] as CFDictionary
        var pixelBuffer : CVPixelBuffer?
        let status = CVPixelBufferCreate(kCFAllocatorDefault, Int(image.size.width), Int(image.size.height), kCVPixelFormatType_32ARGB, attrs, &pixelBuffer)
        guard (status == kCVReturnSuccess) else {
            return nil
        }
        
        CVPixelBufferLockBaseAddress(pixelBuffer!, CVPixelBufferLockFlags(rawValue: 0))
        let pixelData = CVPixelBufferGetBaseAddress(pixelBuffer!)
        
        let rgbColorSpace = CGColorSpaceCreateDeviceRGB()
        let context = CGContext(data: pixelData, width: Int(image.size.width), height: Int(image.size.height), bitsPerComponent: 8, bytesPerRow: CVPixelBufferGetBytesPerRow(pixelBuffer!), space: rgbColorSpace, bitmapInfo: CGImageAlphaInfo.noneSkipFirst.rawValue)
        
        context?.translateBy(x: 0, y: image.size.height)
        context?.scaleBy(x: 1.0, y: -1.0)
        
        UIGraphicsPushContext(context!)
        image.draw(in: CGRect(x: 0, y: 0, width: image.size.width, height: image.size.height))
        UIGraphicsPopContext()
        CVPixelBufferUnlockBaseAddress(pixelBuffer!, CVPixelBufferLockFlags(rawValue: 0))
        
        return pixelBuffer
    }

}
