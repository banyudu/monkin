# Releasing Monkin

Monkin uses the same local macOS app workflow as Banyan:

```sh
./scripts/package-app.sh
```

This builds the Xcode project in Release configuration, signs the app with the
first installed `Developer ID Application` certificate, verifies the signature,
and installs it into `/Applications/Monkin.app`. Set
`MONKIN_SKIP_INSTALL=1` to keep the result only in `dist/`.

To create and publish a DMG:

```sh
./scripts/release.sh 0.1.0
```

The release script requires a clean Git checkout, the GitHub CLI, and the
`Developer ID Application: Yudu Ban (RYLS8UDY5D)` certificate. Override the
identity with `MONKIN_SIGNING_IDENTITY` when needed.
