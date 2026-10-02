// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2026 Vorssaint

import AppKit
import QuartzCore
import SwiftUI

/// A one-off motion the companion plays over its face.
enum NotchMascotCue: Equatable {
    /// Results turned up: a hop with smiling eyes.
    case celebrate
    /// Something was typed: the eyes dart about.
    case glance
}

/// The companion, drawn with shape layers. Every motion is a Core Animation
/// animation: the app says where it goes once and the render server draws
/// the way there, with no timer or redraw in the app. Even the blinks chain
/// through Core Animation, each one starting from the end of the last.
/// `root` is its square; its parent must lay out from the top, as a flipped
/// view does.
final class NotchMascotRig: NSObject {
    let root = CALayer()
    private(set) var look = NotchMascotLook.standard
    private(set) var size: CGFloat = 0
    private(set) var mood = NotchMascotMood.idle
    /// Whether it blinks now and then and, after a long rest, grows sleepy.
    private(set) var idles = false
    var reduceMotion = false

    private let hopper = CALayer()
    private let squasher = CALayer()
    private let tilter = CALayer()
    private let ears = CAShapeLayer()
    private let antenna = CAShapeLayer()
    private let bulb = CAShapeLayer()
    private let fill = CAGradientLayer()
    private let fillMask = CAShapeLayer()
    private let visor = CAShapeLayer()
    private let shine = CAShapeLayer()
    private let face = CALayer()
    private let leftEye = CAShapeLayer()
    private let rightEye = CAShapeLayer()
    private var blinks = 0
    private var blinkRelay: NotchMascotAnimationRelay?
    /// Blinks wait until a visit has gone by.
    private var blinksResume: CFTimeInterval = 0
    private var configured = false

    override init() {
        super.init()
        root.addSublayer(hopper)
        hopper.addSublayer(squasher)
        squasher.addSublayer(tilter)
        for layer in [ears, antenna, bulb, fill, visor, shine] { tilter.addSublayer(layer) }
        tilter.addSublayer(face)
        face.addSublayer(leftEye)
        face.addSublayer(rightEye)
        fill.mask = fillMask
        for layer in [root, hopper, squasher, tilter, face, ears, antenna, bulb, fill, fillMask, visor, shine,
                      leftEye, rightEye] {
            layer.actions = Self.noActions
        }
        shine.fillColor = NotchMascotColor.shine.cgColor
        visor.fillColor = NotchMascotColor.visor.cgColor
    }

    private static let noActions: [String: CAAction] = [
        "position": NSNull(), "bounds": NSNull(), "transform": NSNull(), "path": NSNull(),
        "opacity": NSNull(), "hidden": NSNull(), "contents": NSNull(), "colors": NSNull(),
        "fillColor": NSNull(), "frame": NSNull(), "sublayers": NSNull(), "shadowColor": NSNull(),
        "shadowOpacity": NSNull(),
    ]

    // MARK: Look

