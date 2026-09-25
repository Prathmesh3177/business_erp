# UI/UX design system

Status: P19 implementation increment, 2026-09-25. This specification describes the implemented Flutter presentation layer; it does not change domain or posting behavior.

## Tokens

| Token | Value | Use |
|---|---:|---|
| Canvas | `#F8F9FA` | Application background |
| Surface | `#FFFFFF` | Cards, dialogs and fields |
| Slate border | `#E2E8F0` / `#CBD5E1` | Dividers and enabled field borders |
| Text | `#1E293B` | High-contrast primary text |
| Primary | `#DC2626` | Primary actions, focus and selected navigation only |
| Primary pressed | `#B91C1C` | Intentional strong primary emphasis |
| Success / warning / information | `#15803D` / `#B45309` / `#0369A1` | Status only; never the sole state signal |

Cards have a 12dp radius and a subtle slate outline. Controls use a 10dp radius and a minimum 48dp target. Fields have floating labels, a crimson 2dp focus ring, inline error styling and support prefix icons such as search and INR.

## Reusable presentation primitives

`lib/app/theme.dart` owns tokens and Material component themes. `lib/features/common/erp_ui.dart` owns only presentation primitives:

- `ErpBreakpoints`: compact `<600`, tablet `<840`, desktop `>=1200` logical pixels.
- `ErpSectionCard`, `ErpStatusBadge`, and `ErpEmptyState` for consistent containers and state communication.
- `ErpResponsiveTable` for horizontally scrollable, sticky-compatible Material tables on compact devices.

These widgets must not import domain/data packages or perform authorization, calculation, or posting. Feature widgets continue to invoke the existing authorized use cases.

## Responsive rules implemented in this increment

- Dashboard uses two KPI columns on compact devices and four on desktop; compact cards reserve enough height for labels and values.
- The Foundation ready screen keeps its centered launcher when it fits and becomes vertically scrollable when its action grid exceeds the available height.
- POS retains its high-density split catalog/cart layout at tablet-and-up widths. Under 840dp it switches to a touch-sized, vertically ordered search, customer, product, cart and payment workflow.
- Reports filter controls wrap rather than overflow and report tables scroll horizontally inside a card. Primary workflow tabs are scrollable.
- Dashboard, POS, inventory, projects, service, and reports inherit the neutral app bar, primary action, form, dialog and table styling.

## Verification and remaining work

Widget tests exercise dashboard layout at 1920×1080, 1366×768, and 375×812, and assert no rendering exception. This is automated layout evidence, not a substitute for manual assistive-technology, 200% text-scale, desktop navigation-rail, or physical-device review. P19 remains in progress until those checks and the remaining feature-view refactors are completed.
