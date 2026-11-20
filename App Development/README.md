# Shop Scraper Pro • E-Commerce Intelligence & Product Research Platform

A modern, responsive, and professional SaaS application built with **Flutter**, **Dart**, and **Material 3**. Designed for researching e-commerce shops, analyzing competitor storefronts, discovering high-margin products, and benchmarking market saturation across **Etsy**, **Amazon**, **eBay**, and **Shopify**.

---

## 🎨 Design System & Theme

Crafted with a sleek, dark SaaS dashboard interface adhering strictly to the brand guidelines:

| Element | Hex Code | Purpose |
|---|---|---|
| **Primary Background** | `#000000` | Deep black foundation for zero eye strain |
| **Secondary Background** | `#171717` | Card surfaces, inputs, and sidebars |
| **Card Background** | `#171717` | Rounded elevated content cards |
| **Primary Text** | `#FFFFFF` | High-contrast headers and bold titles |
| **Secondary Text** | `#A7A7A7` | Subtitles, labels, and metadata |
| **Primary Green** | `#00A878` | Call-to-action buttons, active indicators |
| **Accent Lime** | `#B7F34A` | High Opportunity Scores, KPI highlights |
| **Border Color** | `#303030` | Subtle clean card and divider outlines |

---

## 📱 Supported E-Commerce Platforms

- 🟠 **Etsy**: Handmade boutiques, printable digital art, print-on-demand items, and tag conversion analytics.
- 🟡 **Amazon**: FBA private label storefronts, Buy Box dynamics, estimated sales velocity, and BSR metrics.
- 🔵 **eBay**: Refurbished electronics, verified authentic streetwear/sneakers, and sold-listing market floors.
- 🟢 **Shopify**: Direct-to-Consumer (DTC) lifestyle brands, viral social trends, and average order value (AOV).

---

## 🚀 Key Modules & Capabilities

### Module 1: Executive Dashboard
- **Aggregate Metrics**: Tracked storefronts, indexed catalog items, saved watchlists, and estimated monthly GMV.
- **Platform Matrix**: Real-time breakdown of Etsy, Amazon, eBay, and Shopify metrics.
- **Recent Analysis & Feeds**: Quick jumps to recently parsed shops and trending opportunity items.

### Module 2: Shop Scraper & Storefront Analyzer
- Public shop URL parser with one-click demo presets.
- Interactive multi-stage scraping simulation with real-time feedback.
- In-depth storefront analysis across 4 dedicated tabs:
  1. **Listings**: Real catalog items with sales volume estimates.
  2. **Tags & Niches**: High-frequency search algorithm tags and category breakdowns.
  3. **Competitor Overlap**: Direct overlap percentage and pricing disparity.
  4. **Strategic SWOT Report**: Algorithmic strengths, vulnerabilities, and actionable advice.

### Module 3: Product Research Engine
- **Search & Filters**: Instant keyword search (titles, tags, categories, shops).
- **Advanced Filtering**: Marketplace selection, saturation level (`Low`, `Medium`, `High`), and price range slider.
- **Sorting**: Highest Opportunity Score (1-100), Price Low-to-High, Price High-to-Low, Most Reviews, Newest.
- **Adaptive Layout**: Quick toggle between responsive Grid View and List View.

### Module 4: Competitor Intelligence Matrix
- **Head-to-Head Comparison**: Select any baseline shop and compare against competitor storefronts.
- Price advantage percentages, catalog overlap, rating discrepancies, and revenue comparisons.
- Custom dialogue to add and monitor new competitor brands.

### Module 5: Product Details & Opportunity Breakdown
- Multi-image gallery with thumbnail preview strip.
- Price comparison, original price strike-through, and discount percentage.
- Expandable product description and high-intent tag cloud.
- Market saturation density, estimated monthly sales volume, and related product recommendations.

### Module 6: Saved Research & Watchlists
- Interactive session bookmarks for both products and storefronts.
- Search within saved items and undo support on deletion.

### Module 7: Reports & Analytics
- Monthly GMV revenue comparison bar charts powered by `fl_chart`.
- Marketplace share and growth trends.
- Comprehensive market reports with exportable summaries.

### Module 8: Profile & Future Python Backend Connectivity
- User profile, tier quotas (Shops and Products analyzed), and active sessions.
- **Python Backend Configuration**: REST API Base URL input (`http://localhost:8000/api/v1`), API key field, and live "Test Backend Ping" connectivity test.

