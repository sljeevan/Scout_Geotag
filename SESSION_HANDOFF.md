# Scout Geotag - Session Handoff (May 22, 2026)

## Completed Changes

### Branding rename: `SitePin` -> `Scout`
- Updated user-facing app name across platforms:
  - `android/app/src/main/AndroidManifest.xml` (`android:label="Scout"`)
  - `ios/Runner/Info.plist` (`CFBundleDisplayName`, `CFBundleName`, permission text)
  - `web/index.html` (`<title>Scout</title>`, Apple web app title)
  - `web/manifest.json` (`name`, `short_name` = `Scout`)
  - `windows/runner/main.cpp` (window title)
  - `windows/runner/Runner.rc` (Windows metadata name fields)
  - `linux/runner/my_application.cc` (window/header title)
  - `macos/Runner/Configs/AppInfo.xcconfig` (`PRODUCT_NAME = Scout`)
- Updated in-app visible strings:
  - `lib/main.dart` (`MaterialApp.title = 'Scout'`)
  - `lib/features/auth/login_screen.dart` (`SitePin` -> `Scout`)
  - `lib/features/profile/profile_screen.dart` (`SitePin User` -> `Scout User`)

### Login subtitle update
- Changed login subtitle:
  - `lib/features/auth/login_screen.dart`
  - `Construction Site Geo-Tagger` -> `Geo-Tag`

### Web theme color alignment (Android light green parity)
- Updated web theme colors to light green:
  - `web/index.html` meta theme color = `#F2FAF4`
  - `web/manifest.json` theme/background color = `#F2FAF4`

## Deployment Status (Nginx)

- Domain: `https://sitepin.flss.in`
- Nginx root discovered and used: `/var/www/sitepin`
- Deploy method used successfully:
  1. `flutter build web`
  2. `sudo rsync -av --delete build/web/ /var/www/sitepin/`
  3. `sudo nginx -t && sudo systemctl reload nginx`
- Live verification confirmed:
  - Title and manifest show `Scout`
  - Theme colors show `#F2FAF4`
  - Login subtitle changed to `Geo-Tag`

## Git/GitHub Status

- Local git repo was initialized and committed.
- Pushed successfully to:
  - `https://github.com/sljeevan/Scout_Geotag.git`
  - branch: `main`

## Codemagic / iOS Setup Progress

### `codemagic.yaml` updated
- File: `codemagic.yaml`
- Current key values:
  - `BUNDLE_ID: "com.flss.scout"`
  - `APP_STORE_APPLE_ID: "6772134481"`
- Workflow in use: `ios-testflight`

### iOS bundle IDs aligned in project
- Updated:
  - `ios/Runner.xcodeproj/project.pbxproj`
  - `macos/Runner/Configs/AppInfo.xcconfig`
- Current bundle IDs:
  - App: `com.flss.scout`
  - RunnerTests: `com.flss.scout.RunnerTests`

## Current Blocker

Codemagic iOS build fails with:
- `No matching profiles found for bundle identifier "com.flss.scout" and distribution type "app_store"`

This indicates missing Apple signing assets (profile/certificate) for the bundle ID.

## Important Security Note

- An App Store Connect private key was accidentally shared in chat.
- It must be considered compromised.
- Action required/completed guidance:
  - Revoke old key in App Store Connect.
  - Create a new API key.
  - Update Codemagic secrets with new key data.

## Next Steps (Exact)

1. In Apple Developer (same team: `BCT87DAQCA`):
   - Create **Apple Distribution** certificate (if absent).
   - Create **App Store** provisioning profile for `com.flss.scout`.

2. In Codemagic:
   - Ensure env secrets are set with the **new rotated** key:
     - `APP_STORE_CONNECT_PRIVATE_KEY`
     - `APP_STORE_CONNECT_KEY_IDENTIFIER`
     - `APP_STORE_CONNECT_ISSUER_ID`
   - Refresh/sync iOS code signing assets from Apple portal.
   - Confirm profile appears for:
     - Bundle ID `com.flss.scout`
     - Distribution type `app_store`

3. Re-run workflow:
   - `ios-testflight`

4. After successful upload:
   - App Store Connect -> TestFlight
   - Wait for processing
   - Add internal testers

## Useful Commands Used

```bash
# Deploy web to Nginx
flutter build web
sudo rsync -av --delete /root/GeoLocationMapper/sitepin_flutter/build/web/ /var/www/sitepin/
sudo nginx -t && sudo systemctl reload nginx

# Push code
cd /root/GeoLocationMapper/sitepin_flutter
git add .
git commit -m "..."
git push -u origin main
```

---

# Session Update (May 23, 2026)

## What Happened

- Continued debugging Codemagic iOS TestFlight failures for `ios-testflight`.
- Initial failures were signing-related:
  - `No matching profiles found for bundle identifier "com.flss.scout" and distribution type "app_store"`
  - `Cannot save Signing Certificates without certificate private key`
- User fixed Apple-side assets (created profile/certificate), but build still failed due to workflow/script issues and then deployment target mismatch.

## Codemagic / Git Changes Made Today

### 1) Fixed wrong env group in `codemagic.yaml`
- Changed group from `app_store_credentials` to actual configured group `Scout_geotag`.
- Commit: `5a9a7e3`
- Message: `ci: use correct codemagic env group for app store creds`

