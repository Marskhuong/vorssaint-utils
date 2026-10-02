// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2026 Vorssaint

import CoreGraphics
import Foundation

// The companion is a small friend who lives in the Dynamic Island: a colored
// shape with two ink eyes and no mouth, or a little robot. It rests beside
// the camera when the closed island has nothing else to show, passes by now
// and then, and is the Command Bar's face when the bar comes out of the
// island. The code calls it the mascot, because "companion" already names
// the second activity sharing the closed island.

enum NotchMascotStyle: String, CaseIterable, Identifiable {
    case minimal, robot

    var id: String { rawValue }
}

enum NotchMascotShape: String, CaseIterable, Identifiable {
    case ball, egg, squircle, drop, pill

    var id: String { rawValue }
}

/// sRGB components, so the model needs no AppKit.
struct NotchMascotColor: Equatable {
    let red: CGFloat
    let green: CGFloat
    let blue: CGFloat
    var alpha: CGFloat = 1

    var cgColor: CGColor { CGColor(srgbRed: red, green: green, blue: blue, alpha: alpha) }

    /// The eyes, a soft black that still reads on the black island's edge.
    static let ink = NotchMascotColor(red: 0.07, green: 0.07, blue: 0.08)
    /// The robot's face plate, where its lit eyes sit.
    static let visor = NotchMascotColor(red: 0.09, green: 0.09, blue: 0.11)
    static let shine = NotchMascotColor(red: 1, green: 1, blue: 1, alpha: 0.55)
}

enum NotchMascotPalette: String, CaseIterable, Identifiable {
    case pearl, mint, peach, lilac, lemon, rose

    var id: String { rawValue }

    /// The body's lit top.
    var light: NotchMascotColor {
        switch self {
        case .pearl: return NotchMascotColor(red: 0.99, green: 0.98, blue: 0.96)
        case .mint: return NotchMascotColor(red: 0.72, green: 0.97, blue: 0.86)
        case .peach: return NotchMascotColor(red: 1.00, green: 0.86, blue: 0.74)
        case .lilac: return NotchMascotColor(red: 0.88, green: 0.83, blue: 1.00)
        case .lemon: return NotchMascotColor(red: 1.00, green: 0.96, blue: 0.64)
        case .rose: return NotchMascotColor(red: 1.00, green: 0.80, blue: 0.87)
        }
    }

    /// The body's shaded bottom, and the robot's antenna and bolts.
    var shade: NotchMascotColor {
        switch self {
        case .pearl: return NotchMascotColor(red: 0.84, green: 0.85, blue: 0.90)
        case .mint: return NotchMascotColor(red: 0.40, green: 0.83, blue: 0.66)
        case .peach: return NotchMascotColor(red: 0.98, green: 0.64, blue: 0.50)
        case .lilac: return NotchMascotColor(red: 0.69, green: 0.59, blue: 0.96)
        case .lemon: return NotchMascotColor(red: 0.97, green: 0.83, blue: 0.30)
        case .rose: return NotchMascotColor(red: 0.95, green: 0.54, blue: 0.68)
        }
    }
}

struct NotchMascotLook: Equatable {
    var style: NotchMascotStyle
    var shape: NotchMascotShape
    var palette: NotchMascotPalette

    static let standard = NotchMascotLook(style: .minimal, shape: .ball, palette: .pearl)
}

enum NotchMascotMood: String, CaseIterable, Identifiable {
    case idle, happy, wink, love, sleepy, determined, surprised, searching, thinking, confused

    var id: String { rawValue }

    /// The faces the Settings preview shows, one per click.
    static let showcase: [NotchMascotMood] = [.happy, .wink, .love, .sleepy, .determined,
                                              .surprised, .searching, .thinking, .confused]
}

/// How the Command Bar comes out of the island.
enum NotchCommandBarStyle: String, CaseIterable, Identifiable {
    /// A drop falls from the island's lower edge and opens into the bar.
    case droplet
    /// The bar opens inside the open island.
    case island

    var id: String { rawValue }
}

/// Where the Command Bar shows when it opens.
enum CommandBarPresentation: Equatable {
    /// Its own window, as it always has.
    case window
    /// A window below the island, reached by a falling drop.
    case droplet
    /// Inside the open island.
    case island
}

enum NotchMascotEye: Equatable {
    case open, closed, happy, heart, sleepy, wide, squint
    /// The lid slants down toward the other eye.
    case determined

    var blinks: Bool { self == .open || self == .wide || self == .squint }
}

struct NotchMascotExpression: Equatable {
    var left: NotchMascotEye
    var right: NotchMascotEye
    /// Where the eyes look, in shares of the companion's size. Y grows downward.
    var gaze: CGPoint = .zero
    /// The head's lean in radians, clockwise on screen.
    var tilt: CGFloat = 0

    /// Open eyes blink now and then. Closed, curved or heart eyes do not.
    var blinks: Bool { left.blinks && right.blinks }
}

