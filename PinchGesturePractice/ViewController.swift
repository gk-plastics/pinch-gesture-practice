//
//  ViewController.swift
//  PinchGesturePractice
//
//  Created by gok on 2023/03/14.
//

import UIKit

class ViewController: UIViewController {
    private(set) weak var someView: UIView?
    private(set) weak var pinchGestureRecognizer: UIPinchGestureRecognizer?

    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        setupGestureRecognizers()
    }

    private func setupViews() {
        let someView = UIView(frame: CGRect(x: 50, y: 50, width: 200, height: 200))
        someView.backgroundColor = .red
        someView.center = view.center
        self.view.addSubview(someView)
        self.someView = someView
    }

    private func setupGestureRecognizers() {
        let pinchGestureRecognizer = UIPinchGestureRecognizer(target: self, action: #selector(someViewWasPinched))
        self.view.addGestureRecognizer(pinchGestureRecognizer)
        self.pinchGestureRecognizer = pinchGestureRecognizer
    }

    @objc private func someViewWasPinched(_ sender: UIPinchGestureRecognizer) {
        switch sender.state {
        case .began, .changed:
            zoom(scale: sender.scale, anchorPoint: sender.location(in: someView))
            sender.scale = 1.0
        default:
            break
        }
    }

    private func zoom(scale: CGFloat, anchorPoint: CGPoint) {
        guard let someView = someView else { return }
        var frame = someView.frame
        let newWidth = frame.width * scale
        let newHeight = frame.height * scale
        frame.origin.x -= (newWidth - frame.width) * anchorPoint.x / frame.width
        frame.origin.y -= (newHeight - frame.height) * anchorPoint.y / frame.height
        frame.size.width = newWidth
        frame.size.height = newHeight
        someView.frame = frame
    }
}

// MARK: -

final class ViewControllerA: UIViewController {
    private weak var someView: UIView? // Added to the view of SomeViewController
    private weak var pinchGestureRecognizer: UIPinchGestureRecognizer? // Added to the view of SomeViewController

    override func viewDidLoad() {
        super.viewDidLoad()
        addSomeView()
        addPinchGestureRecognizer()
    }

    private func addSomeView() {
        let someView = UIView(frame: CGRect(x: 0, y: 0, width: 200, height: 200))
        someView.backgroundColor = .red
        someView.center = view.center
        view.addSubview(someView)
        self.someView = someView
    }

    private func addPinchGestureRecognizer() {
        let pinchGestureRecognizer = UIPinchGestureRecognizer(target: self, action: #selector(someViewWasPinched(_:)))
        someView?.addGestureRecognizer(pinchGestureRecognizer)
        self.pinchGestureRecognizer = pinchGestureRecognizer
    }

    @objc private func someViewWasPinched(_ sender: UIPinchGestureRecognizer) {
        guard let someView = someView else { return }
        var scale: CGFloat = sender.scale
        scale = max(scale, 0.5) // Minimum scale
        scale = min(scale, 2.0) // Maximum scale

        // Calculate anchor point
        let pinchLocation = sender.location(in: someView)
        let anchorPoint = CGPoint(x: pinchLocation.x / someView.bounds.width, y: pinchLocation.y / someView.bounds.height)

        zoom(scale: scale, anchorPoint: anchorPoint)

        // Reset scale to avoid compounding
        sender.scale = 1.0
    }

    private func zoom(scale: CGFloat, anchorPoint: CGPoint) {
        guard let someView = someView else { return }
        var frame = someView.frame

        // Calculate new width and height
        let newWidth = frame.size.width * scale
        let newHeight = frame.size.height * scale

        // Calculate new origin x and y
        let newOriginX = frame.origin.x - (newWidth - frame.size.width) * anchorPoint.x
        let newOriginY = frame.origin.y - (newHeight - frame.size.height) * anchorPoint.y

        // Set new frame
        frame.origin.x = newOriginX
        frame.origin.y = newOriginY
        frame.size.width = newWidth
        frame.size.height = newHeight
        someView.frame = frame
    }
}

// MARK: -

final class ViewControllerB: UIViewController {
    private(set) weak var someView: UIView?
    private(set) weak var pinchGestureRecognizer: UIPinchGestureRecognizer?
    private(set) weak var doubleTapGestureRecognizer: UITapGestureRecognizer?

