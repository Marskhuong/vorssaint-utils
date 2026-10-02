// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2026 Vorssaint

import CoreGraphics
import Foundation

/// The companion's model: its preferences, faces, outlines and strolls, and
/// the drop that carries the Command Bar out of the island.
enum NotchMascotTests {
    static func run(_ suite: TestSuite) {
        preferenceContracts(suite)
        faceContracts(suite)
        outlineContracts(suite)
        trackContracts(suite)
        strollContracts(suite)
        homecomingContracts(suite)
        commandBarContracts(suite)
        dropletContracts(suite)
    }

    private static func preferenceContracts(_ suite: TestSuite) {
        let domain = "com.vorssaint.tests.notch-mascot"
        let defaults = UserDefaults(suiteName: domain)!
        defaults.removePersistentDomain(forName: domain)
        defer { defaults.removePersistentDomain(forName: domain) }
        for (key, value) in Defaults.registeredDefaults where key.hasPrefix("notch") { defaults.set(value, forKey: key) }
        for (key, value) in AppFeature.availabilityDefaults { defaults.set(value, forKey: key) }
        defaults.set(true, forKey: AppFeature.notch.availabilityKey)
        defaults.set(true, forKey: AppFeature.commandBar.availabilityKey)

        defaults.set(true, forKey: DefaultsKey.notchEnabled)
        suite.expect(!NotchMascotSupport.isEnabled(in: defaults) && !NotchMascotSupport.visits(in: defaults)
                     && NotchMascotSupport.commandBarStyle(in: defaults) == nil,
                     "the companion is opt-in, and the Command Bar keeps its own window until it is on")
        suite.expect(NotchMascotSupport.look(in: defaults) == .standard
                     && NotchMascotLook.standard == NotchMascotLook(style: .minimal, shape: .ball, palette: .pearl),
                     "it starts as a pearl ball with two ink eyes")
        defaults.set(true, forKey: DefaultsKey.notchMascotEnabled)
        suite.expect(NotchMascotSupport.isEnabled(in: defaults) && NotchMascotSupport.visits(in: defaults)
                     && NotchMascotSupport.commandBarStyle(in: defaults) == .droplet,
                     "turned on, it visits now and then and the Command Bar falls from the island as a drop")
        defaults.set(NotchCommandBarStyle.island.rawValue, forKey: DefaultsKey.notchCommandBarStyle)
        suite.expect(NotchMascotSupport.commandBarStyle(in: defaults) == .island, "the bar can open inside the island instead")
        defaults.set("puddle", forKey: DefaultsKey.notchCommandBarStyle)
        suite.expect(NotchMascotSupport.commandBarStyle(in: defaults) == .droplet, "an unknown style falls back to the drop")
        defaults.set(false, forKey: DefaultsKey.notchCommandBar)
        suite.expect(NotchMascotSupport.commandBarStyle(in: defaults) == nil, "turned off, the bar keeps its own window")
        defaults.set(true, forKey: DefaultsKey.notchCommandBar)
        defaults.set(false, forKey: AppFeature.commandBar.availabilityKey)
        suite.expect(NotchMascotSupport.commandBarStyle(in: defaults) == nil,
                     "a Command Bar taken off the Features page never comes out of the island")
        defaults.set(true, forKey: AppFeature.commandBar.availabilityKey)
        defaults.set(false, forKey: DefaultsKey.notchMascotVisits)
        suite.expect(NotchMascotSupport.isEnabled(in: defaults) && !NotchMascotSupport.visits(in: defaults),
                     "visits can be turned off while it still rests")
        defaults.set(true, forKey: DefaultsKey.notchMascotVisits)
        defaults.set(false, forKey: DefaultsKey.notchEnabled)
        suite.expect(!NotchMascotSupport.isEnabled(in: defaults) && !NotchMascotSupport.visits(in: defaults)
                     && NotchMascotSupport.commandBarStyle(in: defaults) == nil,
                     "without the island there is no companion and no bar from it")
        defaults.set(true, forKey: DefaultsKey.notchEnabled)
        defaults.set(NotchMascotStyle.robot.rawValue, forKey: DefaultsKey.notchMascotStyle)
        defaults.set(NotchMascotShape.pill.rawValue, forKey: DefaultsKey.notchMascotShape)
        defaults.set(NotchMascotPalette.lilac.rawValue, forKey: DefaultsKey.notchMascotPalette)
        suite.expect(NotchMascotSupport.look(in: defaults) == NotchMascotLook(style: .robot, shape: .pill, palette: .lilac),
                     "style, shape and color are read as chosen")
        defaults.set("cube", forKey: DefaultsKey.notchMascotShape)
        defaults.set("neon", forKey: DefaultsKey.notchMascotPalette)
        defaults.set("dragon", forKey: DefaultsKey.notchMascotStyle)
        suite.expect(NotchMascotSupport.look(in: defaults) == .standard, "unknown values from a newer backup fall back")

        let keys = [DefaultsKey.notchMascotEnabled, DefaultsKey.notchMascotVisits, DefaultsKey.notchMascotStyle,
                    DefaultsKey.notchMascotShape, DefaultsKey.notchMascotPalette, DefaultsKey.notchCommandBar,
                    DefaultsKey.notchCommandBarStyle]
        suite.expect(keys.allSatisfy { Defaults.registeredDefaults[$0] != nil && $0.hasPrefix("notch") }
                     && SettingsBackupSupport.exportKeys().isSuperset(of: keys),
                     "every companion preference travels in a settings backup with the island's")
        suite.expect(Set(NotchMascotShape.allCases.map(\.rawValue)).count == 4
                     && Set(NotchMascotPalette.allCases.map(\.rawValue)).count == 6
                     && Set(NotchMascotPalette.allCases.map { "\($0.light)" }).count == 6,
                     "four shapes and six distinct colors")
        suite.expect(NotchMascotSupport.nextVisitDelay(random: 0) == NotchMascotSupport.visitDelay.lowerBound
                     && NotchMascotSupport.nextVisitDelay(random: 1) == NotchMascotSupport.visitDelay.upperBound
                     && NotchMascotSupport.nextVisitDelay(random: 7) == NotchMascotSupport.visitDelay.upperBound
                     && NotchMascotSupport.visitDelay.lowerBound >= 60,
                     "visits come minutes apart, never on a fast beat")
        suite.expect(NotchMascotSupport.greeting(random: 0) == .happy && NotchMascotSupport.greeting(random: 0.5) == .wink
                     && NotchMascotSupport.greeting(random: 0.99) == .love && NotchMascotSupport.greeting(random: 3) == .love,
                     "a visit says hello happy, with a wink or in love")
    }

