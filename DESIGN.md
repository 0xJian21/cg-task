---
name: URL Shortener
description: Precise, public URL shortening with click analytics
colors:
  signal-blue: "#4f46e5"
  signal-blue-hover: "#4338ca"
  surface-white: "#ffffff"
  surface-subtle: "#f9fafb"
  border-default: "#e5e7eb"
  border-divider: "#f3f4f6"
  text-primary: "#111827"
  text-secondary: "#374151"
  text-label: "#4b5563"
  text-muted: "#6b7280"
  error: "#dc2626"
typography:
  display:
    fontFamily: "system-ui, -apple-system, BlinkMacSystemFont, 'Segoe UI', sans-serif"
    fontSize: "1.5rem"
    fontWeight: 700
    lineHeight: 1.2
  headline:
    fontFamily: "system-ui, -apple-system, BlinkMacSystemFont, 'Segoe UI', sans-serif"
    fontSize: "1.125rem"
    fontWeight: 600
    lineHeight: 1.3
  body:
    fontFamily: "system-ui, -apple-system, BlinkMacSystemFont, 'Segoe UI', sans-serif"
    fontSize: "0.875rem"
    fontWeight: 400
    lineHeight: 1.5
  label:
    fontFamily: "system-ui, -apple-system, BlinkMacSystemFont, 'Segoe UI', sans-serif"
    fontSize: "0.75rem"
    fontWeight: 500
    lineHeight: 1
    letterSpacing: "0.05em"
  mono:
    fontFamily: "ui-monospace, 'Cascadia Code', 'Source Code Pro', Menlo, monospace"
    fontSize: "0.875rem"
    fontWeight: 400
    lineHeight: 1.5
rounded:
  sm: "6px"
  md: "8px"
spacing:
  sm: "8px"
  md: "16px"
  lg: "24px"
  xl: "32px"
components:
  button-primary:
    backgroundColor: "{colors.signal-blue}"
    textColor: "{colors.surface-white}"
    rounded: "{rounded.sm}"
    padding: "8px 16px"
  button-primary-hover:
    backgroundColor: "{colors.signal-blue-hover}"
    textColor: "{colors.surface-white}"
    rounded: "{rounded.sm}"
    padding: "8px 16px"
  input-text:
    backgroundColor: "{colors.surface-white}"
    textColor: "{colors.text-primary}"
    rounded: "{rounded.sm}"
    padding: "8px 12px"
  card:
    backgroundColor: "{colors.surface-white}"
    rounded: "{rounded.md}"
    padding: "24px"
---

# Design System: URL Shortener

## 1. Overview

**Creative North Star: "The Clean Ledger"**

This is a precision instrument. Every screen exists to complete one job and move the user on. The aesthetic draws from data-focused products like CoinGecko — white surfaces, subtle gray structure, one restrained accent color used only where action is required. Nothing competes for attention. The page title tells you what the screen is; the content confirms it.

The system is light-mode only, built for use at any hour in any context. Contrast is always sufficient; interactive elements are always distinguishable. Data — slugs, URLs, click counts, geolocations — is presented in monospace or tight tabular layouts so it reads as factual, not styled.

What this system explicitly rejects: crypto-neon aesthetics (neon on black, gradient text, glassmorphism as decoration), generic SaaS-blue hero metrics, side-stripe accents on cards, and any decoration that doesn't carry meaning.

**Key Characteristics:**
- White-surface, gray-structure layout — depth through borders, not shadows
- Single accent color used only on interactive elements (links, buttons, focus states)
- Monospace for all user-generated or system-generated strings (slugs, URLs, IPs)
- Labels in uppercase tracking — the only typographic texture permitted
- Tables as the primary data container; cards only for structured key-value summaries

## 2. Colors: The Signal Palette

One accent, used sparingly. The rest is a tight gray scale.

