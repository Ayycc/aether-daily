# Aether Daily — AI Newspaper iPhone App

A beautiful, newspaper-style iPhone app focused on the hottest AI developments, with **X (Twitter)** as the primary source.

## Features
- Classic daily newspaper masthead ("THE AETHER DAILY")
- Hero breaking story + categorized article rows
- Elegant serif typography and newspaper aesthetic
- Real data seeded from high-engagement X posts (June 2026)
- Tap any article to open full detail view
- "View on X" button that opens the original post
- Pull-to-refresh simulation (ready for real X API v2 integration)
- Light newspaper theme (easy to switch to dark)

## How to Run (Xcode on Mac)

1. Open **Xcode** (macOS required)
2. Create a new project: **iOS App** → **SwiftUI** → Name it `AetherDaily`
3. Delete the default `ContentView.swift` and `AetherDailyApp.swift`
4. Copy the two files from this folder into your project:
   - `AetherDailyApp.swift`
   - `ContentView.swift`
5. Build & Run on iPhone simulator or device (iOS 17+ recommended)

## Extending to Real X Data

The app currently uses curated real posts from X. To make it fully dynamic:

- Add the official **X API v2** (bearer token)
- Use `TwitterAPI` or `TwitterKit` (or raw `URLSession`)
- Replace `sampleArticles` with a `@State` fetched from `https://api.twitter.com/2/tweets/search/recent`
- Add query: `AI OR LLM OR "machine learning" min_faves:100` + recent filter

## Screenshots / Preview

The app renders beautifully on iPhone 15/16 Pro with:
- Large serif headlines
- Category pills
- Heart icons showing engagement
- Clean detail sheets

## Future Ideas
- Real-time X streaming via WebSocket
- Personalized following list
- AI summary generation of threads
- Dark mode newspaper variant
- Widget for Today view (top AI story)

Built with ❤️ using SwiftUI + real X data.