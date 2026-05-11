# FinScope iOS

Aplikacja do śledzenia kursów akcji, kryptowalut i walut forex.

## Wymagania

- Xcode 15+
- iOS 17+ (symulator lub fizyczne urządzenie)
- Uruchomiony backend ([finscope-backend](https://github.com/owolcz/finscope-backend))

## Uruchomienie

1. Sklonuj repozytorium i otwórz `FinScope.xcodeproj` w Xcode
2. Upewnij się, że backend działa lokalnie na porcie `8000` (domyślny adres w `Services/APIClient.swift` to `http://localhost:8000`)
3. Wybierz symulator lub urządzenie i naciśnij **Run** (⌘R)


## Struktura projektu

```
FinScope/
├── Models/          # Modele danych (Stock, StockHistory, ...)
├── Services/        # APIClient — komunikacja z backendem
├── ViewModels/      # Logika widoków (MarketViewModel, DetailViewModel, ...)
└── Views/           # Widoki SwiftUI (MarketView, StockDetailView, SearchView, ...)
```