    /// Draws the companion at `size` points with `look`. Nothing moves.
    func configure(look: NotchMascotLook, size: CGFloat, contentsScale scale: CGFloat) {
        guard !configured || look != self.look || size != self.size || scale != root.contentsScale else { return }
        configured = true
        self.look = look
        self.size = size
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        defer { CATransaction.commit() }
        let box = CGRect(x: 0, y: 0, width: size, height: size)
        root.bounds = box
        for layer in [hopper, squasher, tilter, face, ears, antenna, bulb, fill, fillMask, visor, shine] {
            layer.frame = box
            layer.contentsScale = scale
        }
        root.contentsScale = scale
        let robot = look.style == .robot
        let palette = look.palette
        fill.colors = [palette.light.cgColor, palette.shade.cgColor]
        fill.startPoint = CGPoint(x: 0.5, y: 0)
        fill.endPoint = CGPoint(x: 0.5, y: 1)
        if robot {
            let parts = NotchMascotGeometry.robot(size: size)
            fillMask.path = parts.head
            ears.path = parts.ears
            antenna.path = parts.antenna
            bulb.path = parts.bulb
            visor.path = parts.visor
            ears.fillColor = palette.shade.cgColor
            antenna.fillColor = palette.shade.cgColor
            bulb.fillColor = palette.light.cgColor
            for eye in [leftEye, rightEye] {
                eye.fillColor = palette.light.cgColor
                eye.shadowColor = palette.light.cgColor
                eye.shadowOpacity = 0.9
                eye.shadowRadius = max(0.6, size * 0.04)
                eye.shadowOffset = .zero
            }
        } else {
            fillMask.path = NotchMascotGeometry.body(look.shape, size: size)
            for eye in [leftEye, rightEye] {
                eye.fillColor = NotchMascotColor.ink.cgColor
                eye.shadowOpacity = 0
            }
        }
        for layer in [ears, antenna, bulb, visor] { layer.isHidden = !robot }
        shine.path = NotchMascotGeometry.shine(look.face, size: size)
        shine.isHidden = robot
        let face = look.face
        let side = size * 0.4
        leftEye.frame = CGRect(x: face.leftEye.x * size - side / 2, y: face.leftEye.y * size - side / 2, width: side, height: side)
        rightEye.frame = CGRect(x: face.rightEye.x * size - side / 2, y: face.rightEye.y * size - side / 2, width: side, height: side)
        leftEye.contentsScale = scale
        rightEye.contentsScale = scale
        apply(mood.expression, animated: false)
    }

    // MARK: Faces

    func setMood(_ mood: NotchMascotMood, animated: Bool) {
        guard mood != self.mood else { return }
        let previous = self.mood
        self.mood = mood
        if mood != .sleepy { blinks = 0 }
        apply(mood.expression, animated: animated && !reduceMotion)
        guard animated, !reduceMotion, size > 0 else { syncBlinking(); return }
        switch mood {
        case .surprised: pop()
        case .confused: wobble()
        case .love: heartbeat()
        case .idle where previous == .sleepy: pop()
        default: break
        }
        syncBlinking()
    }

    private func eyePath(_ eye: NotchMascotEye, right: Bool) -> CGPath {
        let face = look.face
        let side = size * 0.4
        return NotchMascotGeometry.eye(eye, size: CGSize(width: face.eyeSize.width * size, height: face.eyeSize.height * size),
                                       center: CGPoint(x: side / 2, y: side / 2), right: right)
    }

    private func gazeTransform(_ gaze: CGPoint) -> CATransform3D {
        CATransform3DMakeTranslation(gaze.x * size, gaze.y * size, 0)
    }

    private func apply(_ expression: NotchMascotExpression, animated: Bool) {
        guard size > 0 else { return }
        let left = eyePath(expression.left, right: false)
        let right = eyePath(expression.right, right: true)
        let gaze = gazeTransform(expression.gaze)
        let tilt = CATransform3DMakeRotation(expression.tilt, 0, 0, 1)
        if animated {
            for (layer, path) in [(leftEye, left), (rightEye, right)] {
                let morph = CABasicAnimation(keyPath: "path")
                morph.fromValue = layer.presentation()?.path ?? layer.path
                morph.toValue = path
                morph.duration = 0.22
                morph.timingFunction = CAMediaTimingFunction(controlPoints: 0.2, 0.8, 0.3, 1)
                layer.add(morph, forKey: "morph")
            }
            let glance = CASpringAnimation(keyPath: "transform")
            glance.fromValue = face.presentation()?.transform ?? face.transform
            glance.toValue = gaze
            glance.damping = 16
            glance.stiffness = 260
            glance.duration = glance.settlingDuration
            face.add(glance, forKey: "gaze")
            let lean = CASpringAnimation(keyPath: "transform")
            lean.fromValue = tilter.presentation()?.transform ?? tilter.transform
            lean.toValue = tilt
            lean.damping = 12
            lean.stiffness = 200
            lean.duration = lean.settlingDuration
            tilter.add(lean, forKey: "tilt")
        }
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        leftEye.path = left
        rightEye.path = right
        face.transform = gaze
        tilter.transform = tilt
        CATransaction.commit()
    }

