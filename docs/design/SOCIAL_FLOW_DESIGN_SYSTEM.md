# Social Flow AI Design System — Foundation

This document defines the official UI foundation shared by every Flutter feature.
It is presentation-only: components receive values and callbacks, and never access
repositories, APIs, storage, or business controllers.

## Direction

- Modern, premium, clean and professional
- AI-oriented without decorative overload
- Mobile-first, accessible and responsive
- Purple/blue brand identity
- Equivalent hierarchy and readability in light and dark modes

## Tokens

All visual constants live under `lib/core/theme/`.

| Category | Contract |
|---|---|
| Brand and semantic colors | `AppColors` |
| Brand, AI and subtle gradients | `AppGradients` |
| Type scale | `AppTypography` |
| Spacing and screen insets | `AppSpacing` |
| Corners | `AppRadius` |
| Control, icon and content sizes | `AppSizes` |
| Shadows and elevation recipes | `AppShadows` |
| Responsive thresholds | `AppBreakpoints` |
| Motion durations | `AppMotion` |
| Material light and dark themes | `AppTheme` |

Widgets must use semantic `ColorScheme` values whenever the color depends on the
active theme. Brand, status and social-network colors come from `AppColors`.

## Shared primitives

Reusable components live under `lib/shared/widgets/`:

- buttons: primary, secondary, tertiary and icon;
- text, search and password fields;
- cards, social-network cards, metric cards and action tiles;
- avatars, chips, badges and tabs;
- bottom sheets and confirmation dialogs;
- loaders, skeletons, empty/error/success states;
- network images;
- section headers and list tiles;
- switch, checkbox and radio controls;
- the generic application navigation bar primitive.

Feature screens provide display models, labels, state and callbacks. This keeps
the widgets compatible with mock repositories today and API repositories later.

## Screen states

Every data-backed screen defines the relevant subset before implementation:

- initial;
- loading or refreshing;
- content;
- empty;
- error with recovery action;
- success confirmation;
- disabled or permission-required.

## Responsive and accessibility rules

- Interactive controls target at least 48 logical pixels.
- Text may scale and long labels must wrap or truncate intentionally.
- Screen content uses Safe Area and constrained readable widths.
- Compact layouts start below 360 px; medium layouts at 600 px; expanded layouts
  at 840 px.
- Important images, actions, progress and state messages expose semantics.
- Skeleton motion respects the platform's reduced-animation preference.
- Bottom sheets account for keyboard insets and use a safe area.

## Navigation invariant

Top-level destinations remain Home / Create / Calendar / Analytics / Profile.
`AppNavigationBar` is only the visual primitive; route ownership and the exact
five-destination shell remain the responsibility of SFA-003.
