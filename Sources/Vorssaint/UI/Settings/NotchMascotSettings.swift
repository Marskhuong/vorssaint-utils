// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2026 Vorssaint

import SwiftUI

/// The companion's card on the Dynamic Island page: whether it lives in the
/// island, how it looks, and whether the Command Bar comes out with it.
struct NotchMascotSettingsCard: View {
    @ObservedObject private var l10n = L10n.shared
    /// Redraws when the Command Bar is turned on or off on the Features page.
    @ObservedObject private var features = FeatureRuntime.shared
    @AppStorage(DefaultsKey.notchMascotEnabled) private var enabled = false
    @AppStorage(DefaultsKey.notchMascotVisits) private var visits = true
    @AppStorage(DefaultsKey.notchMascotStyle) private var style = NotchMascotStyle.minimal.rawValue
    @AppStorage(DefaultsKey.notchMascotShape) private var shape = NotchMascotShape.ball.rawValue
    @AppStorage(DefaultsKey.notchMascotPalette) private var palette = NotchMascotPalette.pearl.rawValue
    @AppStorage(DefaultsKey.notchCommandBar) private var commandBar = true
    @AppStorage(DefaultsKey.notchCommandBarStyle) private var commandBarStyle = NotchCommandBarStyle.droplet.rawValue
    /// The face the preview shows: at rest, or one of the showcase after a click.
    @State private var face = 0
    @State private var cueID = 0

    private var text: NotchMascotStrings { FeatureStrings.notchMascot(l10n.language) }

    private var look: NotchMascotLook {
        NotchMascotLook(style: NotchMascotStyle(rawValue: style) ?? .minimal,
                        shape: NotchMascotShape(rawValue: shape) ?? .ball,
                        palette: NotchMascotPalette(rawValue: palette) ?? .pearl)
    }

    private var mood: NotchMascotMood { face == 0 ? .idle : NotchMascotMood.showcase[(face - 1) % NotchMascotMood.showcase.count] }

    var body: some View {
        SettingsCard {
            HStack(spacing: 12) {
                preview
                VStack(alignment: .leading, spacing: 2) {
                    Text(text.title).font(.headline)
                    Text(text.hint).font(.caption).foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
                Spacer(minLength: 12)
                Toggle(text.title, isOn: $enabled).labelsHidden().toggleStyle(.switch)
            }
            if enabled {
                switchRow("sparkles", text.visits, caption: text.visitsHint, isOn: $visits)
                SettingsChoiceRow(symbol: "paintpalette", title: text.style, selection: $style) {
                    ForEach(NotchMascotStyle.allCases) { Text(text.style($0)).tag($0.rawValue) }
                }
                if look.style == .minimal { shapes }
                colors
                commandBarRows
            }
        }
    }

    /// The companion on a slice of black island; a click shows its next face.
    private var preview: some View {
        Button {
            face = (face + 1) % (NotchMascotMood.showcase.count + 1)
            cueID += 1
        } label: {
            NotchMascotView(look: look, mood: mood, size: 30, idles: true,
                            cue: mood == .happy ? .celebrate : mood == .searching ? .glance : nil, cueID: cueID)
                .frame(width: 30, height: 30)
                .frame(width: 58, height: 40)
                .background(Color.black, in: Capsule())
                .contentShape(Capsule())
        }
        .buttonStyle(.plain)
        .help(text.previewHint)
        .accessibilityLabel(text.preview)
        .accessibilityValue(text.mood(mood))
        .accessibilityHint(text.previewHint)
    }

    private var shapes: some View {
        VStack(alignment: .leading, spacing: 8) {
            SettingsRow(symbol: "circle.square", title: text.shape) {
                Text(text.shape(look.shape)).foregroundStyle(.secondary)
            }
            HStack(spacing: 8) {
                ForEach(NotchMascotShape.allCases) { item in
                    let selected = look.shape == item
                    Button { shape = item.rawValue } label: {
                        NotchMascotView(look: NotchMascotLook(style: .minimal, shape: item, palette: look.palette),
                                        size: 24, idles: false)
                            .frame(width: 24, height: 24)
                            .frame(maxWidth: .infinity)
                            .frame(height: 38)
                            .background(Color.black, in: RoundedRectangle(cornerRadius: 9, style: .continuous))
                            .overlay(RoundedRectangle(cornerRadius: 9, style: .continuous)
                                .strokeBorder(selected ? Color.accentColor : .clear, lineWidth: 2))
                            .contentShape(RoundedRectangle(cornerRadius: 9, style: .continuous))
                    }
                    .buttonStyle(.plain)
                    .help(text.shape(item))
                    .accessibilityLabel(text.shape(item))
                    .accessibilityAddTraits(selected ? .isSelected : [])
                }
            }
            .padding(.leading, settingsRowTextInset)
        }
    }

    private var colors: some View {
        VStack(alignment: .leading, spacing: 8) {
            SettingsRow(symbol: "swatchpalette", title: text.color) {
                Text(text.palette(look.palette)).foregroundStyle(.secondary)
            }
            HStack(spacing: 10) {
                ForEach(NotchMascotPalette.allCases) { item in
                    let selected = look.palette == item
                    Button { palette = item.rawValue } label: {
                        Circle()
                            .fill(LinearGradient(colors: [Color(cgColor: item.light.cgColor), Color(cgColor: item.shade.cgColor)],
                                                 startPoint: .top, endPoint: .bottom))
                            .frame(width: 20, height: 20)
                            .overlay(Circle().strokeBorder(Color.primary.opacity(0.15), lineWidth: 0.5))
                            .padding(3)
                            .overlay(Circle().strokeBorder(selected ? Color.accentColor : .clear, lineWidth: 2))
                            .contentShape(Circle())
                    }
                    .buttonStyle(.plain)
                    .help(text.palette(item))
                    .accessibilityLabel(text.palette(item))
                    .accessibilityAddTraits(selected ? .isSelected : [])
                }
            }
            .padding(.leading, settingsRowTextInset)
        }
    }

    @ViewBuilder private var commandBarRows: some View {
        let available = AppFeature.commandBar.isAvailable
        switchRow("command", text.commandBar,
                  caption: available ? text.commandBarHint : FeatureStrings.notchEditor(l10n.language)
                    .enableFeature(AppFeature.commandBar.hubTitle(l10n.s, hub: FeatureStrings.hub(l10n.language))),
                  isOn: Binding(get: { available && commandBar }, set: { commandBar = $0 }))
            .disabled(!available)
        if available, commandBar {
            SettingsChoiceRow(symbol: "drop", title: text.opensAs, selection: $commandBarStyle) {
                ForEach(NotchCommandBarStyle.allCases) { Text(text.commandBarStyle($0)).tag($0.rawValue) }
            }
            .padding(.leading, settingsRowTextInset)
        }
    }

    /// An option with its icon, one line and a switch, like the rest of the page.
    private func switchRow(_ symbol: String, _ title: String, caption: String? = nil, isOn: Binding<Bool>) -> some View {
        SettingsRow(symbol: symbol, title: title, caption: caption) {
            Toggle(title, isOn: isOn).labelsHidden().toggleStyle(.switch)
        }
    }
}