    private static func faceContracts(_ suite: TestSuite) {
        suite.expect(Set(NotchMascotMood.showcase) == Set(NotchMascotMood.allCases).subtracting([.idle]),
                     "the Settings preview shows every face")
        suite.expect(NotchMascotMood.idle.expression.blinks && NotchMascotMood.searching.expression.blinks
                     && !NotchMascotMood.happy.expression.blinks && !NotchMascotMood.love.expression.blinks
                     && !NotchMascotMood.sleepy.expression.blinks && !NotchMascotMood.wink.expression.blinks,
                     "open eyes blink now and then; smiling, heart and sleepy eyes do not")
        suite.expect(NotchMascotMood.wink.expression.left != NotchMascotMood.wink.expression.right
                     && NotchMascotMood.confused.expression.tilt != 0 && NotchMascotMood.thinking.expression.gaze.y < 0,
                     "a wink closes one eye, confusion tilts the head and thinking looks up")
        var expressions: [NotchMascotExpression] = []
        for mood in NotchMascotMood.allCases where !expressions.contains(mood.expression) {
            expressions.append(mood.expression)
        }
        suite.expect(expressions.count == NotchMascotMood.allCases.count, "every face is its own")
    }

    private static func outlineContracts(_ suite: TestSuite) {
        let eyes: [NotchMascotEye] = [.open, .closed, .happy, .heart, .sleepy, .wide, .squint, .determined]
        let size = CGSize(width: 2, height: 4)
        let structure = elements(NotchMascotGeometry.eye(.open, size: size, center: .zero, right: false))
        var shared = true, bounded = true, starts = true
        for eye in eyes {
            for right in [false, true] {
                let path = NotchMascotGeometry.eye(eye, size: size, center: CGPoint(x: 10, y: 10), right: right)
                shared = shared && elements(path) == structure
                let box = path.boundingBoxOfPath
                bounded = bounded && box.minX > 10 - size.width * 1.4 && box.maxX < 10 + size.width * 1.4
                    && box.minY > 10 - size.height && box.maxY < 10 + size.height
                let points = NotchMascotGeometry.eyePoints(eye, size: size, right: right)
                starts = starts && points.count == NotchMascotGeometry.eyeCurveCount && abs(points[0].x) < 0.05
                    && points[0].y <= (points.map(\.y).min() ?? 0) + size.height * 0.35
            }
        }
        suite.expect(structure.count == NotchMascotGeometry.eyeCurveCount + 2 && shared,
                     "every eye is drawn with the same curves, so any face can turn into any other")
        suite.expect(bounded, "every eye stays around its own place on the face")
        suite.expect(starts, "every outline starts at the top of its middle and runs the same way round")
        let open = NotchMascotGeometry.eyePoints(.open, size: size, right: false)
        let mirrored = NotchMascotGeometry.eyePoints(.determined, size: size, right: true)
        let left = NotchMascotGeometry.eyePoints(.determined, size: size, right: false)
        suite.expect(abs((open.map(\.x).max() ?? 0) + (open.map(\.x).min() ?? 0)) < 0.05
                     && abs((left.map(\.x).max() ?? 0) + (mirrored.map(\.x).min() ?? 0)) < 0.05,
                     "the right eye mirrors the left")

        for shape in NotchMascotShape.allCases {
            let box = NotchMascotGeometry.body(shape, size: 20).boundingBoxOfPath
            suite.expect(box.minX >= 0 && box.minY >= 0 && box.maxX <= 20 && box.maxY <= 20 && box.width > 8 && box.height > 8,
                         "the \(shape.rawValue) body fits its square")
            let face = NotchMascotLook(style: .minimal, shape: shape, palette: .pearl).face
            let body = NotchMascotGeometry.body(shape, size: 20)
            suite.expect(body.contains(CGPoint(x: face.leftEye.x * 20, y: face.leftEye.y * 20))
                         && body.contains(CGPoint(x: face.rightEye.x * 20, y: face.rightEye.y * 20))
                         && body.contains(CGPoint(x: face.shineCenter.x * 20, y: face.shineCenter.y * 20)),
                         "the \(shape.rawValue) face and its highlight sit on the body")
        }
        let robot = NotchMascotGeometry.robot(size: 20)
        let face = NotchMascotLook(style: .robot, shape: .ball, palette: .mint).face
        suite.expect(robot.visor.contains(CGPoint(x: face.leftEye.x * 20, y: face.leftEye.y * 20))
                     && robot.visor.contains(CGPoint(x: face.rightEye.x * 20, y: face.rightEye.y * 20))
                     && [robot.head, robot.ears, robot.antenna, robot.bulb].allSatisfy {
                         let box = $0.boundingBoxOfPath
                         return box.minX >= 0 && box.minY >= 0 && box.maxX <= 20 && box.maxY <= 20
                     },
                     "the robot's eyes light its visor, and all of it fits its square")
    }

