---
name: Aether Blue
colors:
  surface: '#f8f9ff'
  surface-dim: '#c6dbff'
  surface-bright: '#f8f9ff'
  surface-container-lowest: '#ffffff'
  surface-container-low: '#eff3ff'
  surface-container: '#e6eeff'
  surface-container-high: '#dde9ff'
  surface-container-highest: '#d4e3ff'
  on-surface: '#001c39'
  on-surface-variant: '#414753'
  inverse-surface: '#0e3157'
  inverse-on-surface: '#ebf1ff'
  outline: '#717784'
  outline-variant: '#c0c6d5'
  surface-tint: '#005eb1'
  primary: '#005cad'
  on-primary: '#ffffff'
  primary-container: '#0075d9'
  on-primary-container: '#fefcff'
  inverse-primary: '#a7c8ff'
  secondary: '#0057c2'
  on-secondary: '#ffffff'
  secondary-container: '#246fe7'
  on-secondary-container: '#fefcff'
  tertiary: '#05647e'
  on-tertiary: '#ffffff'
  tertiary-container: '#317d98'
  on-tertiary-container: '#fafdff'
  error: '#ba1a1a'
  on-error: '#ffffff'
  error-container: '#ffdad6'
  on-error-container: '#93000a'
  primary-fixed: '#d5e3ff'
  primary-fixed-dim: '#a7c8ff'
  on-primary-fixed: '#001c3b'
  on-primary-fixed-variant: '#004787'
  secondary-fixed: '#d9e2ff'
  secondary-fixed-dim: '#afc6ff'
  on-secondary-fixed: '#001a43'
  on-secondary-fixed-variant: '#004398'
  tertiary-fixed: '#baeaff'
  tertiary-fixed-dim: '#89d0ed'
  on-tertiary-fixed: '#001f29'
  on-tertiary-fixed-variant: '#004d62'
  background: '#f8f9ff'
  on-background: '#001c39'
  surface-variant: '#d4e3ff'
typography:
  display-hero:
    fontFamily: Manrope
    fontSize: 84px
    fontWeight: '200'
    lineHeight: 92px
    letterSpacing: -0.03em
  display-hero-mobile:
    fontFamily: Manrope
    fontSize: 64px
    fontWeight: '200'
    lineHeight: 72px
    letterSpacing: -0.03em
  headline-lg:
    fontFamily: Manrope
    fontSize: 36px
    fontWeight: '700'
    lineHeight: 44px
    letterSpacing: -0.02em
  headline-lg-mobile:
    fontFamily: Manrope
    fontSize: 28px
    fontWeight: '700'
    lineHeight: 36px
    letterSpacing: -0.02em
  headline-md:
    fontFamily: Manrope
    fontSize: 22px
    fontWeight: '600'
    lineHeight: 28px
    letterSpacing: -0.01em
  headline-sm:
    fontFamily: Manrope
    fontSize: 18px
    fontWeight: '600'
    lineHeight: 24px
  telemetry-val:
    fontFamily: Manrope
    fontSize: 24px
    fontWeight: '700'
    lineHeight: 28px
    letterSpacing: -0.01em
  body-lg:
    fontFamily: Manrope
    fontSize: 16px
    fontWeight: '400'
    lineHeight: 24px
  body-md:
    fontFamily: Manrope
    fontSize: 14px
    fontWeight: '400'
    lineHeight: 20px
  label-md:
    fontFamily: Manrope
    fontSize: 12px
    fontWeight: '600'
    lineHeight: 16px
    letterSpacing: 0.04em
  label-sm:
    fontFamily: Manrope
    fontSize: 11px
    fontWeight: '500'
    lineHeight: 14px
    letterSpacing: 0.02em
rounded:
  sm: 0.5rem
  DEFAULT: 1rem
  md: 1.5rem
  lg: 2rem
  xl: 3rem
  full: 9999px
spacing:
  gutter: 1rem
  gutter-sm: 0.75rem
  margin: 1.25rem
  margin-sm: 1rem
  margin-lg: 2rem
  space-xs: 0.25rem
  space-sm: 0.5rem
  space-md: 1rem
  space-lg: 1.25rem
  space-xl: 1.75rem
  space-2xl: 2.5rem
---

## Brand & Style

The design system embodies an elevated Nordic-inspired airiness, combining absolute clarity with tranquil environmental immersion. Engineered for an Android-first weather platform, it replaces traditional cluttered weather feeds with spacious, plush surfaces, crystalline hierarchy, and high-legibility telemetry.

The aesthetic philosophy draws on contemporary Scandinavian minimalism and atmospheric glassmorphism:
- **Atmospheric Horizon:** Dynamic, multi-stop sky gradients establish an emotional connection with meteorological conditions without visual clutter.
- **Pure Surfaces:** Crisp, high-contrast white cards float effortlessly over soft, icy-blue atmospheric tints.
- **Precision Telemetry:** Data-dense metrics (humidity, barometric pressure, UV index, dew point) are distilled into legible typography and balanced micro-modules.
- **Cool Cohesion:** Strictly avoids warm orange, yellow, or purple legacy accents in favor of a cohesive, oceanic, and arctic color story.

## Colors

The palette captures shifting sky conditions using pristine cyan, royal azure, and deep arctic navy. 

### Palette Architecture
- **Primary (`#2589F4`):** The signature vibrant azure. Drives primary actions, active states, and focal graph lines.
- **Secondary (`#1769E0`):** Deep cobalt blue. Serves as the anchor tone in gradient headers, emphasis badges, and interactive controls.
- **Tertiary (`#87CEEB`):** Sky-blue highlight. Used for ambient glow fills, subtle track indicators, precipitation bars, and soft accents.
- **Neutral Deep (`#12345A`):** Midnight navy. Replaces pure black to maintain optimal text contrast while staying tonally harmonious with blue backgrounds.
- **Neutral Muted (`#61758B`):** Cool slate. Used for secondary metadata, timestamps, wind direction indicators, and structural framing.

