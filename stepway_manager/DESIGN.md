---
name: Stepway Manager
colors:
  surface: '#faf8ff'
  surface-dim: '#d2d9f4'
  surface-bright: '#faf8ff'
  surface-container-lowest: '#ffffff'
  surface-container-low: '#f2f3ff'
  surface-container: '#eaedff'
  surface-container-high: '#e2e7ff'
  surface-container-highest: '#dae2fd'
  on-surface: '#131b2e'
  on-surface-variant: '#424754'
  inverse-surface: '#283044'
  inverse-on-surface: '#eef0ff'
  outline: '#727785'
  outline-variant: '#c2c6d6'
  surface-tint: '#005ac2'
  primary: '#0058be'
  on-primary: '#ffffff'
  primary-container: '#2170e4'
  on-primary-container: '#fefcff'
  inverse-primary: '#adc6ff'
  secondary: '#505f76'
  on-secondary: '#ffffff'
  secondary-container: '#d0e1fb'
  on-secondary-container: '#54647a'
  tertiary: '#4f5d70'
  on-tertiary: '#ffffff'
  tertiary-container: '#677689'
  on-tertiary-container: '#fdfcff'
  error: '#ba1a1a'
  on-error: '#ffffff'
  error-container: '#ffdad6'
  on-error-container: '#93000a'
  primary-fixed: '#d8e2ff'
  primary-fixed-dim: '#adc6ff'
  on-primary-fixed: '#001a42'
  on-primary-fixed-variant: '#004395'
  secondary-fixed: '#d3e4fe'
  secondary-fixed-dim: '#b7c8e1'
  on-secondary-fixed: '#0b1c30'
  on-secondary-fixed-variant: '#38485d'
  tertiary-fixed: '#d4e4fa'
  tertiary-fixed-dim: '#b9c8de'
  on-tertiary-fixed: '#0d1c2d'
  on-tertiary-fixed-variant: '#39485a'
  background: '#faf8ff'
  on-background: '#131b2e'
  surface-variant: '#dae2fd'
typography:
  display-lg:
    fontFamily: Manrope
    fontSize: 32px
    fontWeight: '700'
    lineHeight: 40px
    letterSpacing: -0.02em
  headline-md:
    fontFamily: Manrope
    fontSize: 24px
    fontWeight: '700'
    lineHeight: 32px
    letterSpacing: -0.01em
  headline-sm:
    fontFamily: Manrope
    fontSize: 20px
    fontWeight: '600'
    lineHeight: 28px
  body-lg:
    fontFamily: Manrope
    fontSize: 16px
    fontWeight: '500'
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
    letterSpacing: 0.02em
  label-sm:
    fontFamily: Manrope
    fontSize: 11px
    fontWeight: '400'
    lineHeight: 14px
  display-lg-mobile:
    fontFamily: Manrope
    fontSize: 28px
    fontWeight: '700'
    lineHeight: 36px
rounded:
  sm: 0.25rem
  DEFAULT: 0.5rem
  md: 0.75rem
  lg: 1rem
  xl: 1.5rem
  full: 9999px
spacing:
  unit: 8px
  xs: 8px
  sm: 16px
  md: 24px
  lg: 32px
  xl: 40px
  margin-page: 24px
  gutter: 16px
---

## Brand & Style
The design system for this vehicle management application is rooted in **Modern Minimalism**, prioritizing clarity, utility, and a sense of "lightness." The interface is designed for fleet managers and drivers who require high legibility of data and a frictionless task-completion environment. 

The aesthetic leverages a "Polar" palette to create a cool, professional atmosphere. By utilizing significant whitespace and a restricted color palette, the UI emphasizes information hierarchy and operational status over decorative elements. The emotional response should be one of reliability, precision, and calm efficiency.