    private static func trackContracts(_ suite: TestSuite) {
        for height: CGFloat in [24, 32, 38] {
            let track = NotchMascotSupport.track(stripWidth: 180 + 88, stripHeight: height, wing: 44, cameraWidth: 180,
                                                 floats: false, bodyHeight: height)
            suite.expect(track.rest - track.size / 2 >= 0 && track.rest + track.size / 2 <= 44 - 4
                         && track.hidden == 44...224 && abs(track.farSpot - (224 + 44 - track.rest)) < 0.01
                         && track.size <= height - 8,
                         "at \(Int(height)) points it rests whole inside the wing, beside the camera and never under it")
        }
        let capsule = NotchMascotSupport.track(stripWidth: 76, stripHeight: 24, wing: 0, cameraWidth: 0,
                                               floats: true, bodyHeight: 20)
        suite.expect(capsule.hidden == nil && capsule.rest == 38 && capsule.size <= 16 && capsule.baseline == 12
                     && capsule.farSpot > capsule.rest && capsule.farSpot + capsule.size / 2 <= 76,
                     "in a capsule it rests in the middle, with no camera to hide behind")
    }

    private static func strollContracts(_ suite: TestSuite) {
        let notch = NotchMascotSupport.track(stripWidth: 268, stripHeight: 32, wing: 44, cameraWidth: 180,
                                             floats: false, bodyHeight: 32)
        let capsule = NotchMascotSupport.track(stripWidth: 76, stripHeight: 24, wing: 0, cameraWidth: 0,
                                               floats: true, bodyHeight: 20)
        for (name, track) in [("notch", notch), ("capsule", capsule)] {
            for kind in [NotchMascotVisit.Kind.lap, .pass] {
                let path = NotchMascotMotion.path(for: kind, on: track)
                let label = "\(name) \(kind == .lap ? "lap" : "pass")"
                let counts = Set([path.keyTimes.count, path.x.count, path.lift.count, path.squash.count, path.gaze.count])
                suite.expect(counts.count == 1 && path.keyTimes.first == 0 && path.keyTimes.last == 1
                             && zip(path.keyTimes, path.keyTimes.dropFirst()).allSatisfy { $0 <= $1 },
                             "the \(label) is one even run of frames from start to end")
                suite.expect(path.duration == NotchMascotMotion.duration(of: kind) && path.duration <= 4
                             && path.greeting.lowerBound > 0 && path.greeting.upperBound < path.duration,
                             "the \(label) is short, with its hello inside it")
                suite.expect(path.lift.allSatisfy { $0 >= 0 && $0 <= track.size * 0.4 }
                             && path.squash.allSatisfy { abs($0) <= 0.15 },
                             "the \(label) hops stay low and its squashes small")
                suite.expect(path.lift.allSatisfy { track.baseline - $0 - track.size / 2 >= track.ceiling + 1 },
                             "the \(label) never hops into the island's top edge")
                if kind == .lap {
                    suite.expect(abs((path.x.first ?? 0) - track.rest) < 0.01 && abs((path.x.last ?? 0) - track.rest) < 0.01,
                                 "the \(label) leaves its resting place and comes back to it")
                    // Between two frames it never crosses the strip: a frame
                    // drawn in between would show it in the middle.
                    let crossings = zip(zip(path.x, path.x.dropFirst()), zip(path.keyTimes, path.keyTimes.dropFirst()))
                        .filter { abs($0.0.1 - $0.0.0) > track.width / 2 }
                    suite.expect(!crossings.isEmpty && crossings.allSatisfy { $0.1.0 == $0.1.1 },
                                 "the \(label) goes around off stage in no time, never seen on the way")
                } else {
                    suite.expect((path.x.first ?? 0) <= -track.size / 2 && (path.x.last ?? 0) >= track.width + track.size / 2,
                                 "the \(label) comes in at one end and leaves at the other")
                }
                // Wherever it stands still, it stands where it can be seen.
                if let hidden = track.hidden {
                    var stillInCamera = false
                    for index in 1..<path.x.count where path.x[index] == path.x[index - 1] {
                        let x = path.x[index]
                        if x > hidden.lowerBound + 1, x < hidden.upperBound - 1 { stillInCamera = true }
                    }
                    suite.expect(!stillInCamera, "the \(label) never stops behind the camera")
                }
                let hello = path.keyTimes.indices.filter {
                    let time = path.keyTimes[$0] * path.duration
                    return time >= path.greeting.lowerBound + 0.2 && time <= path.greeting.upperBound - 0.2
                }
                suite.expect(!hello.isEmpty && hello.allSatisfy { index in
                    let x = path.x[index]
                    let seen = x - track.size / 2 >= 0 && x + track.size / 2 <= track.width
                    guard let hidden = track.hidden else { return seen }
                    return seen && (x + track.size / 2 <= hidden.lowerBound || x - track.size / 2 >= hidden.upperBound)
                }, "the \(label) says hello where it can be seen")
            }
        }
    }