extension NotchMascotMood {
    var expression: NotchMascotExpression {
        switch self {
        case .idle: return NotchMascotExpression(left: .open, right: .open)
        case .happy: return NotchMascotExpression(left: .happy, right: .happy, gaze: CGPoint(x: 0, y: -0.02))
        case .wink: return NotchMascotExpression(left: .open, right: .happy, tilt: -0.08)
        case .love: return NotchMascotExpression(left: .heart, right: .heart)
        case .sleepy: return NotchMascotExpression(left: .sleepy, right: .sleepy, gaze: CGPoint(x: 0, y: 0.03), tilt: 0.05)
        case .determined: return NotchMascotExpression(left: .determined, right: .determined)
        case .surprised: return NotchMascotExpression(left: .wide, right: .wide, gaze: CGPoint(x: 0, y: -0.02))
        case .searching: return NotchMascotExpression(left: .open, right: .open, gaze: CGPoint(x: 0.05, y: 0))
        case .thinking: return NotchMascotExpression(left: .squint, right: .open, gaze: CGPoint(x: 0.06, y: -0.06), tilt: -0.1)
        case .confused: return NotchMascotExpression(left: .open, right: .squint, gaze: CGPoint(x: -0.03, y: 0.01), tilt: 0.14)
        }
    }
}

/// Where the face sits on each body, in shares of the companion's size from
/// its top left corner.
struct NotchMascotFaceLayout: Equatable {
    let leftEye: CGPoint
    let rightEye: CGPoint
    /// An open eye's width and height.
    let eyeSize: CGSize
    /// The soft highlight on the body: its center, radii and lean.
    let shineCenter: CGPoint
    let shineRadii: CGSize
    let shineAngle: CGFloat
}

extension NotchMascotLook {
    var face: NotchMascotFaceLayout {
        if style == .robot {
            return NotchMascotFaceLayout(leftEye: CGPoint(x: 0.36, y: 0.63), rightEye: CGPoint(x: 0.64, y: 0.63),
                                         eyeSize: CGSize(width: 0.085, height: 0.16),
                                         shineCenter: CGPoint(x: 0.27, y: 0.34), shineRadii: CGSize(width: 0.07, height: 0.04),
                                         shineAngle: -0.3)
        }
        switch shape {
        case .ball:
            return NotchMascotFaceLayout(leftEye: CGPoint(x: 0.36, y: 0.50), rightEye: CGPoint(x: 0.64, y: 0.50),
                                         eyeSize: CGSize(width: 0.10, height: 0.20),
                                         shineCenter: CGPoint(x: 0.31, y: 0.29), shineRadii: CGSize(width: 0.085, height: 0.055),
                                         shineAngle: -0.5)
        case .egg:
            return NotchMascotFaceLayout(leftEye: CGPoint(x: 0.375, y: 0.55), rightEye: CGPoint(x: 0.625, y: 0.55),
                                         eyeSize: CGSize(width: 0.095, height: 0.19),
                                         shineCenter: CGPoint(x: 0.33, y: 0.31), shineRadii: CGSize(width: 0.075, height: 0.05),
                                         shineAngle: -0.6)
        case .squircle:
            return NotchMascotFaceLayout(leftEye: CGPoint(x: 0.35, y: 0.53), rightEye: CGPoint(x: 0.65, y: 0.53),
                                         eyeSize: CGSize(width: 0.10, height: 0.20),
                                         shineCenter: CGPoint(x: 0.24, y: 0.28), shineRadii: CGSize(width: 0.08, height: 0.05),
                                         shineAngle: -0.55)
        case .drop:
            return NotchMascotFaceLayout(leftEye: CGPoint(x: 0.375, y: 0.62), rightEye: CGPoint(x: 0.625, y: 0.62),
                                         eyeSize: CGSize(width: 0.095, height: 0.18),
                                         shineCenter: CGPoint(x: 0.33, y: 0.45), shineRadii: CGSize(width: 0.07, height: 0.05),
                                         shineAngle: -0.7)
        case .pill:
            return NotchMascotFaceLayout(leftEye: CGPoint(x: 0.37, y: 0.57), rightEye: CGPoint(x: 0.63, y: 0.57),
                                         eyeSize: CGSize(width: 0.09, height: 0.19),
                                         shineCenter: CGPoint(x: 0.20, y: 0.42), shineRadii: CGSize(width: 0.07, height: 0.045),
                                         shineAngle: -0.45)
        }
    }
}

/// Outlines in a square of `size` points, from its top left corner.
enum NotchMascotGeometry {
    /// Every eye is drawn with this many curves, so any eye can turn into
    /// any other one point at a time.
    static let eyeCurveCount = 24

