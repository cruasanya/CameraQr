//
//  QRFrameView.swift
//  ShopUsor
//
//  Created by Александр Новиков on 06.12.2024.
//

import Foundation
import UIKit

final class QRFrameView: UIView {
    let frameLayer = CAShapeLayer()

    var shapeCorners = Optional<[CGPoint]>.none {
        didSet {
            if let shapeCorners, shapeCorners != oldValue {
                setNeedsLayout()
                layoutIfNeeded()
            }
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        layer.addSublayer(frameLayer)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        frameLayer.frame = layer.bounds
        updateShapeLayer(shapeCorners ?? [bounds.origin,CGPoint(x: bounds.minX, y: bounds.maxY), CGPoint(x: bounds.maxX, y: bounds.maxY), CGPoint(x: bounds.maxX, y: bounds.minY)])
    }

    func updateShapeLayer(_ corners: [CGPoint]) {
        frameLayer.path = createCornerPath(coordinates: corners).cgPath
        frameLayer.strokeColor = UIColor.black.cgColor
        frameLayer.fillColor = nil
        frameLayer.lineWidth = 5
    }

    private func createCornerPath(coordinates: [CGPoint]) -> UIBezierPath {
        let path = UIBezierPath()
        let normalizedCorners = coordinates.map { $0 - frame.origin }

//        for i in 0..<normalizedCorners.count {
//            let currentPoint = normalizedCorners[i]
//            let nextPoint = normalizedCorners[(i + 1) % normalizedCorners.count]
//            path.move(to: currentPoint)
//            path.addLine(to: CGPoint(
//                x: currentPoint.x + 0.25 * (nextPoint.x - currentPoint.x),
//                y: currentPoint.y + 0.25 * (nextPoint.y - currentPoint.y)
//            ))
//            path.move(to: CGPoint(
//                x: currentPoint.x + 0.75 * (nextPoint.x - currentPoint.x),
//                y: currentPoint.y + 0.75 * (nextPoint.y - currentPoint.y)
//            ))
//            path.addLine(to: nextPoint)
//        }
        for i in 0..<normalizedCorners.count {
            let firstPoint = normalizedCorners[i]
            let cornerPoint = normalizedCorners[(i + 1) % normalizedCorners.count]
            let lastPoint = normalizedCorners[(i + 2) % normalizedCorners.count]
            path.move(to: firstPoint)
            path.move(to: CGPoint(
                x: firstPoint.x - 0.75 * (firstPoint.x - cornerPoint.x),
                y: firstPoint.y - 0.75 * (firstPoint.y - cornerPoint.y)
            ))
            path.addCurve(to: CGPoint(
                x: cornerPoint.x - 0.25 * (cornerPoint.x - lastPoint.x),
                y: cornerPoint.y - 0.25 * (cornerPoint.y - lastPoint.y)),
                          controlPoint1: cornerPoint,
                          controlPoint2: cornerPoint)
        }

        return path
    }
}

extension CGPoint {
    public static func -(lhs: CGPoint, rhs: CGPoint) -> CGPoint {
        .init(x: lhs.x - rhs.x,
              y: lhs.y - rhs.y)
    }

    public static func +(lhs: CGPoint, rhs: CGPoint) -> CGPoint {
        .init(x: lhs.x + rhs.x,
              y: lhs.y + rhs.y)
    }
}
