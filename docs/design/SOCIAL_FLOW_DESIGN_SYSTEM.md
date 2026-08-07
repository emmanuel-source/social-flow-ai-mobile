# Social Flow AI Design System — Foundation

This document defines the design-system responsibilities, not final pixel values.

## Direction
- Modern
- Premium
- Clean
- AI-oriented
- Mobile-first
- Established purple/blue visual identity

## Token categories
Maintain tokens in `lib/core/theme/` for:
- semantic colors
- gradients
- typography
- spacing
- radius
- shadows/elevation
- breakpoints
- motion durations when introduced

## Shared primitives
Prefer reusable components under `lib/shared/widgets/` for:
- primary/secondary/tertiary buttons
- text fields/search fields
- cards
- social-network chips/selectors
- media tiles
- dialogs
- bottom sheets
- loaders/skeletons
- empty/error states
- navigation primitives

## Screen states
Every data-backed screen should define its relevant states before implementation:
- initial
- loading
- content
- empty
- error
- refreshing
- disabled/permission-required when applicable

## Navigation invariant
Top-level destinations stay:
Home / Create / Calendar / Analytics / Profile.
