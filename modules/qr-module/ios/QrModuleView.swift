import ExpoModulesCore
import UIKit
import AVFoundation

class QrModuleView: UIView, AVCaptureMetadataOutputObjectsDelegate {
    private let captureSession = AVCaptureSession()
    private lazy var previewLayer: AVCaptureVideoPreviewLayer = {
        .init(session: captureSession)
    }()
    private var isScannerFrameSetup = false
    private var resetTimer: Timer?
    private let resetDelay: TimeInterval = 1
    private let scannerSize: CGFloat = 200
    private var scannerFrameView: QRFrameView = .init()

    var onCodeScanned = EventDispatcher()

    private var qrFrame: CGRect? {
        didSet {
            if qrFrame != oldValue {
                setNeedsLayout()
                layoutIfNeeded()
            }
        }
    }

    private var qrCorners: [CGPoint]? {
        didSet {
            if qrCorners != oldValue {
                setNeedsLayout()
                layoutIfNeeded()
            }
        }
    }

    private var centeredQrCorners: [CGPoint] {
        [
            CGPoint(x: centeredQrFrame.minX, y: centeredQrFrame.minY),
            CGPoint(x: centeredQrFrame.minX, y: centeredQrFrame.maxY),
            CGPoint(x: centeredQrFrame.maxX, y: centeredQrFrame.maxY),
            CGPoint(x: centeredQrFrame.maxX, y: centeredQrFrame.minY)
        ]
    }

    private var centeredQrFrame: CGRect {
        CGRect(
            origin: CGPoint(x: bounds.width/2 - scannerSize/2, y: bounds.height/2 - scannerSize/2),
            size: CGSize(width: scannerSize, height: scannerSize)
        )
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupScanner()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        previewLayer.frame = bounds
        scannerFrameView.frame = qrFrame ?? centeredQrFrame
        scannerFrameView.shapeCorners = qrCorners ?? centeredQrCorners
    }

    private func setupScanner() {
        translatesAutoresizingMaskIntoConstraints = false
        initializeCaptureSession()
        setupPreviewLayer()
        startCaptureSession()
        setupScannerFrame()
    }

    private func initializeCaptureSession() {
        guard let videoCaptureDevice = AVCaptureDevice.default(for: .video),
              let videoInput = try? AVCaptureDeviceInput(device: videoCaptureDevice),
              captureSession.canAddInput(videoInput) else { return }

        captureSession.addInput(videoInput)

        let metadataOutput = AVCaptureMetadataOutput()
        guard captureSession.canAddOutput(metadataOutput) else { return }

        captureSession.addOutput(metadataOutput)
        metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
        metadataOutput.metadataObjectTypes = [.qr]
    }

    private func setupPreviewLayer() {
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.frame = layer.bounds
        previewLayer.videoGravity = .resizeAspectFill
        layer.addSublayer(previewLayer)
    }

    private func startCaptureSession() {
        DispatchQueue.global(qos: .background).async {
            self.captureSession.startRunning()
        }
    }

    private func setupScannerFrame() {
        scannerFrameView.translatesAutoresizingMaskIntoConstraints = false
        scannerFrameView.frame = centeredQrFrame
        scannerFrameView.backgroundColor = .clear
        addSubview(scannerFrameView)
    }

    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        guard let metadataObject = metadataObjects.first as? AVMetadataMachineReadableCodeObject,
              metadataObject.type == .qr,
              let qrCodeObject = previewLayer.transformedMetadataObject(for: metadataObject) as? AVMetadataMachineReadableCodeObject else { return }
        updateScannerFrame(withFrame: qrCodeObject.bounds, withCorners: qrCodeObject.corners)

        if let stringValue = metadataObject.stringValue {
            onCodeScanned([
                "data": stringValue
            ])
            stopCaptureSession()
        }
    }
    private func updateScannerFrame(withFrame qrCodeFrame: CGRect, withCorners corners: [CGPoint]) {
        UIView.animate(withDuration: 0.25, delay: .zero, options: [.layoutSubviews, .beginFromCurrentState]) { [weak self] in
            guard let self = self else { return }
            self.qrFrame = qrCodeFrame
            self.qrCorners = corners
        }
    }


    private func resetScannerFrameDimensions() {
        UIView.animate(withDuration: 0.25, delay: .zero, options: [.layoutSubviews, .beginFromCurrentState]) { [weak self] in
            self?.qrFrame = nil
            self?.qrCorners = nil
        }
    }

    func stopCaptureSession() {
        captureSession.stopRunning()
        AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
        resetTimer?.invalidate()
    }




}
