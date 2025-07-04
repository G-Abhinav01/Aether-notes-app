# Aether-notes-app
Branch-structured mobile notes + task manager (React Native)



> ⚠️ **Notice**: This project is a private product-in-development.  
> While the repository is public for review, all rights are reserved. Do not copy, reuse, or redistribute any part of this codebase.


# 🌿 Aether — A Branch-Structured Mobile Notes + Task App

> **Smart, structured, minimal.**  
> Aether is a mobile-first, folder-driven note and task manager — built for people who think in **branches**, not just lists.

---

## 📌 Overview

Aether is a **lightweight, mobile-first productivity app** designed for users who prefer to organize thoughts, media, and plans in a **folder-based, nested format** — unlike flat apps like Google Keep or overly complex tools like Notion.

It supports:
- **Folders and subfolders** for hierarchical organization
- **Notes**, **tasks**, and **images** inside any folder
- **Tags**, **dark mode**, and **offline-first experience**
- A calm, minimal interface with **future AI extensions**

---

## 🧠 Why Aether?

Most mainstream tools are either:
- **Too simple** (Google Keep: flat, unstructured),
- Or **too heavy** (Notion: bloated for basic use).

For users like me who track things like:
- `Anime → Title → Notes`
- `6th Sem → Subject → Chapter → Exam Tasks`
- `Ideas → Genre → Prompts`

...none of these apps offer **deep structuring**, **quick recall**, or **contextual nesting**.

**Aether is the missing middle-ground.**

---

## 🌲 Core Features (MVP)

| Feature         | Description |
|----------------|-------------|
| 📁 Folders      | Create unlimited folders & subfolders (e.g., `Semester → Subject → Chapter`) |
| 📝 Notes        | Title + body with tags and timestamps |
| ✅ Tasks        | Checklist items inside any folder |
| 🏷️ Tags         | Add searchable tags for fast lookup |
| 📸 Image Upload | Scan and store handwritten notes under folders |
| 🌙 Dark Mode    | UI theming (light/dark toggle) |
| 🔍 Search       | Global + folder-specific keyword/tag search |
| 📴 Offline First| Works without internet, syncs later |
| ☁️ Sync         | Firebase Firestore for real-time cloud sync |

---

## 🌠 Future Features

| Feature         | Description |
|----------------|-------------|
| ✨ AI Summarizer| Auto TL;DR for long notes using LLMs |
| 🧠 Auto-tagging | Suggest tags based on note content |
| 🔎 Semantic Search | Understand context, not just keywords |
| 📤 Export       | Markdown or JSON export of notes/folders |

---

## 💻 Tech Stack

| Layer              | Choice                            |
|-------------------|------------------------------------|
| **Framework**      | React Native (Expo)               |
| **State Management** | Zustand or React Context        |
| **Database**       | Firebase Firestore                |
| **Storage**        | Firebase Storage (for images)     |
| **Styling**        | NativeWind / Tailwind / Tamagui   |
| **Image Picker**   | Expo Image Picker                 |
| **AI (Future)**    | OpenAI or Gemini APIs             |

---

## 📱 Ideal Use Cases

- 🧑‍🎓 Students: `Semester → Subject → Chapter → Notes`
- 🎨 Writers: `Genre → Prompt Type → Drafts`
- 🎥 Media Watchlists: `Anime → Title → Notes/Status`
- 📚 Exam Prep: Scanned notes stored by topic or subject

---

## ✏️ Design Philosophy

- **Clean & Calm**: Minimal UI that doesn't overwhelm
- **Deeply Structured**: Branching folders, not flat lists
- **Offline Native**: Local-first, syncs when online
- **Theme-Friendly**: Dark/light toggle included

---

## 📦 Repository Status

This repo is under **active development**  
Progress is tracked via `day-x` branches (e.g., `day-1`, `day-2`, ...)  
Current status: UI Scaffolding → State Logic Integration → Firebase Sync

---

## 🚫 Licensing Notice

> ⚠️ **This is a private product-in-development.**  
> While the repository is public for demonstration purposes, all rights are reserved.

- 📜 **License**: All Rights Reserved  
- ❌ No reuse, redistribution, or commercial use allowed  
- 📩 Contact author for permission: [@Abhinav on GitHub](https://github.com/G-Abhinav01)

---

## 🔗 Live Preview

> Coming soon via Expo Go preview link.  
> You'll be able to scan a QR and try the mobile app live.

---

## 👨‍💻 Author

Built by **G Abhinav**  
Devlog & Showcase: [LinkedIn](https://www.linkedin.com/in/g-abhinav-138a39252/) · [GitHub](https://github.com/G-Abhinav01)

---

## 🛠️ Build With

> Initial scaffold powered by [VS Code](https://code.visualstudio.com/)   
> Manual logic, UI design, and integrations crafted from scratch

---







---

## 🔒 License & Usage Notice

This project is shared for demonstration and portfolio review purposes only.

All rights reserved.  
Commercial or derivative use of the code, design, or concepts is **strictly prohibited** without prior written permission from the author.

© 2025 G Abhinav (@Abhinav)

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
