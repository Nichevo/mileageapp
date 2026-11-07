# MileageLog

A personal mileage app: log petrol fill-ups (and, later, EV charges), see fuel economy and cost trends, record road trips with a battery-friendly GPS trace, and keep a Google Sheet or Dropbox export up to date.

Android first, built with Flutter so an iPhone build and a read-only web view can follow from the same code.

Status: **planning**. No app code yet. See [docs/PLAN.md](docs/PLAN.md) for the product and technical plan, [docs/mockups/screens.html](docs/mockups/screens.html) for the screen mock-ups (open in a browser), and [docs/icon](docs/icon) for the adaptive icon layers.

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
docs/            plan, mock-ups, icon
sample_data/     fictional sheet and Road Trip exports in the real import formats
scripts/         privacy check and helpers
.githooks/       pre-commit hook (enable with core.hooksPath)
```