    /// Turns to `mood` at `time` on the media clock and keeps it there, for
    /// a face set ahead of a moment, such as a drop landing. The face it
    /// keeps on its own stays as it was.
    func turn(to mood: NotchMascotMood, at time: CFTimeInterval) {
        guard size > 0 else { return }
        let from = self.mood.expression, to = mood.expression
        for (layer, eyes, right) in [(leftEye, (from.left, to.left), false), (rightEye, (from.right, to.right), true)] {
            let morph = CABasicAnimation(keyPath: "path")
            morph.fromValue = eyePath(eyes.0, right: right)
            morph.toValue = eyePath(eyes.1, right: right)
            morph.beginTime = time
            morph.duration = reduceMotion ? 0.01 : 0.22
            morph.fillMode = .both
            morph.isRemovedOnCompletion = false
            layer.add(morph, forKey: "turn")
        }
        for (layer, from, to) in [(face, gazeTransform(from.gaze), gazeTransform(to.gaze)),
                                  (tilter, CATransform3DMakeRotation(from.tilt, 0, 0, 1),
                                   CATransform3DMakeRotation(to.tilt, 0, 0, 1))] {
            let move = CABasicAnimation(keyPath: "transform")
            move.fromValue = NSValue(caTransform3D: from)
            move.toValue = NSValue(caTransform3D: to)
            move.beginTime = time
            move.duration = reduceMotion ? 0.01 : 0.22
            move.fillMode = .both
            move.isRemovedOnCompletion = false
            layer.add(move, forKey: "turn")
        }
    }

    /// Back to its own face at rest, with every motion taken off.
    func reset(to mood: NotchMascotMood) {
        stopBlinking()
        for layer in [root, hopper, squasher, tilter, face, leftEye, rightEye] { layer.removeAllAnimations() }
        self.mood = mood
        blinks = 0
        apply(mood.expression, animated: false)
    }

    // MARK: Cues

    func play(_ cue: NotchMascotCue) {
        guard size > 0, !reduceMotion else {
            if cue == .celebrate, reduceMotion { flashFace(.happy, duration: 1) }
            return
        }
        switch cue {
        case .celebrate:
            hop(height: size * 0.28)
            flashFace(.happy, duration: 1)
        case .glance:
            let dart = CAKeyframeAnimation(keyPath: "transform.translation.x")
            dart.values = [0, size * 0.07, -size * 0.06, 0]
            dart.keyTimes = [0, 0.3, 0.7, 1]
            dart.duration = 0.42
            dart.isAdditive = true
            dart.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
            face.add(dart, forKey: "glance")
        }
    }

    private func hop(height: CGFloat) {
        let lift = CAKeyframeAnimation(keyPath: "transform.translation.y")
        lift.values = [0, -height, 0, -height * 0.3, 0]
        lift.keyTimes = [0, 0.32, 0.6, 0.78, 1]
        lift.timingFunctions = [CAMediaTimingFunction(name: .easeOut), CAMediaTimingFunction(name: .easeIn),
                                CAMediaTimingFunction(name: .easeOut), CAMediaTimingFunction(name: .easeIn)]
        lift.duration = 0.62
        lift.isAdditive = true
        hopper.add(lift, forKey: "hop")
        let squash = CAKeyframeAnimation(keyPath: "transform")
        squash.values = [squashed(0), squashed(-0.12), squashed(0), squashed(0.14), squashed(0), squashed(0.06), squashed(0)]
            .map { NSValue(caTransform3D: $0) }
        squash.keyTimes = [0, 0.12, 0.3, 0.62, 0.72, 0.84, 1]
        squash.duration = 0.62
        squasher.add(squash, forKey: "squash")
    }

    /// Positive flattens it on the ground, negative stretches it up; its
    /// bottom stays where it was.
    private func squashed(_ amount: CGFloat) -> CATransform3D {
        let scaleX = 1 + amount * 0.8, scaleY = 1 - amount
        let bottom = size * 0.42
        return CATransform3DConcat(CATransform3DMakeScale(scaleX, scaleY, 1),
                                   CATransform3DMakeTranslation(0, bottom * (1 - scaleY), 0))
    }

