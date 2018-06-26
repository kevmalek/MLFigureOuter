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
        
        cameraOutput.capturePhoto(with: settings, delegate: self)
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        
    }

    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        guard error == nil else {
            print(error!.localizedDescription)
            return
        }
        
        guard let data = photo.fileDataRepresentation() else { return }
        let imageToDisplay = UIImage(data: data)
        guard let pixelBuffer = photo.pixelBuffer else { return }
        
        let predictionInput = ShoesAndHandbagsPhase2Input(image: pixelBuffer)
        predictionOutput = try? ShoesAndHandbagsPhase2().prediction(input: predictionInput)
        performSegue(withIdentifier: "showProductMLDetails", sender: nil)
    }
}