    static func body(_ shape: NotchMascotShape, size: CGFloat) -> CGPath {
        let path = CGMutablePath()
        func point(_ x: CGFloat, _ y: CGFloat) -> CGPoint { CGPoint(x: x * size, y: y * size) }
        switch shape {
        case .ball:
            path.addEllipse(in: CGRect(x: 0.08 * size, y: 0.12 * size, width: 0.84 * size, height: 0.84 * size))
        case .egg:
            path.move(to: point(0.5, 0.10))
            path.addCurve(to: point(0.86, 0.60), control1: point(0.71, 0.10), control2: point(0.86, 0.36))
            path.addCurve(to: point(0.5, 0.96), control1: point(0.86, 0.80), control2: point(0.70, 0.96))
            path.addCurve(to: point(0.14, 0.60), control1: point(0.30, 0.96), control2: point(0.14, 0.80))
            path.addCurve(to: point(0.5, 0.10), control1: point(0.14, 0.36), control2: point(0.29, 0.10))
            path.closeSubpath()
        case .squircle:
            // A superellipse: flatter sides than a rounded rectangle, no corner seam.
            let count = 72
            for index in 0..<count {
                let angle = CGFloat(index) / CGFloat(count) * 2 * .pi
                let cosine = cos(angle), sine = sin(angle)
                let exponent: CGFloat = 2 / 3.4
                let x = 0.5 + 0.43 * (cosine < 0 ? -1 : 1) * pow(abs(cosine), exponent)
                let y = 0.55 + 0.40 * (sine < 0 ? -1 : 1) * pow(abs(sine), exponent)
                if index == 0 { path.move(to: point(x, y)) } else { path.addLine(to: point(x, y)) }
            }
            path.closeSubpath()
        case .drop:
            path.move(to: point(0.53, 0.085))
            path.addCurve(to: point(0.84, 0.62), control1: point(0.60, 0.20), control2: point(0.84, 0.40))
            path.addCurve(to: point(0.5, 0.96), control1: point(0.84, 0.81), control2: point(0.69, 0.96))
            path.addCurve(to: point(0.16, 0.62), control1: point(0.31, 0.96), control2: point(0.16, 0.81))
            path.addCurve(to: point(0.47, 0.085), control1: point(0.16, 0.40), control2: point(0.40, 0.20))
            path.addCurve(to: point(0.53, 0.085), control1: point(0.49, 0.06), control2: point(0.51, 0.06))
            path.closeSubpath()
        case .pill:
            path.addRoundedRect(in: CGRect(x: 0.05 * size, y: 0.28 * size, width: 0.90 * size, height: 0.60 * size),
                                cornerWidth: 0.30 * size, cornerHeight: 0.30 * size)
        }
        return path
    }

    /// The robot's head, ears, antenna and face plate.
    struct Robot {
        let head: CGPath
        let ears: CGPath
        let antenna: CGPath
        let bulb: CGPath
        let visor: CGPath
    }

    static func robot(size: CGFloat) -> Robot {
        func rect(_ x: CGFloat, _ y: CGFloat, _ width: CGFloat, _ height: CGFloat) -> CGRect {
            CGRect(x: x * size, y: y * size, width: width * size, height: height * size)
        }
        func rounded(_ rect: CGRect, _ radius: CGFloat) -> CGPath {
            CGPath(roundedRect: rect, cornerWidth: radius * size, cornerHeight: radius * size, transform: nil)
        }
        let ears = CGMutablePath()
        ears.addPath(rounded(rect(0.05, 0.50, 0.08, 0.20), 0.035))
        ears.addPath(rounded(rect(0.87, 0.50, 0.08, 0.20), 0.035))
        return Robot(head: rounded(rect(0.12, 0.26, 0.76, 0.68), 0.20),
                     ears: ears,
                     antenna: rounded(rect(0.475, 0.12, 0.05, 0.16), 0.025),
                     bulb: CGPath(ellipseIn: rect(0.43, 0.04, 0.14, 0.14), transform: nil),
                     visor: rounded(rect(0.20, 0.44, 0.60, 0.38), 0.15))
    }

    /// The highlight, an ellipse leaning with the body's curve.
    static func shine(_ face: NotchMascotFaceLayout, size: CGFloat) -> CGPath {
        var transform = CGAffineTransform(translationX: face.shineCenter.x * size, y: face.shineCenter.y * size)
            .rotated(by: face.shineAngle)
        let radii = CGSize(width: face.shineRadii.width * size, height: face.shineRadii.height * size)
        return CGPath(ellipseIn: CGRect(x: -radii.width, y: -radii.height, width: radii.width * 2, height: radii.height * 2),
                      transform: &transform)
    }

    /// An eye's outline around `center`. `size` is an open eye's width and
    /// height, and the right eye mirrors the left one.
    static func eye(_ eye: NotchMascotEye, size: CGSize, center: CGPoint, right: Bool) -> CGPath {
        let points = eyePoints(eye, size: size, right: right).map {
            CGPoint(x: $0.x + center.x, y: $0.y + center.y)
        }
        return smoothClosedPath(points)
    }