### 2) Removed manual signing fetch script
- Removed custom step:
  - `app-store-connect fetch-signing-files "$BUNDLE_ID" --type IOS_APP_STORE --create`
- Kept:
  - `xcode-project use-profiles`
- Reason: manual fetch step repeatedly failed with private-key mismatch while built-in signing setup was already succeeding.
- Commit: `1eac4eb`
- Message: `ci: remove manual fetch-signing-files step`

### 3) Fixed iOS minimum deployment target
- Build then failed at `Build signed IPA` with:
  - `google_maps_flutter_ios requires higher minimum iOS deployment version`
  - Required minimum: `iOS 14.0`
- Added missing `ios/Podfile` with:
  - `platform :ios, '14.0'`
  - standard Flutter pod setup
  - post_install deployment target set to `14.0`
- Updated `ios/Runner.xcodeproj/project.pbxproj` deployment targets from `13.0` to `14.0`.
- Commit: `ab17336`
- Message: `ios: set minimum deployment target to 14.0`

## Final Outcome (Today)

- Build ID: `6a116031e49a6883a98e0d5c`
- Workflow: `ios-testflight`
- Status: **finished (success)**
- Successful steps included:
  - Set up code signing identities
  - Set up code signing settings on Xcode project
  - Build signed IPA
  - Publishing

## Current Project State

- iOS signing issue is resolved.
- Codemagic workflow is building successfully from `main`.
- Next validation is in App Store Connect TestFlight processing and tester assignment.

## Immediate Next Steps

1. Open App Store Connect (`https://appstoreconnect.apple.com`) → My Apps → `Scout` → TestFlight.
2. Wait for build processing to complete.
3. Add internal testers and verify install.
4. Run smoke tests on device:
   - Login
   - Map/geotag flow
   - Profile screen
5. Security cleanup:
   - Revoke/rotate Codemagic API token that was shared during troubleshooting.

---

# Session Update (May 23, 2026 - Late Update)

## What Happened

- Investigated why TestFlight remained empty despite a prior "successful" Codemagic build.
- Queried Codemagic API directly and confirmed root cause:
  - Build `6a116031e49a6883a98e0d5c` had `Publishing: success` but **no IPA artifact**.
  - Publishing log: `No artifacts were found`.
  - Build log error: `exportArchive "Runner.app" requires a provisioning profile.`
- Conclusion: the pipeline completed, but export failed, so nothing was uploaded to App Store Connect.

## Changes Made

### 1) Fixed IPA export in Codemagic
- File: `codemagic.yaml`
- Updated build command to include explicit export options generated by Codemagic:
  - `--export-options-plist=/Users/builder/export_options.plist`
- Commit: `296f917`
- Message: `ci: fix ios ipa export with codemagic export options plist`

### 2) Added export compliance plist key
- File: `ios/Runner/Info.plist`
- Added:
  - `ITSAppUsesNonExemptEncryption` = `false`
- Commit: `edc93af`
- Message: `ios: declare non-exempt encryption usage in Info.plist`

### 3) Fixed App Store warning ITMS-90683
- Apple warning received for build 16:
  - Missing `NSLocationAlwaysAndWhenInUseUsageDescription`
- File: `ios/Runner/Info.plist`
- Added:
  - `NSLocationAlwaysAndWhenInUseUsageDescription`
- Commit: `723b3fb`
- Message: `ios: add missing always-and-when-in-use location purpose string`

### 4) Increased app icon visual size
- Issue: icon appeared too small on iPhone home screen.
- Action:
  - Enlarged icon artwork framing.
  - Regenerated launcher icons (iOS and Android) using `flutter_launcher_icons`.
- Commit: `76a1823`
- Message: `chore: enlarge app icon artwork and regenerate launcher icons`

## Codemagic Build Timeline (Latest)

- Build `6a11b2dd155d2c8b3f0d1419` (commit `296f917`):
  - Status: `finished`
  - Result: IPA created (`Scout.ipa`, build number 16), App Store Connect distribution task created (`pending` at time of check).
- Build `6a11b6f41023a04cad3bb932` (commit `723b3fb`):
  - Triggered with plist purpose-string fix.
  - Status at last check: `queued` (subsequent status not re-polled in this session).
- Build `6a11b94ed987e41728a159fe` (commit `76a1823`):
  - Triggered with icon size fix.
  - Status at last check: `building` (in `Build signed IPA` step).

## Current Project State

- Main branch includes all fixes through commit `76a1823`.
- iOS pipeline configuration now supports artifact export/upload.
- Export compliance and location purpose-string keys are in `Info.plist`.
- App icon assets were regenerated with larger visual footprint.

## Immediate Next Steps

1. Monitor build `6a11b94ed987e41728a159fe` to completion in Codemagic.
2. In App Store Connect TestFlight, verify newest uploaded build appears and finishes processing.
3. Validate:
   - No ITMS-90683 warning on new upload.
   - Icon size appearance is correct on installed iPhone build.
4. Add internal testers and run smoke tests (login, map/geotag flow, profile).
5. Security cleanup:
   - Revoke/rotate Codemagic API token shared in chat.