    private static func homecomingContracts(_ suite: TestSuite) {
        let notch = NotchMascotSupport.track(stripWidth: 268, stripHeight: 32, wing: 44, cameraWidth: 180,
                                             floats: false, bodyHeight: 32)
        let capsule = NotchMascotSupport.track(stripWidth: 76, stripHeight: 24, wing: 0, cameraWidth: 0,
                                               floats: true, bodyHeight: 20)
        for (name, track) in [("notch", notch), ("capsule", capsule)] {
            let path = NotchMascotMotion.path(for: .home, on: track)
            let counts = Set([path.keyTimes.count, path.x.count, path.lift.count, path.squash.count, path.gaze.count])
            suite.expect(counts.count == 1 && path.keyTimes.first == 0 && path.keyTimes.last == 1
                         && path.duration == NotchMascotMotion.homeDuration && path.duration < 0.8,
                         "coming home in a \(name) is one short run of frames")
            suite.expect(abs((path.x.last ?? 0) - track.rest) < 0.01 && path.lift.last == 0,
                         "coming home in a \(name) ends standing where it rests")
            suite.expect(path.greeting.lowerBound == 0 && path.greeting.upperBound < path.duration,
                         "it keeps the bar's face only until it lands")
            if let hidden = track.hidden {
                suite.expect((path.x.first ?? 0) - track.size / 2 > hidden.lowerBound
                             && path.x.allSatisfy { $0 >= track.rest - 0.01 },
                             "it comes out from behind the camera, never past its place")
            } else {
                suite.expect(path.x.allSatisfy { abs($0 - track.rest) < 0.01 },
                             "in a capsule it lands where it rests, the drop having risen there")
            }
        }
    }