### Background & Surface Hierarchy
- **Canvas Base:** Soft glacial tint (`#EFF8FF` to `#F8FBFF`), giving depth behind floating panels.
- **Floating Containers:** Solid white (`#FFFFFF`) or 88% translucent frosted white with subtle boundaries (`#D7E8F7`).
- **Signature Gradient:** Linear gradient from top-left (`#1769E0`) through center (`#2589F4`) to bottom-right (`#87CEEB`), reserved for dynamic hero cards and condition spotlights.

## Typography

Manrope delivers geometric clarity, open apertures, and numeric symmetry essential for digital telemetry and glanceable mobile layouts.

### Usage Guidance
- **Display Hero (`display-hero` / `display-hero-mobile`):** Dedicated exclusively to the primary current temperature read-out. Set at a slender `font-weight: 200` to prevent visual heaviness.
- **Telemetry Figures (`telemetry-val`):** Applied to wind speed, precipitation probability, humidity percentages, and visibility indices. High weight (`700`) ensures quick legibility.
- **Labels (`label-md` / `label-sm`):** Rendered in uppercase or stylized title case with tracking (`+0.02em` to `+0.04em`) for category anchors like "WIND DIRECTION", "AIR QUALITY", and "SUNSET".

## Layout & Spacing

The layout utilizes a fluid 4-column system on mobile devices and an 8-column layout on foldables and tablets.

### Layout Rules
- **Canvas Margins:** Mobile viewports use `margin` (`1.25rem` / `20px`) for edge-to-edge breathing room. Compact viewports drop to `margin-sm` (`1rem` / `16px`).
- **Telemetry Grid:** Sub-metrics (UV, Wind, Humidity, Pressure) sit in 2x2 modular card arrangements separated by `gutter-sm` (`0.75rem` / `12px`).
- **Vertical Rhythm:** Main page sections (Hero, Hourly Forecast, 10-Day Horizon, Radar Snippet) separate along an explicit `space-xl` (`1.75rem` / `28px`) vertical stack.

## Elevation & Depth

Visual hierarchy is communicated through luminous layering rather than heavy drop shadows, matching Nordic clarity.

### Depth Styles
- **Level 0 (Atmosphere):** Base canvas background washed with `#EFF8FF` or subtle dynamic vertical mesh.
- **Level 1 (Sub-Containers):** Pure white `#FFFFFF` cards resting with ambient sky-diffused elevation: `box-shadow: 0 8px 24px -4px rgba(37, 137, 244, 0.08), 0 2px 6px -1px rgba(18, 52, 90, 0.04)`. Outlined with a hairline border (`1px solid #D7E8F7`).
- **Level 2 (Active & Hero Elements):** Floating interactive elements, active hour capsules, and sheet overlays: `box-shadow: 0 16px 36px -6px rgba(23, 105, 224, 0.16), 0 4px 12px -2px rgba(18, 52, 90, 0.06)`.
- **Frosted Elements:** Navigation pills and sticky headers utilize backdrop glassmorphism: `background: rgba(255, 255, 255, 0.78); backdrop-filter: blur(16px); border: 1px solid rgba(215, 232, 247, 0.6)`.

## Shapes

The interface embraces a plush, continuous squircle aesthetic (`roundedness: 3`). 

### Geometry Applications
- **Hero Condition Canvas:** Curvature of `28px` to `32px` (`rounded-lg` to `rounded-xl`), creating an inviting, organic display.
- **Telemetry & Information Cards:** Radii standardized between `18px` and `22px` for comfortable scanning.
- **Capsules & Interactive Tags:** Full pill rounding (`9999px`) for search bars, location selectors, hourly chips, and CTA buttons.

## Components

### Hero Card
The centerpiece of the weather view. Features the triple-stop blue gradient (`#1769E0` → `#2589F4` → `#87CEEB`), with text rendered in pure white and subtle ice-white (`rgba(255, 255, 255, 0.8)`). Houses the ultra-light display temperature, weather condition description, high/low range, and an illuminated condition visual. Corner radius: `30px`.

### Telemetry Cards
Compact squircle containers (`20px` radius) structured with a white surface, fine border (`#D7E8F7`), and soft blue shadow. Top line displays an icon paired with an uppercase muted title (`#61758B`). Center displays the metric in bold navy (`#12345A`), while the bottom hosts concise contextual feedback (e.g., "Normal for this hour").

### Hourly Forecast Strip
Horizontal scroll track featuring elongated rounded capsules (`rounded-lg`). The active/current hour adopts a primary blue gradient fill (`#2589F4` to `#1769E0`) with white text and a diffuse blue glow; inactive hours feature a crisp white surface with navy temperature labels and secondary slate time stamps.

### Buttons & Navigation Chips
- **Primary Buttons:** Gradient-filled (`#1769E0` to `#2589F4`), pill-shaped, with high-contrast white text and subtle blue outer glow.
- **Chips & Filter Pills:** Pill-shaped, composed of soft ice-blue fill (`#EFF8FF`) and hairline borders (`#D7E8F7`). Hover/active states transition to primary blue text with sky-blue outlines.

### Form Inputs & Search
Floating search bar with `rounded-pill` geometry, frosted white surface (`rgba(255, 255, 255, 0.9)`), slate placeholder text (`#61758B`), and an azure location pinpoint icon (`#2589F4`). Focused state introduces an azure ring (`#2589F4`) with a soft atmospheric blur.