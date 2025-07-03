# Phase 0 & 1 Documentation: Project Setup and Foundation

## 1. Project Initialization

-   **Project Name:** Aether
-   **Framework:** React Native with Expo
-   **Purpose:** A notes application.

## 2. Core Dependencies Installation

-   **React Navigation:**
    -   `@react-navigation/native`
    -   `@react-navigation/stack`
    -   `@react-navigation/bottom-tabs`
    -   `react-native-screens`
    -   `react-native-safe-area-context`

-   **State Management:**
    -   `zustand`

-   **Styling (Initial Attempt):**
    -   `nativewind`
    -   `tailwindcss`
    -   `postcss`

## 3. Core Folder Structure

-   `app/`: Contains the main application screens and navigation logic.
-   `components/`: Reusable UI components.
-   `state/`: Zustand stores for application state management.
-   `assets/`: Static assets like images and fonts.
-   `utils/`: Utility functions and helpers.
-   `hooks/`: Custom React hooks.

## 4. Initial Configuration Files

-   `babel.config.js`: Babel configuration for transpilation.
-   `metro.config.js`: Metro bundler configuration, including NativeWind setup.
-   `tailwind.config.js`: Tailwind CSS configuration.
-   `postcss.config.js`: PostCSS configuration for Tailwind CSS processing.

## 5. Initial Setup Accomplishments

-   Successfully created the Expo project.
-   Installed all primary dependencies for navigation, state management, and styling.
-   Established a clear and modular folder structure.
-   Configured Babel, Metro, Tailwind CSS, and PostCSS for development.

## 6. Challenges Encountered (Phase 0 & 1)

-   **Blank White Screen on Web:** Initially, the application displayed a blank white screen when run on the web. This was resolved by:
    -   Updating `package.json` to remove unnecessary polyfills.
    -   Aligning `react` and `react-dom` versions.
    -   Ensuring correct import paths.

-   **Persistent `tailwindConfigV3` Error with NativeWind:** This error has been a significant blocker, preventing proper styling. Extensive troubleshooting has been performed, including:
    -   Updating and downgrading `nativewind`.
    -   Modifying `metro.config.js` (removing/adding `tailwindConfig` option).
    -   Reinstalling `tailwindcss` and `postcss`.
    -   Clearing npm cache (`npm cache clean --force`).
    -   Creating `postcss.config.js`.
    -   Creating a new minimal Expo project (`AetherNewMinimal`) to isolate the issue.

Despite these efforts, the `tailwindConfigV3` error persists, and is currently the main focus of debugging.