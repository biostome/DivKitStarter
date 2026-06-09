# DivKitStarter

[![CI](https://github.com/biostome/DivKitStarter/actions/workflows/ci.yml/badge.svg)](https://github.com/biostome/DivKitStarter/actions/workflows/ci.yml)
[![CodeQL](https://github.com/biostome/DivKitStarter/actions/workflows/codeql.yml/badge.svg)](https://github.com/biostome/DivKitStarter/actions/workflows/codeql.yml)

DivKitStarter is a production-oriented UIKit + DivKit starter for building server-driven iOS interfaces with a lightweight local Node.js backend.

The project gives you a working SDUI loop out of the box: edit DivKit JSON on the server, refresh the iOS app, validate page metadata and actions, and keep both sides covered by CI. It is meant to be small enough to understand quickly, but structured enough to evolve into a real backend-backed SDUI system.

## Why This Exists

Server-driven UI projects often get stuck between a quick demo and production architecture. This starter keeps the demo loop fast while adding the pieces that usually matter later:

- A UIKit app that renders DivKit cards from an HTTP API
- A local Express server with clear route, controller, service, repository, and validator layers
- Page metadata for publishing, versioning, refresh behavior, and client capabilities
- A custom action protocol for native navigation, modal flows, toast messages, and web links
- Server tests, iOS unit tests, CodeQL scanning, Dependabot, and GitHub Actions CI

## What Is Included

- Native UIKit app with DivKit `32.53.0`
- Local DivKit JSON loading from `http://localhost:3000/api/`
- Loading state, network error state, retry, pull to refresh
- Official DivKit actions:
  - built-in typed actions, for example `copy_to_clipboard`
  - native app actions through official `typed: { "type": "custom" }` + `payload`
- Lightweight Node/Express local server
- Structured server layers: routes, controllers, services, repositories, validators, middlewares
- Server tests for health, card loading, missing cards, and invalid page names
- iOS unit tests for action parsing, response metadata, and response cache behavior
- GitHub Actions workflows for CI, CodeQL scanning, dependency maintenance, release creation, and iOS test diagnostics

## Project Structure

```text
UIKitIntegration/
  DivKitStarter.xcodeproj
  DivKitStarter/
    AppDelegate.swift
    AppConfiguration.swift
    DivHostViewController.swift
    DivKitNetworkClient.swift
    DivKitResponseCache.swift
    LoadingStateView.swift
    SDUIActionHandler.swift
    ToastPresenter.swift

Server/
  cards/
    home.json
    detail.json
  src/
    app.js
    server.js
    config/
    controllers/
    middlewares/
    repositories/
    routes/
    services/
    utils/
    validators/
  test/
```

## Quick Start

Start the local server:

```bash
cd Server
npm install
npm run dev
```

Then build or run the iOS app from Xcode using:

```text
UIKitIntegration/DivKitStarter.xcodeproj
```

The app loads cards from:

```text
http://localhost:3000/api/
```

Edit JSON files in `Server/cards/`, then pull to refresh in the iOS app to reload the UI.

## Run Local Server

```bash
cd Server
npm install
npm run dev
```

Available endpoints:

```text
GET http://localhost:3000/health
GET http://localhost:3000/api/
GET http://localhost:3000/api/detail
```

## Server Scripts

```bash
npm run dev
npm run start
npm run check
npm test
```

## Server Environment

```bash
PORT=3000
NODE_ENV=development
CARDS_DIRECTORY=./cards
DIVKIT_SCHEMA_DIR=
ALLOW_DRAFT_PAGES=false
```

`CARDS_DIRECTORY` is resolved from the `Server` directory. Keep the `Service -> Repository` contract stable when replacing local JSON files with a database, CMS, or remote renderer.

Download the official DivKit schema when you want strict schema validation:

```bash
npm run schema:download
DIVKIT_SCHEMA_DIR=./schema/divkit npm test
```

`Server/schema/` is generated and ignored by git.

## Page Metadata

Every card can include a `page` object used by native clients and server validation:

```json
{
  "id": "home",
  "title": "首页",
  "version": 1,
  "publishedAt": "2026-06-09T00:00:00.000Z",
  "status": "published",
  "refreshable": true,
  "minClientVersion": 1,
  "requiredCapabilities": ["toast", "open", "back"]
}
```

The server also returns `X-SDUI-Page-Id`, `X-SDUI-Page-Version`, and `X-SDUI-Published-At` headers when metadata is present.

`status` controls publication:

- `published`: visible
- `draft`: hidden unless `ALLOW_DRAFT_PAGES=true`
- `archived`: hidden

## Run iOS App

```bash
xcodebuild \
  -project UIKitIntegration/DivKitStarter.xcodeproj \
  -scheme DivKitStarter \
  -destination 'platform=iOS Simulator,name=iPhone 17,OS=26.5' \
  build
```

Run iOS unit tests:

```bash
xcodebuild \
  -project UIKitIntegration/DivKitStarter.xcodeproj \
  -scheme DivKitStarter \
  -destination 'platform=iOS Simulator,name=iPhone 17,OS=26.5' \
  test
```

iOS API environments are defined in:

```text
UIKitIntegration/Config/Debug.xcconfig
UIKitIntegration/Config/Release.xcconfig
```

The default API base URL is configured in:

```text
UIKitIntegration/Config/Debug.xcconfig
```

Key:

```text
API_BASE_URL = http://localhost:3000/api/
```

For a physical iPhone, replace `localhost` with the Mac local network IP, for example:

```text
http://192.168.1.10:3000/api/
```

## DivKit Action Protocol

Show toast:

```json
{
  "log_id": "toast",
  "typed": { "type": "custom" },
  "payload": {
    "action": "toast",
    "text": "Hello DivKit"
  }
}
```

Open a page:

```json
{
  "log_id": "open_detail",
  "typed": { "type": "custom" },
  "payload": {
    "action": "open",
    "path": "detail",
    "title": "详情"
  }
}
```

Go back:

```json
{
  "log_id": "back",
  "typed": { "type": "custom" },
  "payload": {
    "action": "back"
  }
}
```

Page names only allow letters, numbers, hyphen, and underscore.

## Server Evolution Path

The local server currently reads JSON cards from `Server/cards`.

When building the real server, keep the existing route/controller/service shape and replace only the repository layer:

```text
Server/src/repositories/card.repository.js
```

Possible production data sources:

- Database
- CMS
- Admin-authored JSON card storage
- Remote SDUI rendering service

This keeps iOS, routes, controllers, and service contracts stable while the backend data source evolves.
