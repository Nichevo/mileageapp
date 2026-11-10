# MileageLog

A personal mileage app: log petrol fill-ups (and, later, EV charges), see fuel economy and cost trends, record road trips with a battery-friendly GPS trace, and keep a Google Sheet or Dropbox export up to date.

Android first, built with Flutter so an iPhone build and a read-only web view can follow from the same code.

Status: **phase 5**: fill-ups, history, insights (weekly, monthly, yearly), import, backup and Sheets sync; GPS trip recording with Bluetooth auto-start; car care (service schedule, insurance, tyre pressures); home screen widgets (fill-up, trip start/stop, summary, 2x2 quick, 4x2 dashboard) and reminder notifications for service, WOF, rego, insurance, tyres and low fuel; fuel price check against MBIE's weekly national averages, with a shortcut to Gaspy. See [docs/PLAN.md](docs/PLAN.md) for the product and technical plan, [docs/mockups/screens.html](docs/mockups/screens.html) for the screen mock-ups (open in a browser), and [docs/icon](docs/icon) for the adaptive icon layers.

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

Bluetooth auto-start uses a manifest receiver for the car's connect and disconnect broadcasts. Each vehicle can have its own Bluetooth device (Trips > car settings); a trip starts when one of them connects, is saved to that vehicle, and the app switches to that vehicle while it records. It stops two minutes after that same device disconnects, so another linked car's Bluetooth can't end it. Every trip, however it starts (app, widget, notification or Bluetooth), notes its vehicle in the recording the moment it starts: the Bluetooth device's vehicle, otherwise the vehicle selected in the app, which the app keeps the recorder told about. A trip can still be moved to another vehicle from its page. Routes stay on the phone (and in the JSON backup), apart from the optional road lookup below.

Road types and traffic lights (`lib/domain/road_match.dart`, `lib/trips/road_lookup.dart`): after a trip, a simplified route, minus the first and last 300 m, is sent to the public Overpass API to fetch traffic signal nodes and drivable roads nearby. The track is matched to the nearest road heading the same way (within 25 m) to split the distance into motorway, highway/main, suburban and local roads, and stops within 50 m of a signalised intersection are counted as waits at lights. It can be switched off under Trips > car settings.

Weather and elevation (`lib/domain/trip_weather.dart`, `lib/trips/weather_lookup.dart`): after a trip, the free Open-Meteo API is asked for the hourly weather near the middle of the route (location rounded to about 1 km) and for ground heights at points every 200 m along it (minus the first and last 300 m). The trip page shows temperature, rain and wind relative to the direction of travel, plus climb, descent and an elevation chart by distance. It has its own switch under Trips > car settings.

Loan and rental cars (`lib/domain/loan.dart`, `lib/ui/loan_car_page.dart`, schema v6 `vehicles.ownership`, `archived_at`, `loan_json`): added from the vehicle switcher with make, model, who it's from and the pick-up odometer and fuel level; rentals also keep the booking reference, locations, due-back time (with a reminder), cost, excess, km allowance and fuel policy. Their fill-ups aren't queued for Google Sheets and they get no economy warnings. "Hand back" records the return, shows km, trips, fuel bought and fuel level difference, archives the car, removes its Bluetooth link and switches back to your own car. Any vehicle can be archived (sold); archived vehicles are under Past vehicles with their trips. Reminders now cover every vehicle you still have, not just the one shown.

Documents (`lib/data/attachment_store.dart`, `lib/ui/attachments.dart`, schema v5 `attachments` table): photos (camera or gallery, scaled to 2400 px) and PDFs can be attached to service, WOF and other care records and to insurance policies, or added on their own under More > Documents (WOF, service invoice, insurance, registration, tyres, other). Files are copied into the app's private storage, so they survive updates, and the JSON backup carries them as base64 so a restore on a new phone brings them back.

Comparing trips (`lib/domain/route_compare.dart`, `lib/trips/route_compare_service.dart`): each route is resampled every 50 m and matched against other trips' points within 40 m heading the same way, allowing 300 m gaps. Runs of 2 km or more are shared stretches, so trips only need to overlap in part. A trip page lists the stretches other trips also drove (time, rank, usual time), and a comparison page charts time, speeds, stops and red lights over the dates, with medians for weekday peaks, other times, weekends, rain and dry. Trips > Routes lists the most-driven stretches. Matching runs on the phone in a background isolate; nothing is sent anywhere.

Places (`lib/domain/places.dart`): when two or more trips start or end within about 150 m of each other, the Trips page offers to name the spot (Home, Work or any name). Trips that still have their automatic name are then titled "Home → Work" and can be filtered by place. Either end of any trip can also be named from the trip page. Places are kept in the app's settings on the phone only.

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

## Fuel prices

`lib/prices/national_prices.dart` downloads MBIE's public weekly fuel price monitoring table (national average board price per fuel, in cents per litre) at most every three days and keeps a copy on the phone. `lib/domain/prices.dart` compares each fill-up with the national average for its week and ranks your stations by their average difference. Gaspy has no public API, so the app only opens Gaspy (package `nz.hwem.gaspy`) for live station prices.

## Plate lookup

More > Vehicle can fill in the car's details from its number plate using CarJam's ABCD API (`lib/vehicle/carjam_client.dart`) with the user's own API key, entered in the app and kept on the phone. Lookups are charged to that CarJam account. The WOF and registration expiry dates it returns can set the reminder due dates. Without a key, "Open on CarJam" opens the free web page instead. The plate is stored only in the phone's settings.

## Battery

The trip recorder notes the phone's battery % at the start and end of each trip, and whether it was charging, so the trip page shows what recording actually cost.

## Vehicles and charging

Tap the vehicle name at the top of Home to switch vehicles or add one. Each vehicle has a type (petrol, diesel, hybrid, plug-in hybrid or electric) that decides which buttons and units the app shows (`lib/domain/energy.dart`). Charges are energy events of kind `charge`: kWh comes from the charger, or from the battery % before and after when the battery size is set, and home charges are costed from the home power rate kept in settings. Economy is worked out separately for fill-ups (L/100 km) and charges (kWh/100 km); a plug-in hybrid can switch between them in Insights. Charges are not sent to the Google Sheet.

## Z Sharetank

More > Z Sharetank records fuel bought ahead at a locked price. A fill-up paid with "Sharetank" draws on those purchases oldest first (`lib/domain/sharetank.dart`), so its cost is what the litres actually cost; the pump price, if entered, gives the saving. Purchases belong to the person, not a vehicle. Adding or changing a purchase costs earlier Sharetank fill-ups again.

## Tolls and parking

Tolls and parking are expenses of kind `toll` or `parking`, optionally tied to a trip (`Expenses.tripId`). The OpenStreetMap road lookup also notes ways tagged `toll=yes`. When a trip used one and no toll is logged for it, the trip page links to the NZTA payment page and a reminder fires the next morning and the day before the 5-day deadline (off in Reminders for toll account holders).

## EV running costs

More > "Would an EV pay off?" takes the last 12 months of fill-ups on the current vehicle and costs the same distance as an EV (`lib/domain/ev_costs.dart`): energy use, share charged at home, public charging price and road user charges are adjustable. For EVs, Insights shows where you charge (home, public AC, fast DC) and the price paid at each. EVs, plug-in hybrids and diesels can record the odometer their RUC licence runs to, for a reminder before it runs out.
