# Rive desktop runtime

Monkin's macOS application target uses `RiveRuntime` **6.22.1**, pinned in
`project.yml` through Swift Package Manager. The screen-saver target is
deliberately unchanged.

`PetView` remains the AppKit-facing shell: it owns click handling, layout, and
the existing procedural/SVG fallback. `RivePetRenderer` is the desktop-only
adapter that owns the `RiveViewModel` and maps validated `MonkinMotion` names
to state-machine inputs. An unknown motion is normalized to `idle` before it
reaches either renderer.

## Asset workflow

The desktop renderer activates from `Monkin/Resources/monkin-monkey.riv`. The
asset is generated from Monkin's own `MonkinSVGRenderer` default character, so
the Rive renderer keeps the same monkey silhouette and palette as the fallback.
It contains a `Monkin Motion` state machine and named inputs for the existing
motion vocabulary. The first authored motions are `idle`, `wave`, `jump`, and
`celebrate`; aliases resolve to one of those expressive state-machine motions.

When revising the asset, preserve these contracts (or update
`RivePetRenderer.swift` in the same change):

- `idle` is the state-machine default.
- `wriggle`, `jump`, `wave`, and `celebrate` each have their own trigger.
- Optional inputs should cover accent color, expression, and accessories; wire
  them from `setFigure(_:)` in the renderer instead of exposing Rive types to
  window/behavior code.

Export the `.riv` from the Rive editor with the filename `monkin-monkey.riv`,
then use the
desktop app's status menu and thought/roaming flows to exercise every mapped
motion. Do not add the Rive package to `MonkinScreenSaver` without separately
validating the saver host.

## Performance smoke check

The Rive view uses the runtime's `drawOnChanged` optimization and takes over
the animation loop only when the bundled asset loads. `PetView` then stops its
12 FPS SVG pose rebuild timer, avoiding two concurrent render loops. Before a
release, launch the app, leave it idle for 60 seconds, and compare Activity
Monitor's Monkin CPU sample with the fallback (temporarily remove the `.riv`)
and Rive-enabled build. Idle CPU should remain visually indistinguishable; a
sustained increase of more than 1 percentage point should block release.

## License and attribution

The Rive Apple runtime is MIT licensed. Keep its copyright/license notice in
third-party release materials. The Monkin character asset should be original
art; retain the source and license attribution for any third-party asset.