---

## 🗂️ Project Structure

```
lib/
├── app.dart                                # MaterialApp, Theme & Named Routes
├── main.dart                               # Entry point with system overlay styling
├── core/
│   ├── constants/
│   │   ├── app_colors.dart                 # Exact hex color definitions
│   │   └── app_strings.dart                # System strings and titles
│   ├── routes/
│   │   └── app_routes.dart                 # Centralized 16-screen route constants
│   ├── theme/
│   │   └── app_theme.dart                  # Material 3 dark SaaS theme configuration
│   └── widgets/
│       ├── custom_button.dart              # Primary, secondary, outline, lime buttons
│       ├── custom_card.dart                # Rounded dark border cards
│       ├── custom_textfield.dart           # Form fields with icons & validation
│       └── loading_widget.dart             # Shimmers, spinners, empty & error states
├── data/
│   └── demo_data.dart                      # Realistic catalog data for all 4 platforms
├── models/
│   ├── shop_model.dart                     # Storefront schema & JSON serialization
│   ├── product_model.dart                  # Item schema with opportunity scores
│   ├── competitor_model.dart               # Competitor comparison schema
│   ├── research_model.dart                 # Analytical reports & platform metrics
│   └── user_model.dart                     # User profile & backend settings schema
├── services/
│   ├── shop_service.dart                   # Reactive shop state & scraping logic
│   ├── product_service.dart                # Search, filter, sorting & bookmark logic
│   └── research_service.dart               # Analytics, logging & backend ping test
├── shared/
│   ├── navigation/
│   │   └── main_shell.dart                 # Desktop collapsible sidebar & mobile nav bar
│   └── widgets/
│       ├── app_network_image.dart          # Resilient image loader with fallback icons
│       ├── marketplace_badge.dart          # Brand badges (Etsy, Amazon, eBay, Shopify)
│       ├── metric_card.dart                # SaaS KPI statistic cards
│       └── score_indicator.dart            # Opportunity score circular/linear meter
└── features/
    ├── splash/                             # 1. Splash Screen
    ├── onboarding/                         # 2. Onboarding Screen
    ├── authentication/                     # 3. Login & 4. Registration Screens
    ├── dashboard/                          # 5. Executive Dashboard
    ├── shop_analyzer/                      # 6. Scraper, 7. Marketplaces, 8. Shop Analysis
    ├── product_research/                   # 9. Product Research Engine
    ├── product_details/                    # 10. Product Details Screen
    ├── competitor_analysis/                # 11. Competitor Analysis Screen
    ├── saved_research/                     # 12. Saved Products, 13. Saved Shops, 14. Tab View
    ├── reports/                            # 15. Reports & Analytics Screen
    ├── profile/                            # 16. User Profile Screen
    └── settings/                           # 17. Workspace Settings Screen
```

---

## 🛠️ Verification & Testing Status

- **Flutter Analyze**: `No issues found!` (0 errors, 0 warnings).
- **Flutter Test Suite**: `15 out of 15 tests passed` (`test/unit_test.dart` & `test/widget_test.dart`).

---

## 📦 How to Run

### 1. Web (Google Chrome)
```bash
# Run on local web server
flutter run -d web-server --web-port=8080 --web-hostname=localhost
```
Then navigate to `http://localhost:8080`.

### 2. Android Device or Emulator
```bash
# Launch on connected device
flutter run
```

### 3. Generated Android APKs
- **Production Release APK**:
  `build/app/outputs/flutter-apk/app-release.apk` (52.0 MB)
- **Debug APK**:
  `build/app/outputs/flutter-apk/app-debug.apk`

---

## 🐍 Future Python Backend Integration Guide

The frontend services are decoupled and ready for REST API connectivity:

1. In the application, navigate to **Settings** (`/settings`).
2. Point **Backend REST API Base URL** to your local or deployed Python service (e.g. `http://localhost:8000/api/v1`).
3. Click **"Test Backend Ping"** to verify connection.
4. Planned Python Backend Endpoints:
   - `POST /api/v1/scrape`: Receives `{ "marketplace": "Etsy", "url": "..." }`, returns `ShopModel`.
   - `GET /api/v1/products`: Supports query params `?search=...&marketplace=...&min_price=...`.
   - `GET /api/v1/competitors/{shop_id}`: Returns competitor overlap and pricing disparity.
   - `POST /api/v1/reports/export`: Generates downloadable CSV / PDF intelligence reports.