    private func pop() {
        let pop = CAKeyframeAnimation(keyPath: "transform")
        pop.values = [squashed(0), squashed(-0.14), squashed(0.06), squashed(0)].map { NSValue(caTransform3D: $0) }
        pop.keyTimes = [0, 0.35, 0.7, 1]
        pop.duration = 0.34
        squasher.add(pop, forKey: "pop")
    }

    private func wobble() {
        let shake = CAKeyframeAnimation(keyPath: "transform.rotation.z")
        shake.values = [0, 0.12, -0.1, 0.06, 0]
        shake.keyTimes = [0, 0.25, 0.5, 0.75, 1]
        shake.duration = 0.5
        shake.isAdditive = true
        tilter.add(shake, forKey: "wobble")
    }

    private func heartbeat() {
        for eye in [leftEye, rightEye] {
            let beat = CAKeyframeAnimation(keyPath: "transform.scale")
            beat.values = [1, 1.3, 1, 1.22, 1]
            beat.keyTimes = [0, 0.2, 0.45, 0.65, 1]
            beat.duration = 0.7
            eye.add(beat, forKey: "heartbeat")
        }
    }

    /// Shows another face for a moment and comes back to its own, without
    /// changing the face it keeps.
    private func flashFace(_ mood: NotchMascotMood, duration: TimeInterval, beginTime: CFTimeInterval? = nil) {
        let expression = mood.expression
        let own = self.mood.expression
        for (layer, eye, base, right) in [(leftEye, expression.left, own.left, false), (rightEye, expression.right, own.right, true)] {
            let face = CAKeyframeAnimation(keyPath: "path")
            let from = eyePath(base, right: right), to = eyePath(eye, right: right)
            face.values = [from, to, to, from]
            face.keyTimes = [0, 0.15, 0.85, 1]
            face.duration = duration
            if let beginTime { face.beginTime = beginTime }
            if reduceMotion { face.calculationMode = .discrete }
            layer.add(face, forKey: "flash")
        }
        pauseBlinking(for: duration, from: beginTime)
    }

    // MARK: Visits

    /// Plays a stroll that began at `start` on the media clock, from where it
    /// should be now. `baseline` is the height of its center in its parent;
    /// with Reduce Motion it does not walk, and greets at `stand` instead.
    func playVisit(_ path: NotchMascotPath, greeting: NotchMascotMood, baseline: CGFloat, stand: CGPoint,
                   start: CFTimeInterval) {
        guard size > 0, path.duration > 0, path.x.count == path.keyTimes.count else { return }
        let now = CACurrentMediaTime()
        guard now < start + path.duration else { return }
        if reduceMotion {
            // No stroll: it fades in where it would greet, says hello and fades out.
            let still = CAKeyframeAnimation(keyPath: "position")
            still.values = [NSValue(point: stand), NSValue(point: stand)]
            still.duration = path.duration
            still.beginTime = start
            root.add(still, forKey: "visit")
            if root.position != stand {
                let fade = CAKeyframeAnimation(keyPath: "opacity")
                fade.values = [0, 1, 1, 0]
                fade.keyTimes = [0, 0.12, 0.88, 1]
                fade.duration = path.duration
                fade.beginTime = start
                root.add(fade, forKey: "visitFade")
            }
            flashFace(greeting, duration: path.greeting.upperBound - path.greeting.lowerBound,
                      beginTime: start + path.greeting.lowerBound)
            return
        }
        let walk = CAKeyframeAnimation(keyPath: "position")
        walk.values = zip(path.x, path.lift).map { NSValue(point: CGPoint(x: $0, y: baseline - $1)) }
        walk.keyTimes = path.keyTimes.map { NSNumber(value: $0) }
        walk.duration = path.duration
        walk.beginTime = start
        walk.calculationMode = .linear
        root.add(walk, forKey: "visit")
        let squash = CAKeyframeAnimation(keyPath: "transform")
        squash.values = path.squash.map { NSValue(caTransform3D: squashed($0)) }
        squash.keyTimes = walk.keyTimes
        squash.duration = path.duration
        squash.beginTime = start
        squasher.add(squash, forKey: "visit")
        let look = CAKeyframeAnimation(keyPath: "transform.translation.x")
        look.values = path.gaze.map { $0 * size }
        look.keyTimes = walk.keyTimes
        look.duration = path.duration
        look.beginTime = start
        look.isAdditive = true
        face.add(look, forKey: "visit")
        flashFace(greeting, duration: path.greeting.upperBound - path.greeting.lowerBound,
                  beginTime: start + path.greeting.lowerBound)
        // No blink while it walks; the face it shows is the greeting's.
        pauseBlinking(for: start + path.duration - now, from: nil)
    }

