# 📘 Aether — A Branching-Structured, Lightweight Note + Task App  
**Creator:** @achiver  
**Platform Target:** Mobile-first (React Native / Flutter)

---

## 🧠 Vision & Motivation

Most mainstream note-taking apps today fall on two extremes: either overly minimal and flat (like Google Keep), or heavily structured and overly rigid (like Notion). For a user who thinks in categories, subcategories, and contextually branching ideas, there’s often no "just right" middle ground.

Personally, I’ve never found myself sticking to tools like Notion or Google Keep.

- Notion feels overly complex and heavy, especially when all I want is to take notes or track tasks in an organized, nested fashion.
- Google Keep is too flat — no hierarchy, no folders, no structure.
- Even MI/Realme’s default Notes app felt better — at least it offered folders. But still, it lacked subfolders, smart tagging, and depth.

In trying to manage things like:

- J-content tracking (anime, manga, dramas) like multiple different titles, inside j content, multiple anime folders with different names, then inside one of them having multiple episodes, etc.

- Academic notes (e.g., folder 6th Sem → Subjects → Chapters → Images or text notes)
- Exam prep (physical notes backed up as images, with chapter context)
- Content ideas / writing prompts stored under genres or themes
- since sometimes even if a note taking app is good it dosen't allow you to input images and text together, it's either text only or image only, and that's not ideal. 
- I also need a way to store my exam questions, so i can't just dump them in a note app, i need to make a folder for them and then put them in there.

...the lack of branching, nested structure, and contextually rich note organization made every existing solution either cluttered or a compromise.

**Hence, Aether is my answer to this problem**: A structured-yet-minimal, folder-driven note + task manager app with a clean UX, dark mode, and AI enhancements — built for people like me who want contextual recall, nested categorization, and freedom.

---

## 💡 Core Idea

Aether is a hierarchically branching productivity app where:

- Notes and tasks live inside folders or subfolders, not in flat lists  
- Folders can contain both notes and other folders  
- Each item (note/task/folder) can have tags, optional images, and contextual metadata  
- Designed for quick input but long-term organization  
- Built for exam preppers, hobbyists, info collectors, and idea sorters  

---

## 🔍 Pain Points Addressed

| User Frustration                               | How Aether Solves It                            |
|------------------------------------------------|-------------------------------------------------|
| Flat note structures (Google Keep)             | Folders & unlimited subfolders                  |
| No recall context in long note lists           | Branching system + tags                         |
| Overhead in complex tools (Notion)             | Minimal, mobile-first UX                        |
| Poor exam material digitization                | Image upload in notes under chapters            |
| Confusing drive-based prep (Google Drive)      | Integrated view with structure + dark mode      |
| Lack of dark theme and personalization         | Theming included                                |

---

## 🧭 Core Features (MVP)

| Feature Category   | Functionality                                                   |
|--------------------|-----------------------------------------------------------------|
| Folders            | Create nested folders (e.g. J-Content → Anime → Shingeki)       |
| Notes              | Text notes with title, content, tags, timestamps                |
| Tasks              | Checklist or task entries (linked to any folder)                |
| Image Upload       | Attach photo scans / prep material to notes                     |
| Tags               | Add searchable tags to notes/tasks                              |
| Dark Mode          | Native theming support                                          |
| Search             | Global + folder-level keyword and tag-based search              |
| Offline First      | Works without net, syncs when reconnected                       |
| AI Extensions (Future) | Smart summarizer, auto-tag suggestions                     |

---

## 📱 Ideal Use Cases

- **Students:** Organize semester → subject → chapters → notes/images/tasks  
- **Media Consumers:** Track anime/manga/drama with nested notes or impressions  
- **Writers:** Categorize writing prompts into genres/themes  
- **Project Organizers:** Keep tasks and documentation per project/subproject  

---

## 🌱 Design Ethos

- **Lightweight, calming UX**  
  Clean UI with quick access to folders/tags  

- **Hierarchical yet flexible**  
  You can branch deeply or stay flat — your choice  

- **Minimal but expandable**  
  Doesn’t overwhelm like Notion but can grow in structure like a mindmap  

- **Mobile-first**  
  Optimized for Android/iOS, offline access, quick note/image capture  

---

## 🧑‍💻 Platform Decision: React Native or Flutter

You want this to be:

- Mobile-first, since the use case involves on-the-go documentation (classes, commutes, consuming content)  
- Offline-capable, with occasional sync to cloud  
- Visually intuitive, supporting dark mode and touch gestures (drag/drop, swiping)  

### ✅ Recommendation: React Native

- Reusable logic if needed for web later (via Expo Web or Next.js)  
- Mature component libraries (e.g., Tamagui, NativeBase, Shadcn-mobile)  
- Easier Firebase integration (for auth + DB sync)  

> Flutter is a valid alternate if you want a single-codebase aesthetic and native feel — just depends on which ecosystem you prefer.

---

## 🛠️ Tools to Use for Scaffolding

- **Trae or Void IDE:** for mobile-first scaffolding (React Native base)  
- **Firebase:** auth + Firestore DB (sync folders, notes, etc.)  
- **Expo (if React Native):** quick setup and OTA updates  
- **Zustand or Context API:** lightweight state  
- **Shadcn-mobile / Tamagui:** for styling  

---

## 📌 Summary Statement for AI Agents (Paste-Ready)

I'm building a mobile-first note and task management app called **Aether**. It's designed to be lightweight and structured — offering folders, subfolders, notes, tasks, and tagging — all arranged in a nested, branching system similar to file systems.

The motivation stems from my frustration with existing tools:

- Notion is too heavy and overwhelming for quick, practical use  
- Google Keep is too flat — lacks structure and hierarchy  
- I personally rely on MI/Realme Notes for its folders, but it lacks depth like subfolders or smart recall  

My usage includes J-content tracking, exam prep organization, and idea collection — all of which need nested structuring, offline access, and intuitive navigation.

The UI should be clean, themeable (dark mode), and allow adding text notes, tasks, and even images (for scanned handwritten notes).

The final vision is a hybrid between Google Keep,Google Drive, MI/Realme Notes, and a lighter Notion — with added flexibility for tagging and AI-driven enhancements (like auto-tags or summaries) in future phases.

The app will be developed using React Native, with Firebase for auth and DB, and Shadcn-mobile/Tamagui for styling.

The app will have a folder structure similar to Google Drive, with notes and tasks being the leaf nodes, and folders containing them. The user will be able to create, edit, and delete folders and notes, as well as add tags to notes. The app will also have a dark mode, and will be able to have offline support which can sync online , so the user can access their notes from anywhere.

The app will be available for Android and iOS, and will be free (just for early builds and later will have paid plans for Premium features like AI summarisation and stuff).



