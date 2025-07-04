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

-   **Metro Error: NoteDetailScreen Resolution and Nested `app` Directory:** A Metro error occurred, stating that `@/screens/NoteDetailScreen` could not be resolved from `app/app/notes/[id].tsx`, indicating a module not found error.
    -   **Cause:** A redundant nested `app` directory and incorrect import paths due to `expo-router`'s expected path resolution relative to the root `app` directory.
    -   **Resolution:**
        -   Identified the redundant `app` directory structure.
        -   Modified `e:\Projects\Aether\Aether-notes-app\AetherNewMinimal\app\app\notes\[id].tsx` to directly embed the content of the `NoteDetailScreen` component, eliminating the problematic import.
        -   Deleted the redundant file `e:\Projects\Aether\Aether-notes-app\AetherNewMinimal\app\notes\[noteId].tsx`.
        -   Removed the entire nested `e:\Projects\Aether\Aether-notes-app\AetherNewMinimal\app\app` directory to streamline the project structure.
    -   **Outcome:** The Metro error related to `NoteDetailScreen` resolution has been resolved. The project structure is now simplified, and the application runs without errors, with navigation to note details working as expected.

---

# 🚀 Migration Notice (v1.1 → v2.0)

## 🛠️ Migration from React Native to Flutter + Dart

As of version 2.0, this project has been migrated from React Native to Flutter + Dart.

This decision was made after careful consideration of the project's long-term maintainability, performance goals, and development roadmap.

## 🔄 Why the Migration?

Several factors contributed to this shift:

-   **Unified Tooling & Ecosystem:** Flutter provides a cohesive environment with first-party tooling (e.g., Flutter CLI, Hot Reload, Dart DevTools), making development more streamlined and consistent.

-   **Performance:** Flutter compiles directly to native ARM code, offering smoother animations and lower latency compared to React Native’s JavaScript bridge architecture.

-   **UI Consistency:** Flutter’s widget-based rendering ensures pixel-perfect UI across both iOS and Android without relying heavily on native components.

-   **Reduced Dependency Overhead:** React Native often depends on third-party libraries for essential functionality, leading to frequent version mismatches and compatibility issues.

-   **Long-Term Maintainability:** Flutter’s active community, robust documentation, and growing adoption across platforms (mobile, web, desktop) offer a more unified and future-proof approach.


## 📁 Project Versioning

v1.1 and earlier: Built with React Native (JavaScript/TypeScript)

v2.0 and beyond: Built with Flutter (Dart)


Older versions are preserved in the repository under the `legacy/react-native` branch for reference and archival purposes.


---

## 💡 Notes for Developers

The new Flutter codebase is structured following best practices including separation of concerns, state management (e.g., Provider, Riverpod, or Bloc depending on your choice), and platform-agnostic UI.

Documentation and contribution guidelines have been updated to reflect Flutter usage.

All core functionality from the React Native version has been re-evaluated and reimplemented to align with Flutter conventions.