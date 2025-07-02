# 🧭 MASTERPLAN: Aether - Public Development Guide

**Creator:** @G_Abhinav
**Version:** 1.0 (Public)
**Status:** Blueprint for Community

---

## 📌 VISION SUMMARY

Aether is a structured, distraction-free note-taking and task management mobile app that supports folder-based nesting, image attachments, and fast contextual retrieval. It's designed for users who think in branching hierarchies, not flat lists, addressing the gap between overly simplistic apps like Google Keep and overly complex ones like Notion.

## 💡 CORE IDEA & MOTIVATION

The app is born from the need for a tool that can handle structured data like academic notes (Semester → Subject → Chapter), media tracking, and exam preparation without the overhead of enterprise-level software. It solves the pain of flat note structures, lack of contextual recall, and poor digitization of physical materials by offering unlimited folder nesting, robust tagging, and integrated image support.

---

## 🧰 TECH STACK & TOOLS

This stack is chosen for rapid development, scalability, and a mobile-first approach.

| Layer | Tool | Notes |
| --- | --- | --- |
| **Frontend** | React Native (Expo SDK) | For cross-platform development (iOS/Android) from a single codebase. |
| **State Mgmt** | Zustand | A lightweight, simple, and scalable state management solution. |
| **Backend (BaaS)** | **Firebase or Supabase** | A flexible choice between two powerful backend-as-a-service platforms. Firebase offers mature real-time features, while Supabase provides an open-source alternative with a Postgres database. |
| **Image Storage** | Firebase Storage / Supabase Storage | For storing user-uploaded images, linked to specific notes. |
| **Styling** | NativeWind or Tamagui | For a utility-first styling workflow, enabling rapid and consistent UI development. |
| **Authentication** | Firebase Auth / Supabase Auth | To manage user accounts (e.g., Google, Email/Password). |
| **AI Features** | OpenAI API / Gemini API | For future enhancements like note summarization and auto-tagging. |

---

## 🗺️ PHASES & IMPLEMENTATION PLAN

This guide outlines the key phases for building the Aether MVP, providing a high-level overview for developers interested in the project's journey.

### Phase 0: Pre-Build & Foundation

**Goal:** Establish project foundation and architecture.

**Key Activities:**
*   Setting up the GitHub repository and initial branching strategy.
*   Defining the core screen structure and navigation flow.

### Phase 1: UI Scaffolding & Core Navigation

**Goal:** Generate the boilerplate for all screens and components, and implement navigation.

**Key Activities:**
*   Initial project setup and basic UI layout for core screens.
*   Implementing navigation between different sections of the app.

### Phase 2: Local State & Core Logic

**Goal:** Implement local state management and build the core CRUD (Create, Read, Update, Delete) functionality for folders, notes, and tasks.

**Key Activities:**
*   Designing the application's state structure to handle nested data.
*   Developing the logic for creating, reading, updating, and deleting content within the app.
*   Ensuring local data persistence for an offline-first experience.

### Phase 3: Backend Integration

**Goal:** Connect the app to a backend service (Firebase or Supabase) for data synchronization and image storage.

**Key Activities:**
*   Setting up the chosen backend service and defining the database schema.
*   Implementing data synchronization logic to ensure seamless offline and online usage.
*   Integrating image upload capabilities.

### Phase 4: UI Polish & Advanced Features

**Goal:** Refine the user experience with animations, improved UI elements, and search functionality.

**Key Activities:**
*   Implementing dark/light theme toggling.
*   Enhancing the user interface with subtle animations and improved component designs.
*   Developing robust search capabilities for notes and folders.

### Phase 5: AI Enhancements (Optional)

**Goal:** Integrate generative AI features to add value.

**Key Activities:**
*   Adding features like note summarization using external AI APIs.
*   Exploring possibilities for intelligent auto-tagging based on content.

### Phase 6: Finalization & Deployment

**Goal:** Prepare the app for release.

**Key Activities:**
*   Conducting comprehensive testing of all features.
*   Generating production builds for Android and iOS.
*   Finalizing documentation and preparing for app store submission.

---

## ✅ FINAL CHECKLIST

- [ ] `README.md` is finalized with app overview and features.
- [ ] `LICENSE.md` is present.
- [ ] The main branch contains the stable MVP code.
- [ ] Production builds are generated and tested.
- [ ] All core features are implemented and functional.
- [ ] The app has been tested for both online and offline performance.