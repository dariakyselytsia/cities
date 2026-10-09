# Releasing Cities

How to build and share the game (T22). Publishing to Google Play and the App
Store is T29: it needs paid accounts and is on hold.

## Version numbers

`pubspec.yaml` has `version: X.Y.Z+N`:
- **X.Y.Z** is the version people see (Settings → About shows it; keep
  `appVersion` in `lib/core/app_info.dart` equal, a test checks).
- **N** is the build number. **Bump it for every build anyone else
  installs.** Android refuses to install an older build number over a newer
  one, and the stores reject a number they've seen.

Tags: `vX.Y.Z-beta.K` for a friends' build (a GitHub pre-release),
`vX.Y.Z` for a store release. The release workflow checks that the tag's
`X.Y.Z` matches `pubspec.yaml`.

## The Android upload key: keep it safe

Every APK friends install, and later every Play upload, must be signed with
the **same key**. A build signed with another key can't update the game; it
has to be uninstalled first, which loses the player's progress.

- Keystore: `D:\Android\keys\cities-upload.jks` (alias `upload`, PKCS12,
  RSA 4096, valid until 2054), outside the repo.
- Its password is in `android/key.properties`, which is gitignored and
  points Gradle at the keystore.
- Certificate SHA-256:
  `65:9A:F1:5D:4F:A6:11:5B:C4:81:06:CB:FB:2C:E9:C3:94:C3:16:E1:66:60:04:D0:CD:FE:B4:FE:53:DB:FD:E3`

**Back up both** (the `.jks` file and the password) somewhere other than
this PC, e.g. a password manager with the file attached. Without
`key.properties`, a release build still works but is signed with the debug
key (Gradle prints a warning): don't share such a build.

## One-time GitHub setup

Run these from the project root in Git Bash.

1. **Store the key as encrypted GitHub Secrets** (the release workflow
   signs the APK with them):
   ```bash
   base64 -w0 /d/Android/keys/cities-upload.jks | gh secret set ANDROID_KEYSTORE_BASE64
   sed -n 's/^storePassword=//p' android/key.properties | tr -d '\r\n' | gh secret set ANDROID_KEYSTORE_PASSWORD
   ```
2. **Turn on GitHub Pages** for the privacy policy, served from `docs/` on
   `main`:
   ```bash
   gh api -X POST repos/dariakyselytsia/cities/pages -f "source[branch]=main" -f "source[path]=/docs"
   ```
   It appears at https://dariakyselytsia.github.io/cities/privacy/ a minute
   or two later.

## Making a friends' build

1. Bump `version:` in `pubspec.yaml` (at least the `+N`), commit and merge
   to `main`, and push.
2. Tag and push the tag:
   ```bash
   git tag v1.0.0-beta.1
   git push origin v1.0.0-beta.1
   ```
3. The **Release** workflow (Actions tab, about 15 minutes) builds:
   - `cities-v…-android.apk`, signed with the upload key;
   - `cities-v…-ios.ipa`, unsigned (each iPhone signs it with Sideloadly);
   - and publishes them as a GitHub pre-release, linking to
     [INSTALL.md](INSTALL.md).
   The Play bundle (`.aab`) is kept as a workflow artifact for T29.
4. Send friends the [Releases page](https://github.com/dariakyselytsia/cities/releases)
   link.

To get the files without publishing, run the Release workflow by hand
(Actions → Release → Run workflow): they appear as artifacts on the run.

## Building here

```bash
flutter build apk --release         # build/app/outputs/flutter-apk/app-release.apk
flutter build appbundle --release   # build/app/outputs/bundle/release/app-release.aab
```

Check the signer with
`D:\Android\Sdk\build-tools\36.1.0\apksigner.bat verify --print-certs <apk>`:
it should show `CN=Dariia Kyselytsia` and the SHA-256 above.

iOS can't be built here (no Mac). The **CI** workflow builds it, unsigned,
on every push.

## Store material

Everything T29 needs is in [`store/`](store/): the listing text in both
languages, the answers to the store forms and the screenshots. The privacy
policy's source is [`docs/privacy/index.html`](docs/privacy/index.html).