    private static func commandBarContracts(_ suite: TestSuite) {
        suite.expect(NotchMascotSupport.commandBarMood(query: " ", hasResults: false, searching: true) == .idle,
                     "an empty field leaves the face at rest")
        suite.expect(NotchMascotSupport.commandBarMood(query: "fire", hasResults: false, searching: true) == .thinking,
                     "it thinks while answers load")
        suite.expect(NotchMascotSupport.commandBarMood(query: "fire", hasResults: true, searching: false) == .idle
                     && NotchMascotSupport.commandBarMood(query: "qzx", hasResults: false, searching: false) == .confused,
                     "it looks at the results, and looks lost when nothing matches")
        suite.expect(NotchMascotSupport.celebrates(from: .thinking, to: .idle, query: "fire", hasResults: true)
                     && NotchMascotSupport.celebrates(from: .confused, to: .idle, query: "fire", hasResults: true),
                     "it celebrates results that arrive after waiting, or after nothing matched")
        suite.expect(!NotchMascotSupport.celebrates(from: .idle, to: .idle, query: "f", hasResults: true)
                     && !NotchMascotSupport.celebrates(from: .confused, to: .idle, query: " ", hasResults: false)
                     && !NotchMascotSupport.celebrates(from: .thinking, to: .confused, query: "fire", hasResults: false),
                     "the first letters finding something is no party, nor is clearing the field or finding nothing")
        suite.expect(NotchMascotSupport.readingGaze(for: "") == nil,
                     "an empty field leaves the eyes ahead")
        let short = NotchMascotSupport.readingGaze(for: "f"), long = NotchMascotSupport.readingGaze(for: String(repeating: "f", count: 60))
        suite.expect((short?.x ?? 0) >= 0.06 && (long?.x ?? 0) > (short?.x ?? 0) && (long?.x ?? 1) <= 0.12,
                     "its eyes go along the text beside it, further as it grows, and stay on its face")
        let ahead = NotchMascotSupport.pointerGaze(from: CGPoint(x: 26, y: 16), to: CGPoint(x: 26, y: 16), size: 20)
        let right = NotchMascotSupport.pointerGaze(from: CGPoint(x: 26, y: 16), to: CGPoint(x: 400, y: 16), size: 20)
        let left = NotchMascotSupport.pointerGaze(from: CGPoint(x: 26, y: 16), to: CGPoint(x: 0, y: 30), size: 20)
        suite.expect(ahead == .zero && right.x > 0 && abs(right.x) <= 0.08 && left.x < 0 && left.y > 0 && abs(left.y) <= 0.05,
                     "its eyes turn toward the pointer, within its face")
    }