    /// The eye's outline as `eyeCurveCount` points, from the top of its
    /// middle line, clockwise on screen.
    static func eyePoints(_ eye: NotchMascotEye, size: CGSize, right: Bool) -> [CGPoint] {
        let width = max(0.5, size.width), height = max(0.5, size.height)
        var outline: [CGPoint]
        switch eye {
        case .open:
            outline = stadium(width: width, height: height, center: .zero)
        case .closed:
            outline = stadium(width: width * 1.5, height: width * 0.45, center: CGPoint(x: 0, y: height * 0.12))
        case .squint:
            outline = stadium(width: width, height: height * 0.55, center: CGPoint(x: 0, y: height * 0.08))
        case .wide:
            outline = ellipse(radii: CGSize(width: width * 0.8, height: width * 0.8), center: CGPoint(x: 0, y: -height * 0.02))
        case .happy:
            outline = arch(span: width * 2.1, rise: height * 0.42, thickness: width * 0.55, top: -height * 0.18)
        case .heart:
            outline = heart(width: width * 2.0, height: width * 1.8, center: CGPoint(x: 0, y: -height * 0.02))
        case .sleepy:
            outline = lid(width: width * 1.25, top: height * 0.02, depth: height * 0.38)
        case .determined:
            // The left eye's lid falls toward the nose, on its right.
            outline = clipBelow(stadium(width: width, height: height, center: .zero),
                                from: CGPoint(x: -width / 2, y: -height * 0.30),
                                to: CGPoint(x: width / 2, y: height * 0.02))
        }
        if right { outline = outline.map { CGPoint(x: -$0.x, y: $0.y) } }
        return resample(outline, count: eyeCurveCount)
    }

    // MARK: Outlines

    private static let dense = 96

    /// A capsule standing on its round ends, or lying on them when wider.
    private static func stadium(width: CGFloat, height: CGFloat, center: CGPoint) -> [CGPoint] {
        let radius = min(width, height) / 2
        let rect = CGRect(x: center.x - width / 2, y: center.y - height / 2, width: width, height: height)
        return roundedRect(rect, radius: radius)
    }

    private static func roundedRect(_ rect: CGRect, radius: CGFloat) -> [CGPoint] {
        let corners: [(CGPoint, CGFloat)] = [
            (CGPoint(x: rect.maxX - radius, y: rect.minY + radius), -.pi / 2),
            (CGPoint(x: rect.maxX - radius, y: rect.maxY - radius), 0),
            (CGPoint(x: rect.minX + radius, y: rect.maxY - radius), .pi / 2),
            (CGPoint(x: rect.minX + radius, y: rect.minY + radius), .pi),
        ]
        var points: [CGPoint] = []
        let steps = dense / 4
        for (center, start) in corners {
            for step in 0...steps {
                let angle = start + CGFloat(step) / CGFloat(steps) * .pi / 2
                points.append(CGPoint(x: center.x + radius * cos(angle), y: center.y + radius * sin(angle)))
            }
        }
        return points
    }

    private static func ellipse(radii: CGSize, center: CGPoint) -> [CGPoint] {
        (0..<dense).map { index in
            let angle = -CGFloat.pi / 2 + CGFloat(index) / CGFloat(dense) * 2 * .pi
            return CGPoint(x: center.x + radii.width * cos(angle), y: center.y + radii.height * sin(angle))
        }
    }

    /// Eyes shut with a smile: a band bent upward, round at both ends.
    private static func arch(span: CGFloat, rise: CGFloat, thickness: CGFloat, top: CGFloat) -> [CGPoint] {
        let half = max(0.1, span / 2 - thickness / 2)
        let lift = max(0.1, rise)
        let radius = (half * half + lift * lift) / (2 * lift)
        let apex = top + thickness / 2
        let center = CGPoint(x: 0, y: apex + radius)
        let reach = asin(min(1, half / radius))
        func onArc(_ angle: CGFloat, _ radius: CGFloat) -> CGPoint {
            CGPoint(x: center.x + radius * sin(angle), y: center.y - radius * cos(angle))
        }
        let steps = dense / 3
        var points: [CGPoint] = []
        for step in 0...steps {
            points.append(onArc(-reach + CGFloat(step) / CGFloat(steps) * reach * 2, radius + thickness / 2))
        }
        // The right end's round cap, from the outer arc to the inner one.
        let rightEnd = onArc(reach, radius)
        for step in 1..<12 {
            let angle = reach + CGFloat(step) / 12 * .pi
            points.append(CGPoint(x: rightEnd.x + thickness / 2 * sin(angle), y: rightEnd.y - thickness / 2 * cos(angle)))
        }
        for step in 0...steps {
            points.append(onArc(reach - CGFloat(step) / CGFloat(steps) * reach * 2, radius - thickness / 2))
        }
        let leftEnd = onArc(-reach, radius)
        for step in 1..<12 {
            let angle = -reach + .pi + CGFloat(step) / 12 * .pi
            points.append(CGPoint(x: leftEnd.x + thickness / 2 * sin(angle), y: leftEnd.y - thickness / 2 * cos(angle)))
        }
        return points
    }

