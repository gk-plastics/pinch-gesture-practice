//
//  ViewController.swift
//  PinchGesturePractice
//
//  Created by gok on 2023/03/14.
//

import UIKit

final class ViewController: UIViewController {
    private(set) weak var gradientView: RadialGradientView?
    private(set) weak var pinchGestureRecognizer: UIPinchGestureRecognizer?
    private(set) weak var doubleTapGestureRecognizer: UITapGestureRecognizer?

    private var currentScale: CGFloat {
        guard let gradientView else { return 1.0 }
        if gradientView.transform.isIdentity == false {
            return gradientView.transform.scale // transform.scale is the custom extension property
        }
        let originalWidth = view.bounds.width
        let currentWidth = gradientView.frame.width
        return currentWidth / originalWidth
    }
    private var isAlmostOriginalScale: Bool {
        return abs(currentScale - 1) < 0.001
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        let someView = RadialGradientView(frame: CGRect(origin: .zero, size: view.bounds.size))
        someView.backgroundColor = .orange
        someView.center = view.center
        view.addSubview(someView)
        self.gradientView = someView

        let pinchGestureRecognizer = UIPinchGestureRecognizer(target: self, action: #selector(someViewWasPinched(_:)))
        view.addGestureRecognizer(pinchGestureRecognizer)
        self.pinchGestureRecognizer = pinchGestureRecognizer

        let doubleTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(someViewWasDoubleTapped(_:)))
        doubleTapGestureRecognizer.numberOfTapsRequired = 2
        view.addGestureRecognizer(doubleTapGestureRecognizer)
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
        guard let gradientView else { return }
        let anchor = gradientView.frame.center
        print("==== currentScale: \(currentScale) ====")
        if isAlmostOriginalScale {
            print("currentScale is almost original (1.0). scale to 2.0")
            zoom(scale: 2.0, anchor: anchor, animated: true)
        } else {
            print("currentScale is NOT 1.0. scale to 1 / currentScale")
            resetZoom(animated: true)
        }
    }

    func zoom(scale: CGFloat, anchor: CGPoint) {
        print("scale: \(scale), anchor: \(anchor)")
        guard let gradientView else { return }
        //let frame = gradientView.frame
        //gradientView.frame = scaleFrameA(frame: frame, scale: scale, anchor: anchor)
        //gradientView.frame = scaleFrameB(frame: frame, scale: scale, anchor: anchor)
        //gradientView.frame = scaleFrameC(frame: frame, scale: scale, anchor: anchor)
        self.transform(view: gradientView, scale: scale, anchor: anchor)
        print("==== currentScale: \(currentScale) ====")
    }
    // All the scaleFrame(A|B|C) methods below do the same
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
    // All scale the view using transform, without modifying frame
    private func transform(view: UIView, scale: CGFloat, anchor: CGPoint) {
        print("scale: \(scale) anchor: \(anchor)")
        print("viewFrame: \(view.frame) viewFrameCenter: \(view.frame.center)")
        print("viewBounds: \(view.bounds) viewBoundsCenter: \(view.bounds.center)")
        let relativeAnchor = view.convert(anchor, from: view.superview)
        let viewCenter = view.center // Never changes, regardless of the transform
        print("anchorInView: \(relativeAnchor)  viewCenter: \(viewCenter)")
        let tx = (relativeAnchor.x - viewCenter.x) * (1 - scale)
        let ty = (relativeAnchor.y - viewCenter.y) * (1 - scale)
        print("tx: \(tx)  ty: \(ty)")
        let t = CGAffineTransform(translationX: tx, y: ty)
        let s = CGAffineTransform(scaleX: scale, y: scale)
        view.transform = view.transform.concatenating(t.concatenating(s))
    }
    //
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
        guard let gradientView else { return }
        gradientView.center = view.center
        gradientView.layer.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        if gradientView.transform.isIdentity {
            gradientView.frame.size = view.bounds.size
        } else {
            gradientView.transform = .identity
        }
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

// MARK: -

final class RadialGradientView: UIView {
    var startColor: UIColor = .white
    var endColor: UIColor = .orange
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    override func draw(_ rect: CGRect) {
        let context = UIGraphicsGetCurrentContext()
        let colors = [startColor.cgColor, endColor.cgColor] as CFArray
        let center = CGPoint(x: bounds.midX, y: bounds.midY)
        let radius = min(bounds.width, bounds.height) / 2
        guard let gradient = CGGradient(colorsSpace: nil, colors: colors, locations: nil) else { assertionFailure(); return }
        context?.drawRadialGradient(gradient, startCenter: center, startRadius: 0, endCenter: center, endRadius: radius, options: .drawsBeforeStartLocation)
    }
}

// MARK: -

extension CGAffineTransform {
    var scale: Double {
        return sqrt(Double(a * a + c * c))
    }
}
