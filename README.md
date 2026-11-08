# MileageLog

A personal mileage app: log petrol fill-ups (and, later, EV charges), see fuel economy and cost trends, record road trips with a battery-friendly GPS trace, and keep a Google Sheet or Dropbox export up to date.

Android first, built with Flutter so an iPhone build and a read-only web view can follow from the same code.

Status: **phase 3**: fill-ups, history, insights (weekly, monthly, yearly), import, backup and Sheets sync; GPS trip recording with Bluetooth auto-start; car care (service schedule, insurance, tyre pressures); home screen widgets (fill-up, trip start/stop, summary) and reminder notifications for service, WOF, rego, insurance, tyres and low fuel. See [docs/PLAN.md](docs/PLAN.md) for the product and technical plan, [docs/mockups/screens.html](docs/mockups/screens.html) for the screen mock-ups (open in a browser), and [docs/icon](docs/icon) for the adaptive icon layers.

## Building and updating the Android app

Every push to `main` runs [the build workflow](.github/workflows/build.yml), which tests the app and builds a release APK. The APK is attached to the run as an artifact and, when the signing secrets are present, published as a GitHub Release with a direct download link.

Updates install in place and keep settings and data because:

- the application ID `nz.mileagelog.app` and the database file name never change;
- every build is signed with the same release key, read from repository secrets (`MILEAGELOG_KEYSTORE_BASE64`, `MILEAGELOG_STOREPASSWORD`, `MILEAGELOG_KEYALIAS`; the PKCS12 key shares the store password) or locally from `android/key.properties`;
- the build number is the Actions run number, so each build is newer than the last;
- schema changes go through drift migrations that only add to the database;
- the More tab can share a JSON backup and merge one back in, as a safety net.

Without the secrets the workflow still builds, but signs with a throwaway debug key and names the APK `-UNSIGNED-debugkey`; such a build cannot update a properly signed install.

Local development:

```sh
flutter pub get
dart run build_runner build --delete-conflicting-outputs   # drift code generation
flutter test
flutter run
```

## Trip recording

Trips are recorded by a native Android foreground service (`TripRecorderService`) so they continue with the screen off or the app closed. GPS sampling adapts to speed to save battery: every 2 s below about 20 km/h (to catch short stops), every 5 s or 25 m when moving faster, and every 15 s after three minutes parked. Fixes are appended to a file in the app's private storage and imported into the database when the trip ends; stats (moving average, short stops, speed bands, harsh braking, climb) are computed in `lib/domain/trip_stats.dart`.

Bluetooth auto-start uses a manifest receiver for the car's connect and disconnect broadcasts. A trip starts when the chosen car connects and stops two minutes after it disconnects. Routes stay on the phone (and in the JSON backup); only map tiles are fetched from OpenStreetMap.

## Privacy rules for this repository

This repo holds code, documentation and fictional sample data only.

- No real fill-up history, GPS traces, exports, database files or spreadsheet IDs. `.gitignore` blocks `data/`, `exports/`, `*.db`, `*.csv` and `*.json` outside `sample_data/`.
- No secrets. OAuth client IDs, Dropbox keys and signing keys live in `.env` (gitignored) and are passed with `--dart-define`; `.env.example` documents the keys.
- No owner identity. Commits use an anonymous identity (see below), and no file carries an author name, vehicle registration or home location.
- `sample_data/` contains made-up records in the real import formats, for tests and screenshots.

Set the anonymous commit identity once per clone:

```sh
git config user.name "mileage-dev"
git config user.email "mileage-dev@users.noreply.github.com"
git config core.hooksPath .githooks
```

The pre-commit hook in `.githooks/` refuses a commit that contains an email address, a Google spreadsheet ID, a real-looking NZ registration plate, a GPS coordinate pair or a database/export file outside `sample_data/`.

## Layout

```
lib/data/        drift database, repository
lib/domain/      fuel-economy maths
lib/import/      Road Trip and Google Sheet CSV parsers
lib/sync/        Google Sheets sync
lib/trips/       bridge to the native trip recorder, import of finished trips
lib/backup/      JSON backup and restore
lib/ui/          screens
android/         Android project (stable app ID, signing from key.properties or env,
                 TripRecorderService foreground GPS service, CarBluetoothReceiver)
docs/            plan, mock-ups, icon
sample_data/     fictional sheet and Road Trip exports in the real import formats
scripts/         privacy check and helpers
.githooks/       pre-commit hook (enable with core.hooksPath)
```