    private static func heart(width: CGFloat, height: CGFloat, center: CGPoint) -> [CGPoint] {
        // The classic heart curve, 32 wide and about 29 tall, with y up.
        let raw: [CGPoint] = (0..<dense).map { index in
            let t = CGFloat(index) / CGFloat(dense) * 2 * .pi
            let x = 16 * pow(sin(t), 3)
            let y = 13 * cos(t) - 5 * cos(2 * t) - 2 * cos(3 * t) - cos(4 * t)
            return CGPoint(x: x, y: y)
        }
        let minY = raw.map(\.y).min() ?? 0, maxY = raw.map(\.y).max() ?? 1
        let middle = (minY + maxY) / 2
        return raw.map {
            CGPoint(x: center.x + $0.x / 32 * width,
                    y: center.y - ($0.y - middle) / (maxY - minY) * height)
        }
    }

    /// A drowsy eye: the lid's flat edge on top, the eye's round bottom below.
    private static func lid(width: CGFloat, top: CGFloat, depth: CGFloat) -> [CGPoint] {
        let half = width / 2
        var points: [CGPoint] = []
        let flat = dense / 4
        for step in 0...flat {
            points.append(CGPoint(x: -half + CGFloat(step) / CGFloat(flat) * width, y: top))
        }
        let round = dense - flat
        for step in 1..<round {
            let angle = CGFloat(step) / CGFloat(round) * .pi
            points.append(CGPoint(x: half * cos(angle), y: top + depth * sin(angle)))
        }
        return points
    }

    /// The part of a convex outline below the line from `from` to `to`.
    private static func clipBelow(_ points: [CGPoint], from: CGPoint, to: CGPoint) -> [CGPoint] {
        func side(_ point: CGPoint) -> CGFloat {
            // Positive below the line, with y growing downward.
            (to.x - from.x) * (point.y - from.y) - (to.y - from.y) * (point.x - from.x)
        }
        var clipped: [CGPoint] = []
        for index in points.indices {
            let current = points[index], next = points[(index + 1) % points.count]
            let a = side(current), b = side(next)
            if a >= 0 { clipped.append(current) }
            if (a >= 0) != (b >= 0) {
                let share = a / (a - b)
                clipped.append(CGPoint(x: current.x + (next.x - current.x) * share,
                                       y: current.y + (next.y - current.y) * share))
            }
        }
        return clipped.count >= 3 ? clipped : points
    }

    // MARK: Resampling

    /// `count` points evenly spaced along the outline, starting where its top
    /// crosses the middle line and going clockwise on screen. Every eye then
    /// has its points in the same places, which is what lets one become another.
    static func resample(_ outline: [CGPoint], count: Int) -> [CGPoint] {
        guard outline.count >= 3, count >= 3 else { return outline }
        var points = outline
        // Clockwise on screen, with y growing downward, is a positive area.
        var area: CGFloat = 0
        for index in points.indices {
            let a = points[index], b = points[(index + 1) % points.count]
            area += a.x * b.y - b.x * a.y
        }
        if area < 0 { points.reverse() }
        // The start: the highest place where the outline crosses x = 0.
        var start: (index: Int, point: CGPoint)?
        for index in points.indices {
            let a = points[index], b = points[(index + 1) % points.count]
            guard (a.x <= 0 && b.x > 0) || (a.x >= 0 && b.x < 0) || a.x == 0 else { continue }
            let share = b.x == a.x ? 0 : -a.x / (b.x - a.x)
            let crossing = CGPoint(x: 0, y: a.y + (b.y - a.y) * share)
            if start == nil || crossing.y < start!.point.y { start = (index, crossing) }
        }
        guard let start else { return Array(points.prefix(count)) }
        var walk = [start.point]
        for offset in 1...points.count {
            walk.append(points[(start.index + offset) % points.count])
        }
        walk.append(start.point)
        var lengths: [CGFloat] = [0]
        for index in 1..<walk.count {
            lengths.append(lengths[index - 1] + hypot(walk[index].x - walk[index - 1].x, walk[index].y - walk[index - 1].y))
        }
        let total = lengths.last ?? 0
        guard total > 0 else { return Array(repeating: start.point, count: count) }
        var result: [CGPoint] = []
        var segment = 1
        for step in 0..<count {
            let target = total * CGFloat(step) / CGFloat(count)
            while segment < lengths.count - 1, lengths[segment] < target { segment += 1 }
            let span = lengths[segment] - lengths[segment - 1]
            let share = span > 0 ? (target - lengths[segment - 1]) / span : 0
            let a = walk[segment - 1], b = walk[segment]
            result.append(CGPoint(x: a.x + (b.x - a.x) * share, y: a.y + (b.y - a.y) * share))
        }
        return result
    }

    /// A closed curve through every point, one cubic per point.
    static func smoothClosedPath(_ points: [CGPoint]) -> CGPath {
        let path = CGMutablePath()
        let count = points.count
        guard count >= 3 else { return path }
        path.move(to: points[0])
        for index in 0..<count {
            let previous = points[(index - 1 + count) % count]
            let current = points[index]
            let next = points[(index + 1) % count]
            let after = points[(index + 2) % count]
            let first = CGPoint(x: current.x + (next.x - previous.x) / 6, y: current.y + (next.y - previous.y) / 6)
            let second = CGPoint(x: next.x - (after.x - current.x) / 6, y: next.y - (after.y - current.y) / 6)
            path.addCurve(to: next, control1: first, control2: second)
        }
        path.closeSubpath()
        return path
    }
}

