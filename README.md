# DivKitStarter

Production-oriented UIKit + DivKit starter for local SDUI development.

## What Is Included

- Native UIKit app with DivKit `32.53.0`
- Local DivKit JSON loading from `http://localhost:3000/api/`
- Loading state, network error state, retry, pull to refresh
- SDUI actions:
  - `sdui://toast?text=Hello`
  - `sdui://open?path=detail&title=Detail`
  - `sdui://back`
- Lightweight Node/Express local server
- Structured server layers: routes, controllers, services, repositories, validators, middlewares
- Server tests for health, card loading, missing cards, and invalid page names

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

server/
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

## Run Local Server

```bash
cd /Users/han/Desktop/DivKitStarter/server
npm install
npm run dev
```

Available endpoints:

```text
GET http://localhost:3000/health
GET http://localhost:3000/api/
GET http://localhost:3000/api/detail
```

Edit files in `server/cards/`, then pull to refresh in the iOS app to reload JSON.

## Server Scripts

```bash
npm run dev
npm run start
npm run check
npm test
```

## Run iOS App

```bash
xcodebuild \
  -project UIKitIntegration/DivKitStarter.xcodeproj \
  -scheme DivKitStarter \
  -destination 'platform=iOS Simulator,name=iPhone 17,OS=26.5' \
  build
```

The default API base URL is configured in:

```text
UIKitIntegration/DivKitStarter/Info.plist
```

Key:

```text
API_BASE_URL = http://localhost:3000/api/
```

For a physical iPhone, replace `localhost` with the Mac local network IP, for example:

```text
http://192.168.1.10:3000/api/
```

## SDUI Action Protocol

Show toast:

```text
sdui://toast?text=Hello%20DivKit
```

Open a page:

```text
sdui://open?path=detail&title=详情
```

Go back:

```text
sdui://back
```

Page names only allow letters, numbers, hyphen, and underscore.

## Server Evolution Path

The local server currently reads JSON cards from `server/cards`.

When building the real server, keep the existing route/controller/service shape and replace only the repository layer:

```text
server/src/repositories/card.repository.js
```

Possible production data sources:

- Database
- CMS
- Admin-authored JSON card storage
- Remote SDUI rendering service

This keeps iOS, routes, controllers, and service contracts stable while the backend data source evolves.
