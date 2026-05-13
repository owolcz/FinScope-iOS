A stock, cryptocurrency, and forex tracking application.

## Prerequisites
- iOS 17+ (simulator or physical device)
- Xcode 15.0+

## Getting Started
1. Clone the repository and open `FinScope.xcodeproj` in Xcode.
2. Ensure the backend is running locally on port `8000` (default address in `Services/APIClient.swift` is `http://localhost:8000`).
3. Select a simulator or device and press **Run** (⌘R).

## Project Structure
```
FinScope/
├── FinScope/           # Core application files, Theme, Assets
├── Models/             # Data models (Stock, News, etc.)
├── Services/           # Networking (APIClient)
├── ViewModels/         # View logic (MarketViewModel, DetailViewModel, ...)
├── Views/              # UI components and main screens
├── FinScopeTests/      # Unit tests
└── FinScopeTestsUI/    # UI tests
```

## Features
- Real-time stock market data tracking.
- Category-based sector browsing.
- Global search for symbols and companies.
- Detailed stock history charts.
- Favourites system with automatic reordering.
