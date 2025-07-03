# Current Issues

- Blank screen on web build: The application displays a blank white screen when accessed via the web browser, even after:
    - Reorganizing the `app` directory by moving `_layout.tsx` and `index.tsx` into a new `(app)` directory.
    - Configuring `metro.config.js` with polyfills for `buffer`, `stream`, and `crypto`, and setting `nodeModulesPaths`.
    - Adding `expo-router/babel` to `babel.config.js`.
    - Simplifying `app/(app)/index.tsx` to a minimal "Hello World" component.
    - Reinstalling `expo-router` and its dependencies with `--legacy-peer-deps`.
    - Removing duplicate import statements in `app/(app)/_layout.tsx`.
    - Simplifying `app/(app)/_layout.tsx` to a minimal `Stack` component.
    - Simplifying `app/(app)/index.tsx` to a minimal "Hello World" component.
    - Clearing npm cache and reinstalling all dependencies.