    private var originalSize: CGSize = CGSize(width: 200, height: 200)
    private var currentScale: CGFloat {
        guard let someView else { return 1.0 }
        let originalWidth = originalSize.width
        let currentWidth = someView.frame.width
        return currentWidth / originalWidth
    }
    private var isAlmostOriginalScale: Bool {
        return abs(currentScale - 1) < 0.001
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        let someView = UIView(frame: CGRect(origin: .zero, size: originalSize))
        someView.backgroundColor = .red
        someView.center = view.center
        view.addSubview(someView)
        self.someView = someView

        let pinchGestureRecognizer = UIPinchGestureRecognizer(target: self, action: #selector(someViewWasPinched(_:)))
        someView.addGestureRecognizer(pinchGestureRecognizer)
        self.pinchGestureRecognizer = pinchGestureRecognizer

        let doubleTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(someViewWasDoubleTapped(_:)))
        doubleTapGestureRecognizer.numberOfTapsRequired = 2
        someView.addGestureRecognizer(doubleTapGestureRecognizer)
        self.doubleTapGestureRecognizer = doubleTapGestureRecognizer
    }

    @objc private func someViewWasPinched(_ sender: UIPinchGestureRecognizer) {
        let anchor = sender.location(in: view)
        switch sender.state {
        case .began, .changed:
            zoom(scale: sender.scale, anchor: anchor)
            sender.scale = 1.0
        case .ended:
            if isAlmostOriginalScale { resetZoom() }
            sender.scale = 1.0
        default:
            break
        }
    }
    @objc private func someViewWasDoubleTapped(_ sender: UIPinchGestureRecognizer) {
        guard let someView else { return }
        let anchor = someView.frame.center
        print("==== currentScale: \(currentScale) ====")
        if isAlmostOriginalScale {
            // currentScale is almost original (1.0). scale to 2.0
            zoom(scale: 2.0, anchor: anchor, animated: true)
        } else {
            // currentScale is NOT 1.0 scale to 1 / currentScale
            resetZoom(animated: true)
        }
    }

    func zoom(scale: CGFloat, anchor: CGPoint) {
        print("scale: \(scale), anchor: \(anchor)")
        guard let someView = someView else { return }
        let frame = someView.frame
        someView.frame = scaleFrameA(frame: frame, scale: scale, anchor: anchor)
        //someView.frame = scaleFrameB(frame: frame, scale: scale, anchor: anchor)
        //someView.frame = scaleFrameC(frame: frame, scale: scale, anchor: anchor)
        print("==== currentScale: \(currentScale) ====")
    }
    // All the scaleFrame(A|B|C) method below do the same
    private func scaleFrameA(frame: CGRect, scale: CGFloat, anchor: CGPoint) -> CGRect {
        return frame.scaled(by: scale, anchor: anchor)
    }
    private func scaleFrameB(frame: CGRect, scale: CGFloat, anchor: CGPoint) -> CGRect {
        let relativeAnchor: CGPoint = CGPoint(x: anchor.x - frame.origin.x,
                                              y: anchor.y - frame.origin.y)
        return frame.scaled(by: scale, relativeAnchor: relativeAnchor)
    }
    private func scaleFrameC(frame: CGRect, scale: CGFloat, anchor: CGPoint) -> CGRect {
        let relativeAnchor: CGPoint = CGPoint(x: anchor.x - frame.origin.x,
                                              y: anchor.y - frame.origin.y)
        let relativeAnchorRatio = CGPoint(x: relativeAnchor.x / frame.width,
                                          y: relativeAnchor.y / frame.height)
        return frame.scaled(by: scale, relativeAnchorRatio: relativeAnchorRatio)
    }

    func zoom(scale: CGFloat, anchor: CGPoint, animated: Bool) {
        guard animated else { zoom(scale: scale, anchor: anchor); return }
        UIView.animate(withDuration: 0.3,
                       delay: 0,
                       options: [.curveEaseInOut],
                       animations: { [weak self] in
                        self?.zoom(scale: scale, anchor: anchor)
                       },
                       completion: nil)
    }

    func resetZoom() {
        guard let someView else { return }
        someView.frame.size = originalSize
        someView.center = view.center
    }
    func resetZoom(animated: Bool) {
        guard animated else { resetZoom(); return }
        UIView.animate(withDuration: 0.3,
                       delay: 0,
                       options: [.curveEaseInOut],
                       animations: { [weak self] in
                        self?.resetZoom()
                       },
                       completion: nil)
    }
}