/// One stroll of the companion through the closed island.
struct NotchMascotVisit: Equatable {
    enum Kind: Equatable {
        /// From its resting place, around the island and back.
        case lap
        /// In at one end and out at the other, over what the island shows at rest.
        case pass
        /// Back from the Command Bar's drop: out from behind the camera to its place.
        case home
    }

    let id: UUID
    let kind: Kind
    let greeting: NotchMascotMood
    /// When it began, on the media clock, so a strip drawn again meanwhile
    /// picks it up where it is.
    let start: CFTimeInterval

    var duration: TimeInterval { NotchMascotMotion.duration(of: kind) }
}

/// Where the companion can walk in a closed strip, in points from the
/// strip's top left corner.
struct NotchMascotTrack: Equatable {
    var width: CGFloat
    var height: CGFloat
    /// The companion's square.
    var size: CGFloat
    /// Its center while resting.
    var rest: CGFloat
    /// The camera: walking there, it is behind it.
    var hidden: ClosedRange<CGFloat>?
    /// The height of its center.
    var baseline: CGFloat
    /// The top of the island over it: the screen's edge, or a capsule's.
    var ceiling: CGFloat = 0

    /// How high a hop of `share` of its size lifts it, kept clear of the
    /// island's top so it never brushes the screen's edge or a capsule's.
    func hop(_ share: CGFloat) -> CGFloat {
        min(size * share, max(1, baseline - size / 2 - ceiling - (hidden == nil ? 1 : 2)))
    }

    /// Where it says hello across the strip: past the camera, as far from it
    /// as it rests, or toward a capsule's far end.
    var farSpot: CGFloat {
        guard let hidden else { return min(width - size * 0.8, rest + width * 0.22) }
        return hidden.upperBound + (hidden.lowerBound - rest)
    }
}

/// The companion's walk, sampled densely enough for Core Animation to play
/// as given: where it is, how high a hop lifts it, how much a landing
/// squashes it and where it looks.
struct NotchMascotPath: Equatable {
    var keyTimes: [Double] = []
    var x: [CGFloat] = []
    var lift: [CGFloat] = []
    /// Positive squashes it flat, negative stretches it tall.
    var squash: [CGFloat] = []
    /// Where its eyes look across, in shares of its size.
    var gaze: [CGFloat] = []
    var duration: TimeInterval = 0
    /// When its greeting face shows, in seconds from the start.
    var greeting: ClosedRange<TimeInterval> = 0...0
}

enum NotchMascotMotion {
    static let lapDuration: TimeInterval = 3.6
    static let passDuration: TimeInterval = 3.4
    static let homeDuration: TimeInterval = 0.62

    static func duration(of kind: NotchMascotVisit.Kind) -> TimeInterval {
        switch kind {
        case .lap: return lapDuration
        case .pass: return passDuration
        case .home: return homeDuration
        }
    }

    static func path(for kind: NotchMascotVisit.Kind, on track: NotchMascotTrack) -> NotchMascotPath {
        switch kind {
        case .lap: return lap(on: track)
        case .pass: return pass(on: track)
        case .home: return home(on: track)
        }
    }

    private enum Step {
        case stay(TimeInterval, bounces: Int = 0)
        case hop(to: CGFloat, TimeInterval, height: CGFloat)
        case walk(to: CGFloat, TimeInterval)
        case jump(to: CGFloat)
    }

    /// From its resting place behind the camera to the other side, a hello,
    /// out at the far end and back in at the near one to rest again.
    static func lap(on track: NotchMascotTrack) -> NotchMascotPath {
        let size = track.size
        let offstageRight = track.width + size
        let offstageLeft = -size
        var steps: [Step] = [.stay(0.18)]
        if let hidden = track.hidden {
            steps += [.hop(to: hidden.lowerBound + size / 2 + 2, 0.34, height: track.hop(0.24)),
                      .walk(to: hidden.upperBound - size / 2 - 2, 0.50),
                      .hop(to: track.farSpot, 0.34, height: track.hop(0.24))]
        } else {
            steps += [.hop(to: track.farSpot, 0.60, height: track.hop(0.3)), .stay(0.58)]
        }
        steps += [.stay(0.94, bounces: 2),
                  .walk(to: offstageRight, 0.40),
                  .jump(to: offstageLeft),
                  .hop(to: track.rest, 0.52, height: track.hop(0.26))]
        var path = sample(steps, start: track.rest, track: track, duration: lapDuration)
        let greetStart: TimeInterval = track.hidden == nil ? 0.78 : 1.30
        path.greeting = greetStart...(greetStart + 1.0)
        return path
    }

