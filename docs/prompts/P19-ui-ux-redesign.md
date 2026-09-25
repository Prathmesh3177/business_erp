# P19 — Production-Grade UI/UX Redesign & Modern Responsive Design System

Release: UI/UX Redesign. Prerequisites: P18.

Copy the entire block below into your coding assistant. Paths are relative to the repository root; this phase must leave documentation updated.

```text
Implement P19: Production-Grade UI/UX Redesign & Modern Responsive Design System for Solar Shop ERP.

Work only on this phase and its necessary prerequisites. First inspect the repository, applicable AGENTS.md, docs/README.md, docs/tracking/project-status.md, work-log.md and known-issues.md. Inspect existing code before editing; preserve user changes. Confirm prerequisites using evidence, not a status label alone. If a hard prerequisite is missing, record the blocker and finish independent work; do not fake a dependency.

Follow documented module boundaries, atomic posting, fixed-point arithmetic, permission checks and single-branch-authority policy. Do not alter domain business rules, GST engines, or database schemas unless required for visual state binding.

Implement in reviewable task increments. If the phase cannot fit one session, complete a coherent increment and leave an exact handoff; do not silently omit remaining scope. Run checks appropriate to real behavior and visual responsiveness.

Read these additional design documents under docs/: 01-requirements.md, 08-quality-gates.md, 02-architecture.md.
Prerequisites: P18.

Implementation tasks:
1. Design System & Theme Overhaul:
   - Establish a refined, modern color palette: crisp white and light-neutral background canvases (#F8F9FA / #FFFFFF), cool slate borders/surfaces, and rich dark charcoal text (#1E293B).
   - Use Crimson / Deep Red (#DC2626 / #B91C1C) strictly as an intentional primary accent color (brand highlights, primary call-to-action buttons, active navigation states) to avoid overpowering all-red layouts.
   - Define a future-ready typography and elevation hierarchy with subtle drop shadows, rounded container cards (8px-12px corner radii), clean divider lines, and high-contrast text.

2. Modern Component Architecture & Visual Styling:
   - Modernize buttons: styled primary filled buttons, tonal/outlined secondary buttons, rounded pill badges, and interactive hover/press states.
   - Refine form controls: clean floating labels, clear field borders, contextual inline error messages, explicit focus rings, and input group prefixes (e.g., ₹ symbol, search icons).
   - Elevate data presentation: responsive data tables with sticky headers, soft alternating row hues, status badges (e.g., Approved, Draft, Overdue, Paid), and empty/loading states with visual illustrations or clean vector icons.

3. Responsive Multi-Device Layouts (Desktop, Tablet & Mobile):
   - Widescreen Desktop: Multi-pane layouts with collapsible side navigation rail, sticky filter bars, split detail views for quick inspection, and keyboard shortcut indicators (e.g., POS hotkeys F1-F12).
   - Mobile & Tablet: Seamless responsive adaptation via custom breakpoints, bottom navigation shell, touch-optimized button sizes (minimum 48x48 dp), swipeable tabs, and mobile-friendly bottom sheets for filter/input dialogs.

4. Feature View Overhauls (Dashboard, POS, Inventory, Finance, Projects, Service, Reports):
   - Dashboard: Executive metrics grid with visual trend indicators, elevated KPI cards, and clear low-stock alert highlights.
   - POS & Counter Sale: High-speed counter layout with prominent cart summary, single-click payment tender buttons, touch/barcode search bar, and clean customer info selection.
   - Solar Projects & AMC Service: Modern tabbed workflows, timeline progress bars for project milestones, and structured technician/job ticket summary cards.
   - Settings & Dialogs: Modern modal popups with header close controls, organized tabbed settings, and sleek password/file picker controls.

Expected artifacts: Updated theme tokens (`lib/app/theme.dart`), redesigned feature views (`lib/features/`), updated widget tests, and `docs/design/ui-ux-design-system.md`.
Acceptance checks: `flutter analyze` passes with 0 issues; all existing unit/widget test suites pass 100%; visual layouts adapt smoothly across desktop (1920x1080), laptop (1366x768), and mobile (375x812) viewports without horizontal overflow or clipped content.
Exit gate: Certified production-grade, legitimate enterprise ERP visual appearance and responsive usability.

After the work is done, write the results in docs before ending the session. This is mandatory even if the work is partial or blocked:
1. Update docs/tracking/project-status.md with the actual phase/subtask status and evidence links.
2. Append docs/tracking/work-log.md with date, changes, affected files, schema/API/behavior changes, decisions, checks and exact next step.
3. Append docs/tracking/test-evidence.md with exact commands/procedures, environment, outcomes and artifacts; mark unexecuted checks Not run or Blocked.
4. Update docs/tracking/known-issues.md with remaining defects, missing credentials/hardware/reviews, risks and owners; close resolved items with evidence.
5. Update the relevant requirements, architecture, data model, business rules, security/sync/UX docs and phase-specific documents to match the actual implementation. Add an ADR if a decision changes.
6. Record migration, installation and recovery impacts and update affected runbooks/release notes. Verify documentation links.
Finish with a concise summary of what changed, what passed, what remains blocked and the next prompt/subtask. A phase is Complete only when its acceptance gate is evidenced. Do not begin the next phase automatically.
```
