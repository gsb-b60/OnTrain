# Design Principles - OnTrain

This document outlines the design principles and visual language for the OnTrain project to ensure consistency across all screens and future developments.

## 1. Color Palette (`lib/core/constrants/app_colors.dart`)

The app uses a "Minty/Teal" fresh aesthetic. All UI elements must strictly adhere to the defined `AppColors` and `AppGradients`.

### Primary Colors
- **`AppColors.aquaTeal` (#50C9C3):** The primary brand color. Used for:
    - Primary text highlights.
    - Active icons.
    - Borders of outlined buttons.
    - Text in secondary buttons.
    - Selected states in the calendar.
- **`AppColors.mintLight` (#96DEDA):** A lighter companion to Aqua Teal. Primarily used in gradients and as a softer background for "today" in calendars.

### Neutral Colors
- **`AppColors.light` (White):** Used for main background screens and text on dark/gradient backgrounds.
- **`AppColors.black` (Black):** Used for primary body text.
- **`AppColors.greyAqua` (#E9F6FE):** A very light blue-grey. Used for:
    - Input field backgrounds (filled).
    - Secondary button backgrounds.
    - Small decorative elements.
- **Tailwind Gray Palette (`gray100` to `gray900`):** Used for subtle borders, secondary text (Gray 500/600), and dividers.

### Gradients (`AppGradients`)
- **`AppGradients.brand`:** Horizontal gradient (`aquaTeal` to `mintLight`). Used for major headers and hero sections.
- **`AppGradients.focus`:** Used for **Primary Action Buttons** (e.g., "Log In", "Book Now"). This provides a high-contrast, clickable feel.

---

## 2. Visual Style & UI Patterns

### Consistency is Key
- **Rounded Corners:** The app favors a soft, rounded look.
    - Primary Buttons: `BorderRadius.circular(24)`
    - Input Fields & Smaller Buttons: `BorderRadius.circular(16)`
    - Cards/Containers: `BorderRadius.circular(12)` to `16`.
- **Shadows:** Use shadows sparingly. Favor clean flat designs or subtle elevation.

### Typography (`lib/core/constrants/app_size.dart`)
- **Titles:** Use `AppSizes.large` or `AppSizes.medium`, `FontWeight.bold`, and `AppColors.aquaTeal`.
- **Body Text:** Use `AppSizes.small` or `14px`, `AppColors.black` or `AppColors.gray700`.
- **Hints/Secondary:** Use `AppColors.aquaTeal` (for hints in teal fields) or `AppColors.gray500`.

### Input Fields
- **Style:** Filled, no border.
- **Background:** `AppColors.greyAqua`.
- **Hint Style:** `AppColors.aquaTeal`.
- **Shape:** `BorderRadius.circular(16)` or similar.

### Buttons
- **Primary:** Gradient (`AppGradients.focus`), white bold text, rounded corners (24).
- **Secondary (Filled):** `AppColors.greyAqua` background, `aquaTeal` bold text, rounded corners (24).
- **Secondary (Outlined):** `AppColors.light` background, `aquaTeal` border and text, rounded corners (16).

### Headers
- Headers should either use a solid `AppColors.aquaTeal` background or `AppGradients.brand`.
- Text in headers is typically `AppColors.light` and bold.

---

## 3. Component Guidelines

- **Icons:** Use `Icons.arrow_back_ios` for back buttons to maintain the iOS-like aesthetic found in some screens. Icons related to actions should mostly use `AppColors.aquaTeal`.
- **Avatars:** Use `CircleAvatar`. If a border is needed, use `AppColors.aquaTeal`.
- **Dividers:** Use `Divider` with `thickness: 1` and either default grey or a light teal tint.
- **Calendar:** The `TableCalendar` should be styled with `AppColors.aquaTeal` for the primary markers and `AppColors.mintLight` for today's highlight.

## 4. Design Intent for New Screens
When building a new screen:
1.  **Background:** Start with `AppColors.light`.
2.  **Header:** Use `HeaderBar` or a custom container with teal/gradient background.
3.  **Actions:** Identify the primary action and use a gradient button. Secondary actions use outlined or light-filled buttons.
4.  **Spacing:** Use consistent padding (typically `24.0` or `16.0` for horizontal margins).
5.  **Status Bar:** Ensure icons are readable against the header (typically light icons on teal).
