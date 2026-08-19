# Monkin

Monkin is a tiny native macOS desktop pet: a friendly monkey that lives above your windows on a transparent, always-on-top canvas.

## Run

Requirements: macOS 13+ and Xcode. The project uses bundle identifier
`com.banyudu.monkin` and signs local packaged builds with the installed
`Developer ID Application: Yudu Ban (RYLS8UDY5D)` certificate when available.

```sh
xcodegen generate
open Monkin.xcodeproj
```

Run the `Monkin` scheme from Xcode. The generated placeholder monkey can be dragged around the desktop and blinks periodically. The app is an accessory app, so it does not appear in the Dock.

## Screen awareness

Monkin can periodically read visible screen text using Apple Vision's on-device
OCR. It captures the main display every two minutes, keeps each recognized
string with its screen-space bounding rectangle, and currently walks toward one
nearby label before showing a small `nom nom…` reaction.

Every three seconds it also reads lightweight window metadata and the frontmost
application's Accessibility tree. Buttons, sliders, text fields, menu items,
and similar controls can become movement targets without taking a screenshot.

The first scan asks for macOS Screen Recording permission. OCR has no per-call
cost or network dependency; the tradeoff is local CPU and battery use while
each screenshot is analyzed. The interval and target-selection policy live in
`PetWindowController.swift`, and the reusable OCR/capture layer is in
`ScreenTextReader.swift`.

## Direction

The drawing is intentionally self-contained in `PetView.swift`, making it easy to replace with sprite sheets, an animated image, or a richer SwiftUI/AppKit character later.

## Dynamic figures

Monkin can rebuild its SVG appearance at runtime from a data-driven
`MonkinFigureSpec`. The spec uses material names rather than a fixed emotion
enum, so a conversation layer can compose new combinations:

```swift
petWindow.setFigure(MonkinFigureSpec(
    eyes: "curious",
    brows: "raised",
    mouth: "open",
    cheeks: "light",
    accessories: ["question-mark"],
    colors: ["accent": "#4A7772"]
))
```

`MonkinSVGRenderer` turns that specification into SVG and an `NSImage` in
memory. A future LLM bridge only needs to decode validated JSON into
`MonkinFigureSpec`; it does not need to generate the complete character SVG.

## Build and deploy

```sh
# Build, sign, package, and install to /Applications
./scripts/package-app.sh

# Build a signed development app and relaunch it when Swift files change
./scripts/dev-watch.sh

# Build a signed DMG and publish a GitHub release (requires a clean checkout)
./scripts/release.sh 0.1.0
```

Set `MONKIN_SIGNING_IDENTITY` to override the signing certificate, or
`MONKIN_SKIP_INSTALL=1` to package without copying into `/Applications`.