    private static func dropletContracts(_ suite: TestSuite) {
        let edge = CommandBarDropletMotion.rootDepth
        let field = CGRect(x: 28, y: edge + CommandBarDropletMotion.landingGap, width: 560, height: 50)
        let icon = CGPoint(x: field.minX + 27, y: field.midY)
        let centerX: CGFloat = 308
        let drop = CommandBarDropletMotion.drop(edge: edge, centerX: centerX, field: field, icon: icon)
        let structure = elements(CommandBarDropletMotion.neckPath(drop.frames[0], edge: edge, centerX: centerX))
        suite.expect(drop.frames.count == drop.keyTimes.count && drop.keyTimes.first == 0 && drop.keyTimes.last == 1
                     && zip(drop.keyTimes, drop.keyTimes.dropFirst()).allSatisfy { $0 < $1 }
                     && drop.frames.allSatisfy { elements(CommandBarDropletMotion.neckPath($0, edge: edge, centerX: centerX)) == structure },
                     "the drop is one run of frames whose neck keeps its curves, so each turns into the next")
        let first = drop.frames[0], last = drop.frames[drop.frames.count - 1]
        suite.expect(first.bead.midY < edge + 2 && first.bead.midX == centerX && first.mascotScale < 1,
                     "the drop starts in the island's edge, with the companion small inside")
        suite.expect(last.bead == field && last.mascot == icon && last.mascotScale == 1 && last.neckRoot == 0
                     && last.neckEnd <= edge,
                     "it ends as the bar's field, with the companion in the icon's place and no neck left")
        suite.expect(drop.duration > 0.4 && drop.duration < 0.9 && drop.landing > 0.15 && drop.landing < drop.reveal
                     && drop.reveal <= drop.duration && drop.reveal < 0.7,
                     "it falls and opens quickly, landing first, and the bar takes over before the swing ends")
        let revealed = drop.frames[min(drop.frames.count - 1,
                                       Int((drop.reveal / drop.duration * Double(drop.frames.count - 1)).rounded(.up)))]
        suite.expect(abs(revealed.bead.width - field.width) <= 2.5 && abs(revealed.bead.height - field.height) <= 1.5,
                     "when the bar takes over, the drop already has its size within a couple of points")
        suite.expect(drop.frames.allSatisfy { $0.bead.maxY <= field.maxY + 12 && $0.bead.minX >= field.minX - 12
                                               && $0.bead.maxX <= field.maxX + 12 },
                     "its spring opens it around the field, never far past it")
        let pinched = drop.frames.firstIndex { $0.neckEnd < $0.bead.minY - 0.5 } ?? drop.frames.count
        suite.expect(pinched < drop.frames.count
                     && drop.frames[pinched...].allSatisfy { $0.neckEnd < $0.bead.minY - 0.5 }
                     && zip(drop.frames[pinched...], drop.frames[pinched...].dropFirst()).allSatisfy { $0.neckEnd >= $1.neckEnd },
                     "the neck lets go once and draws back into the island")
        suite.expect(drop.frames[pinched...].allSatisfy { $0.neckEnd - edge < 1 || $0.neckTip > 0.2 },
                     "what is left of the neck ends round, never in a point")

        let bar = CGRect(x: field.minX, y: field.minY, width: field.width, height: 380)
        let back = CommandBarDropletMotion.retract(edge: edge, centerX: centerX, bar: bar, field: field, icon: icon)
        let start = back.frames[0], end = back.frames[back.frames.count - 1]
        suite.expect(back.frames.count == back.keyTimes.count && start.bead == bar && start.mascot == icon
                     && start.mascotScale == 1 && back.duration < 0.8,
                     "the way back starts as the whole bar, its companion in the icon's place")
        suite.expect(end.bead.midY < edge && end.mascotScale == CommandBarDropletMotion.ridingScale
                     && back.frames.allSatisfy { elements(CommandBarDropletMotion.neckPath($0, edge: edge, centerX: centerX)) == structure },
                     "and ends risen into the island, the companion small inside the drop")
        let side = CommandBarDropletMotion.beadSide
        suite.expect(back.frames.allSatisfy { frame in
            let gap = frame.bead.minY - edge
            let length = frame.neckEnd - edge
            // Apart, the island only bulges toward the drop. Joined, the
            // neck is wide where it meets it.
            return length <= side * 0.3 + 0.5 || gap <= side * 0.3 + 2 || frame.neckTip >= 3
        }, "rising, no thin thread ever stretches from the island to a drop still far off")
    }

    private static func elements(_ path: CGPath) -> [Int32] {
        var kinds: [Int32] = []
        path.applyWithBlock { kinds.append($0.pointee.type.rawValue) }
        return kinds
    }
}