    // MARK: Blinking

    /// Blinks wait while the layer is out of sight; `visible` resumes them.
    func setIdles(_ idles: Bool, visible: Bool) {
        let wanted = idles && visible
        guard wanted != self.idles else { return }
        self.idles = wanted
        if !wanted {
            stopBlinking()
            if mood == .sleepy, !idles { setMood(.idle, animated: false) }
        } else { syncBlinking() }
    }

    /// Wakes it from a long rest.
    func wake(animated: Bool) {
        blinks = 0
        if mood == .sleepy { setMood(.idle, animated: animated) }
    }

    private func syncBlinking() {
        guard idles, mood.expression.blinks, size > 0 else { stopBlinking(); return }
        guard leftEye.animation(forKey: "blink") == nil else { return }
        scheduleBlink()
    }

    private func stopBlinking() {
        blinkRelay?.target = nil
        blinkRelay = nil
        leftEye.removeAnimation(forKey: "blink")
        rightEye.removeAnimation(forKey: "blink")
    }

    private func pauseBlinking(for duration: TimeInterval, from begin: CFTimeInterval?) {
        let end = (begin ?? CACurrentMediaTime()) + max(0, duration)
        blinksResume = max(blinksResume, end)
        guard idles else { return }
        stopBlinking()
        syncBlinking()
    }

    /// One blink, a few seconds from now. It starts the next one when it ends,
    /// so blinking costs a short animation every few seconds and nothing in between.
    private func scheduleBlink() {
        let now = CACurrentMediaTime()
        let delay = max(0, blinksResume - now) + Double.random(in: NotchMascotSupport.blinkInterval)
        let twice = Double.random(in: 0...1) < 0.18
        let blink = CAKeyframeAnimation(keyPath: "transform.scale.y")
        blink.values = twice ? [1, 0.1, 1, 1, 0.1, 1] : [1, 0.1, 1]
        blink.keyTimes = twice ? [0, 0.2, 0.4, 0.58, 0.78, 1] : [0, 0.45, 1]
        blink.duration = twice ? 0.44 : 0.17
        blink.beginTime = now + delay
        // Reduce Motion: the eyes close and open without a motion between.
        if reduceMotion { blink.calculationMode = .discrete }
        let relay = NotchMascotAnimationRelay(target: self)
        blinkRelay = relay
        blink.delegate = relay
        leftEye.add(blink, forKey: "blink")
        let pair = blink.copy() as? CAKeyframeAnimation ?? blink
        pair.delegate = nil
        rightEye.add(pair, forKey: "blink")
    }

    fileprivate func blinkDidStop(finished: Bool, relay: NotchMascotAnimationRelay) {
        guard finished, relay === blinkRelay, idles else { return }
        blinkRelay = nil
        blinks += 1
        // A long rest makes its eyes heavy; it stops blinking then.
        if mood == .idle, blinks >= NotchMascotSupport.blinksBeforeSleep {
            setMood(.sleepy, animated: true)
            return
        }
        syncBlinking()
    }
}

/// Core Animation keeps its delegate alive; this one keeps only a weak
/// reference, so a companion taken off screen is let go even with a blink pending.
private final class NotchMascotAnimationRelay: NSObject, CAAnimationDelegate {
    weak var target: NotchMascotRig?