### Primary
- **Signal Blue** (#4f46e5): The sole interactive color. Used on primary buttons, text links, and input focus states. Its rarity is load-bearing — if it appears, the user can click it.
- **Signal Blue Hover** (#4338ca): Darker shift on hover and active states. No other treatment needed.

### Neutral
- **Surface White** (#ffffff): All card and content backgrounds. Not softened — contrast is structural here.
- **Surface Subtle** (#f9fafb): Page background and table header rows. One step off white; creates a platform for white cards without using shadow.
- **Border Default** (#e5e7eb): Card borders, table outer borders, nav bottom border. The structural grid of the UI.
- **Border Divider** (#f3f4f6): Table row dividers only. Lighter than Border Default; a rhythm marker, not a separator.
- **Text Primary** (#111827): Page headings and high-importance labels. Near-black.
- **Text Secondary** (#374151): Table cell data. Readable without competing with headings.
- **Text Label** (#4b5563): Table header text. Distinguishes metadata from data.
- **Text Muted** (#6b7280): Empty states, supporting copy, secondary context.

### Named Rules
**The One Signal Rule.** Signal Blue (#4f46e5) appears only on interactive elements — buttons, links, focus rings. Never as a background tint, decorative stripe, or emphasis color on static text. Its scarcity is what makes it trustworthy.

**The No-Tint Rule.** Cards and content areas use Surface White (#ffffff). Do not add a blue or gray tint to card backgrounds. The structure comes from Border Default, not from surface color.

## 3. Typography

**Body Font:** system-ui stack (system-ui, -apple-system, BlinkMacSystemFont, 'Segoe UI', sans-serif)
**Mono Font:** ui-monospace stack (ui-monospace, 'Cascadia Code', 'Source Code Pro', Menlo, monospace)

**Character:** System sans renders at native quality on every device and matches the no-ceremony tone exactly. Monospace is used for all data strings — the contrast between proportional UI text and monospaced data strings creates a clear visual separation between chrome and content.

### Hierarchy
- **Display** (700, 1.5rem, lh 1.2): Page-level headings only. One per page. "Shorten a URL", "Stats: abc123", "Global Report".
- **Headline** (600, 1.125rem, lh 1.3): Section headings within a page ("Top Links", "Top Countries").
- **Body** (400, 0.875rem, lh 1.5): All running text, table cell data, form helper text. Max line length 65ch.
- **Label** (500, 0.75rem, lh 1, tracking 0.05em, uppercase): Key-value field labels inside cards ("SHORT URL", "TARGET URL", "PAGE TITLE"). The only uppercase treatment in the system.
- **Mono** (400, 0.875rem, lh 1.5): Slugs, full URLs, IP addresses, timestamps. Never styled beyond font-family change.

### Named Rules
**The Mono-for-Data Rule.** Any string that the system generated or the user submitted — slugs, target URLs, IP addresses, timestamps — renders in the mono stack. UI labels and copy render in system sans. The switch is semantic, not decorative.

## 4. Elevation

This system is flat by default. Depth is expressed through border color and background contrast, not shadow blur. The one shadow in use — `shadow-sm` (`0 1px 2px 0 rgba(0,0,0,0.05)`) — appears only on cards and table containers. It is ambient and structural, not decorative.

### Shadow Vocabulary
- **Ambient Low** (`box-shadow: 0 1px 2px 0 rgba(0, 0, 0, 0.05)`): Applied to white card surfaces and table wrappers sitting on Surface Subtle (#f9fafb). Lifts the surface just enough to distinguish it without drama.

### Named Rules
**The Flat-By-Default Rule.** No element receives a shadow unless it is a white card or table container sitting on a gray background. Buttons, nav, inputs, and text are always flat.

## 5. Components

### Buttons
Clean fills, no border-radius variety. The button communicates action through color, not shape embellishment.

- **Shape:** Gently rounded corners (6px radius)
- **Primary:** Signal Blue fill (#4f46e5), white text, 8px/16px padding, 0.875rem semibold
- **Hover / Focus:** Darkens to Signal Blue Hover (#4338ca). No transform, no glow. Focus ring: 2px Signal Blue offset 2px.
- **No secondary or ghost variant** in the current UI. If needed, use a text link styled with Signal Blue.

### Inputs / Fields
- **Style:** White background, Border Default stroke (1px #e5e7eb), 6px radius, 8px/12px padding
- **Focus:** Border shifts to Signal Blue (#4f46e5), 1px ring in Signal Blue at 30% opacity
- **Error:** Border and ring in Error Red (#dc2626), error message in Error Red below the field at 0.875rem
- **Placeholder:** Text Muted (#6b7280)

### Cards / Containers
Used only for structured key-value summaries (link details after creation). Not used as a repeating grid pattern.

- **Corner Style:** Gently rounded (8px radius)
- **Background:** Surface White (#ffffff)
- **Shadow:** Ambient Low — one layer only
- **Border:** Border Default (1px #e5e7eb)
- **Internal Padding:** 24px on all sides. Key-value rows separated by 12px vertical space.

### Tables
The primary data container. Tables carry most of the information in this product.

- **Outer wrapper:** rounded-lg (8px), Border Default border, Ambient Low shadow
- **Header row:** Surface Subtle (#f9fafb) background, Text Label (#4b5563), uppercase + tracking (Label style)
- **Body rows:** Surface White (#ffffff) background, divided by Border Divider (#f3f4f6)
- **Hover state:** Row background shifts to Surface Subtle (#f9fafb)
- **Cell padding:** 16px horizontal, 12px vertical
- **Numeric / right-aligned columns:** text-right alignment, same Text Secondary color

### Navigation
Minimal top bar. Doesn't call attention to itself.

- **Background:** Surface White (#ffffff), 1px Border Default bottom border
- **Links:** Signal Blue (#4f46e5), 0.875rem medium weight, 24px gap between items
- **No hover background.** Link text darkens to Signal Blue Hover (#4338ca) on hover.
- **No active state indicator.** Navigation is two links; the page heading makes context clear.

### Key-Value Label
The uppercase field label inside cards and result summaries. The only uppercase treatment in the system.

- **Style:** 0.75rem, 500 weight, uppercase, 0.05em letter-spacing, Text Muted (#6b7280)
- **Value below:** 0.875rem regular, Text Primary or monospace depending on content type

## 6. Do's and Don'ts

### Do:
- **Do** use Signal Blue (#4f46e5) exclusively on interactive elements — buttons and text links. Reserve it; its rarity is what makes it trustworthy.
- **Do** use monospace (ui-monospace stack) for every system-generated or user-submitted string: slugs, full URLs, IP addresses, timestamps.
- **Do** render table headers in uppercase with 0.05em letter-spacing (Label style) to visually separate metadata from data.
- **Do** use Border Default (#e5e7eb) as the primary structural element. Card and table depth comes from borders, not shadow blur.
- **Do** keep one heading per page. The display heading names the screen; everything else is content.
- **Do** use Surface Subtle (#f9fafb) as the page background so white cards and tables sit on a distinct plane.

### Don't:
- **Don't** use neon colors, gradient text (`background-clip: text`), or glassmorphism. This system rejects crypto-neon aesthetics entirely.
- **Don't** add a colored side-stripe (border-left > 1px) to cards, alerts, or list items. Use a background tint or a full border instead.
- **Don't** use Signal Blue as a background tint, decorative accent, or emphasis color on static text.
- **Don't** nest cards. White on white with matching borders is indistinguishable and always wrong.
- **Don't** use more than Ambient Low shadow on any element. Deep shadows read as heavy and mismatched with the flat tone.
- **Don't** use uppercase or letter-spacing on anything other than key-value field labels. Once it appears everywhere, it reads as noise.
- **Don't** add decorative empty-state illustrations or hero images. An empty state is a sentence in Text Muted. Nothing more.