    /// In at the near end, a hello on that side, behind the camera, out at the far end.
    static func pass(on track: NotchMascotTrack) -> NotchMascotPath {
        let size = track.size
        var steps: [Step] = [.stay(0.20), .hop(to: track.rest, 0.42, height: track.hop(0.26)), .stay(0.88, bounces: 2)]
        if let hidden = track.hidden {
            steps += [.hop(to: hidden.lowerBound + size / 2 + 2, 0.34, height: track.hop(0.24)),
                      .walk(to: hidden.upperBound - size / 2 - 2, 0.50),
                      .hop(to: track.farSpot, 0.34, height: track.hop(0.24)),
                      .stay(0.22)]
        } else {
            steps += [.hop(to: track.farSpot, 0.60, height: track.hop(0.3)), .stay(0.80)]
        }
        steps += [.walk(to: track.width + size, 0.40)]
        var path = sample(steps, start: -size, track: track, duration: passDuration)
        path.greeting = 0.55...1.55
        return path
    }

    /// Back from the drop that rose into the island behind the camera: out
    /// from behind it with a little hop to its place, still wearing the face
    /// it left the bar with until it lands. A capsule has no camera, so it
    /// lands where it rests.
    static func home(on track: NotchMascotTrack) -> NotchMascotPath {
        let size = track.size
        guard let hidden = track.hidden else {
            var path = sample([.stay(0.08), .hop(to: track.rest, 0.36, height: track.hop(0.2))],
                              start: track.rest, track: track, duration: homeDuration)
            path.greeting = 0...0.4
            return path
        }
        var path = sample([.stay(0.06), .hop(to: track.rest, 0.42, height: track.hop(0.2))],
                          start: hidden.lowerBound + size / 2 + 2, track: track, duration: homeDuration)
        path.greeting = 0...0.44
        return path
    }

    private static func sample(_ steps: [Step], start: CGFloat, track: NotchMascotTrack,
                               duration: TimeInterval) -> NotchMascotPath {
        let rate: Double = 60
        var path = NotchMascotPath()
        var time: TimeInterval = 0
        var position = start
        // A landing's squash eases out over the start of the next step.
        var landing: (squash: CGFloat, time: TimeInterval) = (0, 0)
        func add(_ x: CGFloat, lift: CGFloat, squash: CGFloat, gaze: CGFloat) {
            let recovery = landing.squash * CGFloat(max(0, 1 - (time - landing.time) / 0.14))
            path.keyTimes.append(min(1, time / duration))
            path.x.append(x)
            path.lift.append(lift)
            path.squash.append(squash != 0 ? squash : recovery)
            path.gaze.append(gaze)
        }
        add(position, lift: 0, squash: 0, gaze: 0)
        for step in steps {
            switch step {
            case .jump(let target):
                // Off stage at both ends, and in no time: two frames at the
                // same moment, so no frame ever draws it on the way across.
                position = target
                add(position, lift: 0, squash: 0, gaze: 0.05)
            case .stay(let length, let bounces):
                let frames = max(1, Int((length * rate).rounded()))
                for frame in 1...frames {
                    let share = CGFloat(frame) / CGFloat(frames)
                    time += length / Double(frames)
                    let wave = bounces > 0 ? abs(sin(share * .pi * CGFloat(bounces))) : 0
                    add(position, lift: wave * track.hop(0.16), squash: 0, gaze: 0)
                }
            case .hop(let target, let length, let height):
                let from = position
                let frames = max(2, Int((length * rate).rounded()))
                let direction: CGFloat = target >= from ? 1 : -1
                for frame in 1...frames {
                    let share = CGFloat(frame) / CGFloat(frames)
                    time += length / Double(frames)
                    // Eased along the ground, a parabola above it.
                    let eased = share * share * (3 - 2 * share)
                    let squash: CGFloat = share < 0.2 ? -0.12 * (1 - share / 0.2) : share > 0.88 ? 0.14 * (share - 0.88) / 0.12 : 0
                    add(from + (target - from) * eased, lift: height * 4 * share * (1 - share),
                        squash: squash, gaze: 0.05 * direction)
                }
                position = target
                landing = (0.14, time)
            case .walk(let target, let length):
                let from = position
                let frames = max(2, Int((length * rate).rounded()))
                let direction: CGFloat = target >= from ? 1 : -1
                for frame in 1...frames {
                    let share = CGFloat(frame) / CGFloat(frames)
                    time += length / Double(frames)
                    // Little steps: a small bob on each.
                    let bob = abs(sin(share * .pi * 3)) * track.hop(0.06)
                    add(from + (target - from) * share, lift: bob, squash: 0, gaze: 0.05 * direction)
                }
                position = target
            }
        }
        // The last step lands, and it stays for whatever time is left.
        if time < duration {
            time = duration
            add(position, lift: 0, squash: 0, gaze: 0)
        } else if let last = path.keyTimes.indices.last {
            path.keyTimes[last] = 1
        }
        path.duration = duration
        return path
    }
}

enum NotchMascotSupport {
    /// Visits come every few minutes, never on a fixed beat.
    static let visitDelay: ClosedRange<TimeInterval> = 240...540
    /// Turned on in Settings, the companion says hello almost at once.
    static let welcomeDelay: TimeInterval = 1.5
    static let greetings: [NotchMascotMood] = [.happy, .wink, .love]
    /// After this many blinks at rest, about three minutes, its eyes grow heavy.
    static let blinksBeforeSleep = 36
    /// A blink comes this long after the previous one.
    static let blinkInterval: ClosedRange<TimeInterval> = 2.6...6.4

