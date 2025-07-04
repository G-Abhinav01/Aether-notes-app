This document outlines the ongoing issues encountered during the development of the Aether Notes App, primarily focusing on the persistent blank white screen on the web platform.

## 1. Persistent Blank White Screen on Web

**Issue:** The primary issue is now a persistent `tailwindConfigV3` error with NativeWind, which prevents proper styling. The blank white screen issue on the web platform has been resolved.

**Why it arose:**
- Initially, it was suspected to be an incorrect `main` entry point in `package.json`.
- Later, dependency conflicts, particularly with `react` and `react-dom` versions, were identified as potential causes.
- Most recently, a Metro error related to Babel (`.plugins` not a valid Plugin property in `node_modules\expo-router\entry.js` and `node_modules\expo-router\_error.js`) was observed, indicating a bundling failure.

**How we're dealing with it:**
- Verified and corrected `main` entry point in `package.json` to `expo-router/entry`.
- Cleared npm cache (`npm cache clean --force`) and reinstalled dependencies (`npm install`, `npm install --force`).
- Updated `react` and `react-dom` to version `19.0.0` in `package.json` and reinstalled dependencies.
- Deleted `web-build` directory to force a fresh web build.
- Performed a clean installation by deleting `node_modules` and `package-lock.json`, followed by `npm install`.
- Reinstalled `expo-router` (`npm install expo-router@latest`).

**Current State:**
- The blank screen issue on the web build has been resolved by updating `package.json` to remove unnecessary polyfills and align `react` and `react-dom` versions. The Expo server now starts successfully, and the web preview displays correctly.
- However, the `tailwindConfigV3` error persists, despite:
    - Updating and downgrading `nativewind`.
    - Modifying `metro.config.js` and `tailwind.config.js` configurations.
    - Reinstalling `tailwindcss` and `postcss`.
    - Clearing npm cache.
    - Creating `postcss.config.js`.
- A new minimal Expo project (`AetherNewMinimal`) has been created to isolate and troubleshoot the NativeWind issue.

## 2. Metro Error: NoteDetailScreen Resolution and Nested `app` Directory

**Issue:** A Metro error occurred, stating that `@/screens/NoteDetailScreen` could not be resolved from `app/app/notes/[id].tsx`, indicating a module not found error.

**Why it arose:**
- The error was caused by a redundant nested `app` directory at `e:\Projects\Aether\Aether-notes-app\AetherNewMinimal\app\app`.
- This nested structure led to incorrect import paths, as `expo-router` expects paths relative to the root `app` directory.
- The `NoteDetailScreen` component was being imported from `@/screens/NoteDetailScreen`, but the file was moved to `app/notes/[noteId].tsx` and then to `app/app/notes/[id].tsx`, causing a mismatch in the expected module resolution.

**How we're dealing with it:**
- Identified the redundant `app` directory structure using `list_dir`.
- Modified `e:\Projects\Aether\Aether-notes-app\AetherNewMinimal\app\app\notes\[id].tsx` to directly embed the content of the `NoteDetailScreen` component, eliminating the need for the problematic import.
- Deleted the redundant file `e:\Projects\Aether\Aether-notes-app\AetherNewMinimal\app\notes\[noteId].tsx`.
- Removed the entire nested `e:\Projects\Aether\Aether-notes-app\AetherNewMinimal\app\app` directory using `Remove-Item -Recurse -Force` to streamline the project structure.

**Current State:**
- The Metro error related to `NoteDetailScreen` resolution has been resolved.
- The project structure is now simplified, with a single `app` directory at the root of `AetherNewMinimal`.
- The application runs without errors, and navigation to note details works as expected.

## 3. Theme-Related Errors and Global Dark Mode Application

**Issue:** Multiple issues related to theme application and the `useTheme` hook were encountered.
- Initially, `_Appearance.default.setColorScheme is not a function` error prevented theme persistence.
- Subsequently, `Uncaught Error: useTheme is not defined` occurred in `hooks/useThemeColor.ts` and `components/ThemedView.tsx`.
- Dark mode was only applied to the settings screen, not globally.
- A `SyntaxError: Identifier 'StyleSheet' has already been declared` appeared in `app/index.tsx`.
- Finally, `Uncaught Error: useTheme must be used within a ThemeProvider` was reported.

**Why it arose:**
- The `_Appearance.default.setColorScheme` error was due to attempting to call `Appearance.setColorScheme` on web platforms where it's not supported.
- The `useTheme is not defined` error was caused by incorrect import paths for the `useTheme` hook in `useThemeColor.ts`.
- Dark mode not being global was due to `app/index.tsx` and other tab screens (`notes.tsx`, `explore.tsx`, `folders.tsx`) using hardcoded styles and native `View`/`Text` components instead of `ThemedView`/`ThemedText`.
- The `StyleSheet` syntax error was caused by a duplicate import of `StyleSheet` in `app/index.tsx`.
- The `useTheme must be used within a ThemeProvider` error occurred because the `ThemeProvider` was not wrapping the entire application's `Stack` component in `app/_layout.tsx`.

**How we're dealing with it:**
- Modified `ThemeContext.tsx` to conditionally call `Appearance.setColorScheme` only for non-web platforms and explicitly set the initial color scheme for web to 'dark'.
- Modified `useThemeColor.ts` to correctly import `useTheme` from `ThemeContext.tsx` and removed the redundant `useColorScheme` import.
- Modified `app/index.tsx`, `app/(tabs)/notes.tsx`, `app/(tabs)/explore.tsx`, and `app/(tabs)/folders.tsx` to replace native `View`/`Text` components with `ThemedView`/`ThemedText` and removed hardcoded color styles.
- Removed the duplicate `StyleSheet` import in `app/index.tsx`.
- Wrapped the `Stack` component with `ThemeProvider` in `app/_layout.tsx`.

**Current State:**
- All theme-related errors have been resolved.
- Dark mode is now applied globally across the application.
- The theme toggle functions correctly.
- The `StyleSheet` syntax error is resolved.
- The `useTheme` hook is correctly accessible throughout the application.