## Colors
This design system utilizes a high-clarity light mode palette:
- **Primary:** Bright blue is reserved exclusively for high-priority actions, primary buttons, and active states.
- **Surface & Background:** A subtle distinction between the Polar Light Gray background (#F8FAFC) and the Pure White surface (#FFFFFF) provides a clean layered effect without the need for borders.
- **Typography Tiers:** 
  - **Primary (#0F172A):** Used for headlines and critical data points.
  - **Secondary (#64748B):** Used for metadata labels and secondary navigation.
  - **Tertiary (#94A3B8):** Used for deactivated states, hints, and timestamps.
- **Status Colors:** Orange and Red are utilized for priority alerts (e.g., overdue maintenance or fuel levels). Use these sparingly to ensure they retain their psychological urgency.

## Typography
The system uses **Manrope** for its modern, geometric construction and exceptional legibility in data-heavy environments. 

Hierarchy is established primarily through weight transitions:
- **Critical Data:** (Odometer readings, fuel percentages) should use `Bold` or `Semibold` weights in the Primary text color.
- **Labels:** Use `Medium` weight in the Secondary text color to provide context without competing with the data.
- **Supporting Info:** Use `Regular` weight in Tertiary colors for low-priority timestamps or offline indicators.

## Layout & Spacing
The system adheres to a strict **8pt spacing grid**. All dimensions, padding, and margins must be multiples of 8 to ensure a consistent rhythm.

- **Margins:** Standard page horizontal padding is fixed at 24px for both mobile and desktop.
- **Touch Targets:** All interactive elements (buttons, list items, toggles) must maintain a minimum height of 48px to ensure ease of use during transit or in-field operations.
- **Grid:** A 12-column fluid grid is used for desktop, collapsing to a single column for mobile views. Spacing between cards and containers should default to 24px (md).

## Elevation & Depth
Depth is created through the use of **Ambient Shadows** and tonal contrast rather than borders.

- **The "Stepway" Shadow:** Applied to all cards and primary containers. 
  - Color: #0F172A (Gray) at 5% opacity.
  - Blur: 10px.
  - Offset: Y: 4, X: 0.
- **Layering:** Background remains at #F8FAFC. Active surfaces (Cards, Inputs) are #FFFFFF. This 1-tier elevation change is the primary method of separating content modules. Elements do not stack beyond two levels of depth to maintain the minimalist aesthetic.

## Shapes
The shape language is friendly and modern, characterized by exaggerated rounded corners.

- **Primary Radius:** 20px is applied to all cards, modals, and major containers.
- **Button Radius:** Follows the 20px standard to create a soft, approachable "squircle" look.
- **Small Elements:** Tooltips and mini-chips should use a reduced radius of 8px (Soft) to maintain visual proportions.

## Components

### Buttons
- **Primary:** Solid #3B82F6 background, White text, 48px height, 20px border radius.
- **Secondary:** Light blue tint or ghost style with Primary-colored text.
- **State:** On press, apply a 10% black overlay to simulate physical depression.

### Cards
- **Structure:** White background (#FFFFFF), 20px radius, "Stepway" shadow. 
- **Padding:** Internal padding should be 24px (md) to give content room to breathe.
- **No Borders:** Never use hair-line borders for cards; rely entirely on the shadow for definition.

### Input Fields
- **Styling:** 48px height, #F8FAFC background, 20px radius.
- **Active State:** 2px solid border in #3B82F6 when focused.

### Icons & Status Indicators
- **Style:** Line icons with a 2px stroke width, professional and utilitarian.
- **Sync Status:** 
  - *Synced:* Cloud icon with a checkmark in #64748B.
  - *Local/Pending:* Cloud icon in #F97316 (Soft Orange).
- **Vehicle Metrics:** Custom icons for Odometer (speedometer dial), Fuel (pump), and Tools (wrench) should maintain consistent visual weight.

### Chips & Badges
- Used for vehicle status (e.g., "In Transit", "Service Required").
- Backgrounds should be low-opacity versions of the status colors (e.g., 10% Red for alerts) with high-contrast text.