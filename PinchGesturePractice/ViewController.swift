//
//  ViewController.swift
//  PinchGesturePractice
//
//  Created by gok on 2023/03/14.
//

import UIKit

final class ViewController: UIViewController {
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