    init(target: NotchMascotRig) { self.target = target }

    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        target?.blinkDidStop(finished: flag, relay: self)
    }
}

/// Holds the companion in a view. It draws only through its layers and never
/// takes a click: what it stands on decides what a click does.
final class NotchMascotHostView: NSView {
    let mascot = NotchMascotRig()
    private let stage = CALayer()
    private let visibilityMask = CAShapeLayer()
    private var visibilityObserver: NSObjectProtocol?
    private var idlesWhenVisible = false
    private var playedVisit: UUID?
    private var lastCueID = 0
    /// The face last asked for. Asked again, it changes nothing: a companion
    /// grown sleepy on its own stays so until something new happens.
    private var requestedMood: NotchMascotMood?
    /// Where it stands, its center, or nil for the middle of the view; and
    /// where it can be seen, nil everywhere. Kept for when the view is resized.
    private var placement: (center: CGPoint?, visible: [CGRect]?) = (nil, nil)

    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        let root = CALayer()
        root.isGeometryFlipped = true
        root.masksToBounds = false
        layer = root
        wantsLayer = true
        stage.actions = ["position": NSNull(), "bounds": NSNull(), "mask": NSNull()]
        root.addSublayer(stage)
        stage.addSublayer(mascot.root)
        setAccessibilityElement(false)
    }

    required init?(coder: NSCoder) { nil }

    deinit {
        if let visibilityObserver { NotificationCenter.default.removeObserver(visibilityObserver) }
    }

    override var isFlipped: Bool { true }
    override func hitTest(_ point: NSPoint) -> NSView? { nil }

    override func viewDidMoveToWindow() {
        super.viewDidMoveToWindow()
        if let visibilityObserver { NotificationCenter.default.removeObserver(visibilityObserver) }
        visibilityObserver = window.map { window in
            NotificationCenter.default.addObserver(forName: NSWindow.didChangeOcclusionStateNotification,
                                                   object: window, queue: .main) { [weak self] _ in
                self?.syncIdling()
            }
        }
        syncIdling()
    }

    override func viewDidHide() { super.viewDidHide(); syncIdling() }
    override func viewDidUnhide() { super.viewDidUnhide(); syncIdling() }

    override func viewDidChangeBackingProperties() {
        super.viewDidChangeBackingProperties()
        mascot.configure(look: mascot.look, size: mascot.size, contentsScale: backingScale)
    }

    private var backingScale: CGFloat { window?.backingScaleFactor ?? NSScreen.main?.backingScaleFactor ?? 2 }

    private var isOnScreen: Bool {
        !isHiddenOrHasHiddenAncestor && window?.isVisible == true
            && window?.occlusionState.contains(.visible) == true
    }

    private func syncIdling() {
        mascot.setIdles(idlesWhenVisible, visible: isOnScreen)
    }

    func configure(look: NotchMascotLook, size: CGFloat, mood: NotchMascotMood, idles: Bool,
                   reduceMotion: Bool, animated: Bool) {
        mascot.reduceMotion = reduceMotion
        mascot.configure(look: look, size: size, contentsScale: backingScale)
        if mood != requestedMood {
            requestedMood = mood
            mascot.setMood(mood, animated: animated && window != nil)
        }
        idlesWhenVisible = idles
        syncIdling()
    }

    override func setFrameSize(_ newSize: NSSize) {
        super.setFrameSize(newSize)
        applyPlacement()
    }

    /// Where it stands, its center in this view or nil for the middle, and
    /// where it can be seen: nil everywhere, or only inside `visible`.
    func place(at center: CGPoint?, visible: [CGRect]?) {
        placement = (center, visible)
        applyPlacement()
    }

    private func applyPlacement() {
        let center = placement.center ?? CGPoint(x: bounds.midX, y: bounds.midY)
        let visible = placement.visible
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        stage.frame = bounds
        if mascot.root.position != center { mascot.root.position = center }
        if let visible {
            let path = CGMutablePath()
            visible.forEach { path.addRect($0) }
            visibilityMask.path = path
            if stage.mask !== visibilityMask { stage.mask = visibilityMask }
        } else if stage.mask != nil {
            stage.mask = nil
        }
        CATransaction.commit()
    }

    func play(_ cue: NotchMascotCue, id: Int) {
        guard id != lastCueID else { return }
        lastCueID = id
        guard window != nil else { return }
        mascot.play(cue)
    }

    func playVisit(_ visit: NotchMascotVisit?, path: @autoclosure () -> NotchMascotPath, baseline: CGFloat,
                   stand: CGPoint) {
        guard let visit, visit.id != playedVisit else { return }
        playedVisit = visit.id
        mascot.wake(animated: false)
        mascot.playVisit(path(), greeting: visit.greeting, baseline: baseline, stand: stand, start: visit.start)
    }
}

