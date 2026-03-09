---
name: winui-polish
description: Audit and fix WinUI 3 visual polish issues — materials, theming, corner radius, spacing, visual states, typography, and icons. Use when asked to "polish", "visual audit", "dark mode fix", "Mica missing", "corner radius", "visual states", or "theme switch" for a WinUI app.
---

# WinUI Polish

Audit and fix visual polish defects in WinUI 3 desktop applications. This skill focuses on the **audit-and-fix loop** — it complements the `winui-app` skill (which handles app creation, structure, and development) by providing a structured workflow for finding and resolving visual issues.

## Polish Flow

1. **Capture current state.** Delegate to the `ui-polisher` skill's `capture-window.ps1` to screenshot the running app. Capture both light and dark themes.
2. **Run defect audit.** Walk through `references/issue-taxonomy.md` against the captured screenshots and XAML source. Record every defect.
3. **Classify each defect** by category (Materials, Theme, Corner Radius, Spacing, Visual States, Typography, Icons) and severity (Critical, Major, Minor).
4. **Load the matching reference file** for each defect category. See the reference index below.
5. **Apply fix patterns** from the reference. Make the smallest change that resolves the defect.
6. **Rebuild and re-capture.** Build the app, launch it, and take new screenshots in both themes.
7. **Verify fixes and check for regressions.** Compare before/after captures. Confirm no new defects were introduced.
8. **Generate polish report.** Summarize what was found, what was fixed, and what remains.

## Reference Index

| Reference file | Topic |
| --- | --- |
| `references/issue-taxonomy.md` | 7-category defect classification and audit worksheet |
| `references/material-and-backdrop-fixes.md` | Mica, MicaAlt, Acrylic setup and fallback logic |
| `references/theme-verification.md` | Light/Dark/HighContrast switching, system brushes, ThemeResource patterns |
| `references/geometry-and-spacing.md` | Spacing ramp, corner radius resources, type ramp resources |
| `references/visual-states.md` | PointerOver/Pressed/Focused/Disabled states, VisualStateManager patterns |
| `references/iconography-polish.md` | Segoe Fluent Icons, icon sizing ramp, color inheritance |

## Rules

- **Visual-only changes.** Never modify app logic, data flow, or business rules. Only touch XAML, styles, resources, and the minimal C# needed for backdrop/theme setup.
- **Always verify both light and dark themes.** A fix that works in one theme but breaks the other is not a fix.
- **Use ThemeResource over hardcoded colors.** Every color value in XAML should come from a `{ThemeResource ...}` or `{StaticResource ...}` that resolves correctly in all themes.
- **Prefer WinUI system resources over custom values.** Use the platform spacing ramp, corner radius tokens, type ramp styles, and system brushes before inventing custom numbers.
- **Max 3 fix-then-verify iterations.** If defects persist after 3 rounds, stop and report remaining issues with clear descriptions.
- **Canonical theming authority.** For any theming rule ambiguity, defer to `winui-app/references/styling-theming-materials-and-icons.md` as the single source of truth.

## Documentation Sources

### Microsoft Learn (Official)

- [Mica material](https://learn.microsoft.com/en-us/windows/apps/design/style/mica) — design guidance, variants, XAML setup
- [Acrylic material](https://learn.microsoft.com/en-us/windows/apps/design/style/acrylic) — in-app vs background acrylic
- [Materials overview](https://learn.microsoft.com/en-us/windows/apps/design/signature-experiences/materials) — comparison of all Windows materials
- [SystemBackdropController](https://learn.microsoft.com/en-us/windows/apps/windows-app-sdk/system-backdrop-controller) — lower-level controller API
- [Title bar customization](https://learn.microsoft.com/en-us/windows/apps/develop/title-bar) — ExtendContentIntoTitleBar, drag regions
- [XAML theme resources](https://learn.microsoft.com/en-us/windows/apps/develop/platform/xaml/xaml-theme-resources) — brush/color key reference
- [Theming in Windows apps](https://learn.microsoft.com/en-us/windows/apps/develop/ui/theming) — dark/light, accent, RequestedTheme
- [Color](https://learn.microsoft.com/en-us/windows/apps/design/signature-experiences/color) — Fluent Design color guidance
- [Contrast themes](https://learn.microsoft.com/en-us/windows/apps/design/accessibility/high-contrast-themes) — high contrast accessibility
- [Spacing and sizes](https://learn.microsoft.com/en-us/windows/apps/design/style/spacing) — spacing ramp, compact density
- [Typography](https://learn.microsoft.com/en-us/windows/apps/design/signature-experiences/typography) — type ramp, Segoe UI Variable
- [Rounded corners](https://learn.microsoft.com/en-us/windows/apps/design/style/rounded-corner) — CornerRadius design guidance
- [VisualStateManager](https://learn.microsoft.com/en-us/windows/windows-app-sdk/api/winrt/microsoft.ui.xaml.visualstatemanager) — visual state API
- [Control templates](https://learn.microsoft.com/en-us/windows/apps/develop/platform/xaml/xaml-control-templates) — styles and templates
- [Keyboard accessibility / focus visuals](https://learn.microsoft.com/en-us/windows/apps/design/accessibility/keyboard-accessibility)
- [Visual feedback guidelines](https://learn.microsoft.com/en-us/windows/apps/develop/input/guidelines-for-visualfeedback) — hover, press, focus states
- [Segoe Fluent Icons](https://learn.microsoft.com/en-us/windows/apps/design/style/segoe-fluent-icons-font) — glyph table / character map
- [Icons in Windows apps](https://learn.microsoft.com/en-us/windows/apps/develop/ui/controls/icons) — SymbolIcon vs FontIcon guidance
- [FontIcon class](https://learn.microsoft.com/en-us/windows/windows-app-sdk/api/winrt/microsoft.ui.xaml.controls.fonticon) · [SymbolIcon class](https://learn.microsoft.com/en-us/windows/windows-app-sdk/api/winrt/microsoft.ui.xaml.controls.symbolicon)
- [XAML styles](https://learn.microsoft.com/en-us/windows/apps/design/style/xaml-styles) · [ResourceDictionary](https://learn.microsoft.com/en-us/windows/apps/develop/platform/xaml/xaml-resource-dictionary)

### Design Systems & Samples

- [Fluent 2 Design System](https://fluent2.microsoft.design/) — current-gen design system
- [WinUI Gallery source](https://github.com/microsoft/WinUI-Gallery) — definitive WinUI 3 example app
- [WinUI Gallery (Microsoft Store)](https://apps.microsoft.com/detail/9p3jfpwwdzrc) — browse controls interactively
- [WindowsAppSDK-Samples](https://github.com/microsoft/WindowsAppSDK-Samples) — feature-specific samples
- [Windows Community Toolkit](https://github.com/CommunityToolkit/Windows) · [docs](https://learn.microsoft.com/en-us/dotnet/communitytoolkit/windows/)

### Community

- [Nick's .NET Travels — WinUI](https://nicksnettravels.builttoroam.com/tag/winui/) — architecture, patterns
- [Windows Developer Blog — WinUI](https://blogs.windows.com/windowsdeveloper/category/winui/) — official announcements
- [#ifdef Windows — WinUI3](https://devblogs.microsoft.com/ifdef-windows/tag/winui3/) — engineering deep dives