    static func isEnabled(in defaults: UserDefaults = .standard) -> Bool {
        NotchSupport.isEnabled(in: defaults) && defaults.bool(forKey: DefaultsKey.notchMascotEnabled)
    }

    static func visits(in defaults: UserDefaults = .standard) -> Bool {
        isEnabled(in: defaults) && defaults.bool(forKey: DefaultsKey.notchMascotVisits)
    }

    static func look(in defaults: UserDefaults = .standard) -> NotchMascotLook {
        NotchMascotLook(
            style: NotchMascotStyle(rawValue: defaults.string(forKey: DefaultsKey.notchMascotStyle) ?? "") ?? .minimal,
            shape: NotchMascotShape(rawValue: defaults.string(forKey: DefaultsKey.notchMascotShape) ?? "") ?? .ball,
            palette: NotchMascotPalette(rawValue: defaults.string(forKey: DefaultsKey.notchMascotPalette) ?? "") ?? .pearl)
    }

    /// How the Command Bar comes out of the island, or nil when it opens in
    /// its own window as it always has.
    static func commandBarStyle(in defaults: UserDefaults = .standard) -> NotchCommandBarStyle? {
        guard isEnabled(in: defaults), AppFeature.commandBar.isAvailable(in: defaults),
              defaults.bool(forKey: DefaultsKey.notchCommandBar) else { return nil }
        return NotchCommandBarStyle(rawValue: defaults.string(forKey: DefaultsKey.notchCommandBarStyle) ?? "") ?? .droplet
    }

    /// What the bar's face shows for what is typed. Results get a hop of
    /// their own on arrival, and afterward the eyes simply stay open on them.
    static func commandBarMood(query: String, hasResults: Bool, searching: Bool) -> NotchMascotMood {
        guard !query.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return .idle }
        if searching { return .thinking }
        return hasResults ? .idle : .confused
    }

    /// Whether the face's change is worth a little celebration: results
    /// turning up after a wait, or after nothing matched. The first letters
    /// typed find something every time, so that is no news.
    static func celebrates(from old: NotchMascotMood, to new: NotchMascotMood, query: String,
                           hasResults: Bool) -> Bool {
        (old == .thinking || old == .confused) && new == .idle && hasResults
            && !query.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    /// Where its eyes go while something is typed: along the text beside
    /// it, a little further as the text grows. Nil when the field is empty.
    static func readingGaze(for query: String) -> CGPoint? {
        guard !query.isEmpty else { return nil }
        return CGPoint(x: 0.07 + 0.04 * min(1, CGFloat(query.count) / 28), y: 0.01)
    }

    /// Where its eyes go for a pointer at `pointer`, with its center at
    /// `center`: toward it, more the farther it is, within its face.
    static func pointerGaze(from center: CGPoint, to pointer: CGPoint, size: CGFloat) -> CGPoint {
        guard size > 0 else { return .zero }
        let dx = (pointer.x - center.x) / (size * 3), dy = (pointer.y - center.y) / (size * 2)
        return CGPoint(x: max(-1, min(1, dx)) * 0.08, y: max(-1, min(1, dy)) * 0.05)
    }

    static func nextVisitDelay(random: Double = Double.random(in: 0...1)) -> TimeInterval {
        visitDelay.lowerBound + (visitDelay.upperBound - visitDelay.lowerBound) * min(1, max(0, random))
    }

    static func greeting(random: Double = Double.random(in: 0..<1)) -> NotchMascotMood {
        greetings[min(greetings.count - 1, max(0, Int(random * Double(greetings.count))))]
    }

    /// The companion's square in a closed strip of `height`, with or without
    /// a capsule's margins around its body.
    static func size(stripHeight: CGFloat, floats: Bool) -> CGFloat {
        floats ? max(10, min(18, stripHeight - 6)) : max(12, min(20, stripHeight - 12))
    }

    /// Where it rests in a strip with a camera: inside the left wing, a
    /// little way from the camera, so it sits beside it and never under it.
    static func track(stripWidth: CGFloat, stripHeight: CGFloat, wing: CGFloat,
                      cameraWidth: CGFloat, floats: Bool, bodyHeight: CGFloat) -> NotchMascotTrack {
        if floats {
            let size = self.size(stripHeight: bodyHeight, floats: true)
            return NotchMascotTrack(width: stripWidth, height: stripHeight, size: size, rest: stripWidth / 2,
                                    hidden: nil, baseline: stripHeight / 2,
                                    ceiling: max(0, (stripHeight - bodyHeight) / 2))
        }
        let size = self.size(stripHeight: stripHeight, floats: false)
        let gap = max(4, min(8, wing - size - 6))
        let rest = max(size / 2, wing - gap - size / 2)
        return NotchMascotTrack(width: stripWidth, height: stripHeight, size: size, rest: rest,
                                hidden: wing...(wing + cameraWidth), baseline: stripHeight / 2 + 0.5)
    }
}