/// The companion on its own, centred in its frame: the Command Bar's face
/// and the Settings preview.
struct NotchMascotView: NSViewRepresentable {
    var look: NotchMascotLook
    var mood: NotchMascotMood = .idle
    var size: CGFloat
    var idles = true
    /// A one-off motion, played whenever `cueID` changes.
    var cue: NotchMascotCue? = nil
    var cueID = 0

    func makeNSView(context: Context) -> NotchMascotHostView {
        let view = NotchMascotHostView(frame: CGRect(x: 0, y: 0, width: size, height: size))
        view.configure(look: look, size: size, mood: mood, idles: idles,
                       reduceMotion: context.environment.accessibilityReduceMotion, animated: false)
        return view
    }

    func updateNSView(_ view: NotchMascotHostView, context: Context) {
        view.configure(look: look, size: size, mood: mood, idles: idles,
                       reduceMotion: context.environment.accessibilityReduceMotion, animated: true)
        view.place(at: nil, visible: nil)
        if let cue { view.play(cue, id: cueID) }
    }

    func sizeThatFits(_ proposal: ProposedViewSize, nsView: NotchMascotHostView, context: Context) -> CGSize? {
        CGSize(width: proposal.width ?? size, height: proposal.height ?? size)
    }
}

/// The companion in a closed strip: resting beside the camera, or strolling
/// through on a visit. It is hidden behind the camera as it passes.
struct NotchMascotTrackView: NSViewRepresentable {
    var look: NotchMascotLook
    var track: NotchMascotTrack
    /// Whether it stands at its resting place, or only comes for the visit.
    var rests: Bool
    var visit: NotchMascotVisit?

    func makeNSView(context: Context) -> NotchMascotHostView {
        NotchMascotHostView(frame: CGRect(x: 0, y: 0, width: track.width, height: track.height))
    }

    func updateNSView(_ view: NotchMascotHostView, context: Context) {
        view.configure(look: look, size: track.size, mood: .idle, idles: rests,
                       reduceMotion: context.environment.accessibilityReduceMotion, animated: true)
        // Off stage at the far end once a visit is over, so nothing jumps
        // when its last frame hands back to where it stands.
        let x = rests ? track.rest : track.width + track.size * 2
        var visible: [CGRect]?
        if let hidden = track.hidden {
            visible = [CGRect(x: -track.size * 3, y: -track.height, width: hidden.lowerBound + track.size * 3,
                              height: track.height * 3),
                       CGRect(x: hidden.upperBound, y: -track.height, width: track.width - hidden.upperBound + track.size * 3,
                              height: track.height * 3)]
        }
        view.place(at: CGPoint(x: x, y: track.baseline), visible: visible)
        view.playVisit(visit, path: visit?.kind == .lap ? NotchMascotMotion.lap(on: track) : NotchMascotMotion.pass(on: track),
                       baseline: track.baseline, stand: CGPoint(x: track.rest, y: track.baseline))
    }

    func sizeThatFits(_ proposal: ProposedViewSize, nsView: NotchMascotHostView, context: Context) -> CGSize? {
        CGSize(width: track.width, height: track.height)
    }
}
