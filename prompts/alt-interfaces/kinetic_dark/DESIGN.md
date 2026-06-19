---
name: Kinetic Dark
colors:
  surface: '#121221'
  surface-dim: '#121221'
  surface-bright: '#383848'
  surface-container-lowest: '#0c0d1c'
  surface-container-low: '#1a1a2a'
  surface-container: '#1e1e2e'
  surface-container-high: '#292839'
  surface-container-highest: '#333344'
  on-surface: '#e3e0f6'
  on-surface-variant: '#c7c4d8'
  inverse-surface: '#e3e0f6'
  inverse-on-surface: '#2f2f3f'
  outline: '#918fa1'
  outline-variant: '#464555'
  surface-tint: '#c4c0ff'
  primary: '#c4c0ff'
  on-primary: '#2000a4'
  primary-container: '#8781ff'
  on-primary-container: '#1b0091'
  inverse-primary: '#4f44e2'
  secondary: '#44e7c3'
  on-secondary: '#00382d'
  secondary-container: '#01caa8'
  on-secondary-container: '#004f40'
  tertiary: '#ffb0ca'
  on-tertiary: '#640036'
  tertiary-container: '#f1589a'
  on-tertiary-container: '#58002f'
  error: '#ffb4ab'
  on-error: '#690005'
  error-container: '#93000a'
  on-error-container: '#ffdad6'
  primary-fixed: '#e3dfff'
  primary-fixed-dim: '#c4c0ff'
  on-primary-fixed: '#100069'
  on-primary-fixed-variant: '#3622ca'
  secondary-fixed: '#5efbd6'
  secondary-fixed-dim: '#37debb'
  on-secondary-fixed: '#002019'
  on-secondary-fixed-variant: '#005142'
  tertiary-fixed: '#ffd9e3'
  tertiary-fixed-dim: '#ffb0ca'
  on-tertiary-fixed: '#3e001f'
  on-tertiary-fixed-variant: '#8d004e'
  background: '#121221'
  on-background: '#e3e0f6'
  surface-variant: '#333344'
typography:
  display-lg:
    fontFamily: Inter
    fontSize: 48px
    fontWeight: '800'
    lineHeight: 56px
    letterSpacing: -0.02em
  headline-lg:
    fontFamily: Inter
    fontSize: 32px
    fontWeight: '700'
    lineHeight: 40px
    letterSpacing: -0.01em
  headline-lg-mobile:
    fontFamily: Inter
    fontSize: 24px
    fontWeight: '700'
    lineHeight: 32px
  title-md:
    fontFamily: Inter
    fontSize: 18px
    fontWeight: '600'
    lineHeight: 24px
  body-md:
    fontFamily: Inter
    fontSize: 16px
    fontWeight: '400'
    lineHeight: 24px
  label-md:
    fontFamily: Inter
    fontSize: 14px
    fontWeight: '500'
    lineHeight: 20px
  caption:
    fontFamily: Inter
    fontSize: 12px
    fontWeight: '400'
    lineHeight: 16px
rounded:
  sm: 0.25rem
  DEFAULT: 0.5rem
  md: 0.75rem
  lg: 1rem
  xl: 1.5rem
  full: 9999px
spacing:
  base: 4px
  xs: 8px
  sm: 12px
  md: 16px
  lg: 24px
  xl: 32px
  container-margin: 20px
  gutter: 16px
---

## Brand & Style

The design system is engineered for high-performance fitness tracking, targeting users who value precision, motivation, and clarity during intense workouts. The brand personality is disciplined yet energetic, utilizing a deep-space backdrop to make performance metrics "pop" with neon-inspired clarity.

The style is **Modern / Minimalist** with a focus on flat surfaces and high-contrast accents. It borrows the structural hierarchy of Material 3 but applies the sleek, centered aesthetic of iOS. Visual noise is eliminated to ensure that during physical activity, the user can consume data at a glance. Interaction states are snappy and immediate, reinforcing a sense of momentum and progress.

## Colors

The palette is anchored in a deep-sea obsidian (`#13131F`) to reduce eye strain in low-light gym environments. 

- **Primary (Electric Indigo):** Used for primary actions, active navigation states, and brand-heavy moments.
- **Highlight (Aquamarine):** Reserved for success states, "In" metrics (hydration/macros), and positive progress.
- **Accent (Punch Pink):** Specifically for "Out" metrics like calorie burn, heart rate intensity, or urgent alerts.
- **Surface:** A slightly lifted grey-blue (`#252535`) provides clear containment for cards and modular content without the need for heavy shadows.

## Typography

This design system utilizes **Inter** for its exceptional readability and neutral, modern character. 

- **Headlines:** Use Bold (700) or ExtraBold (800) for numerical data and main headers to create a strong visual anchor.
- **Body:** Regular (400) weight is used for descriptions. 
- **Secondary Text:** Use the muted text token (`#8E8E9F`) for labels and descriptions to maintain hierarchy.
- **Casing:** All labels, buttons, and headers must use **Sentence case** to feel approachable and modern, avoiding the aggression of all-caps.

## Layout & Spacing

The system follows a **12-column fluid grid** for tablet and desktop, and a **4-column fluid grid** for mobile. 

- **Margins:** A consistent 20px side margin is maintained on mobile to provide breathing room.
- **Rhythm:** An 8px linear scaling system is used for component spacing, while 4px is used for internal micro-adjustments (e.g., icon to text).
- **Density:** Components are generously padded to ensure ease of touch during movement. Vertical stack spacing between cards is fixed at 16px.

## Elevation & Depth

This design system avoids traditional drop shadows in favor of **Tonal Elevation**. 

- **Level 0 (Background):** `#13131F`.
- **Level 1 (Cards/Surfaces):** `#252535`.
- **Dividers:** 1px solid borders using a low-opacity white (10%) or a slightly lighter shade than the surface.
- **Interaction:** High-tensity areas use the Primary Accent color with 0% shadow, relying on the color shift to indicate "lift."

## Shapes

The shape language is defined by a consistent **16px (1rem) corner radius** for all major containers.

- **Cards and Buttons:** Fixed at 16px to create a soft, modern feel that contrasts with the technical dark theme.
- **Stat Badges:** Use a fully rounded "Pill" shape (height / 2) to distinguish them from actionable buttons.
- **Search Bars:** Utilize 16px rounded corners to match the card aesthetic, rather than the fully rounded pill, to maintain structural alignment.

## Components

- **Bottom Navigation Bar:** Features 4 iconic slots (Today, Food, Activity, Gym). Active states use the Primary Accent color for the icon and a subtle 4px dot indicator underneath. Blurred background (backdrop-filter) is permitted for a premium iOS-style feel.
- **Pill-shaped Stat Badges:** Compact, high-contrast badges for "High Protein," "Goal Reached," etc. Backgrounds should be a 15% opacity version of the text color (Teal or Pink).
- **Circular Progress Indicators:** Use a 10px stroke width. The background track is `#252535`, while the active progress uses the Highlight (Teal) or Accent (Pink) with rounded line caps.
- **Search Bars:** Inset within a `#252535` container with a 16px radius. Placeholder text is muted.
- **Floating Action Buttons (FAB):** Strictly circular, using the Primary Accent (`#6C63FF`) with a white icon. Positioned at the bottom right with a 24px offset.
- **Modal Bottom Sheets:** 24px top-corner radius. Includes a "grabber" handle (32x4px, muted color) at the top center.
- **Cards:** No borders, no shadows. Background is strictly `#252535`. Inner padding is fixed at 20px.