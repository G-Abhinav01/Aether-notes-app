import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:aether/repositories/content_repository.dart';
import 'package:aether/services/navigation_service.dart';

// Screen imports
import 'package:aether/screens/home_screen.dart';
import 'package:aether/screens/folder_screen.dart';
import 'package:aether/screens/note_screen.dart';
import 'package:aether/screens/task_screen.dart';
import 'package:aether/screens/image_screen.dart';
import 'package:aether/screens/search_screen.dart';
import 'package:aether/screens/recent_notes_screen.dart';
import 'package:aether/screens/recent_tasks_screen.dart';
import 'package:aether/screens/trash_screen.dart';
import 'package:aether/screens/settings_screen.dart';
import 'package:aether/screens/not_found_screen.dart';

/// App router configuration
class AppRouter {
  final ContentRepository _contentRepository;
  final NavigationService _navigationService;

  AppRouter({
    required ContentRepository contentRepository,
    required NavigationService navigationService,
  }) : _contentRepository = contentRepository,
       _navigationService = navigationService;

  /// Create the router
  GoRouter get router => GoRouter(
    initialLocation: '/',
    debugLogDiagnostics: true,
    routes: [
      // Home route (root folder)
      GoRoute(path: '/', builder: (context, state) => const HomeScreen()),

      // Folder route
      GoRoute(
        path: '/folder/:id',
        builder: (context, state) {
          final folderId = state.pathParameters['id'];
          return FolderScreen(folderId: folderId);
        },
      ),

      // Note route
      GoRoute(
        path: '/note/:id',
        builder: (context, state) {
          final noteId = state.pathParameters['id']!;
          return NoteScreen(noteId: noteId);
        },
      ),

      // Task route
      GoRoute(
        path: '/task/:id',
        builder: (context, state) {
          final taskId = state.pathParameters['id']!;
          return TaskScreen(taskId: taskId);
        },
      ),

      // Image route
      GoRoute(
        path: '/image/:id',
        builder: (context, state) {
          final imageId = state.pathParameters['id']!;
          return ImageScreen(imageId: imageId);
        },
      ),

      // Recent notes route
      GoRoute(
        path: '/recent-notes',
        builder: (context, state) => const RecentNotesScreen(),
      ),

      // Recent tasks route
      GoRoute(
        path: '/recent-tasks',
        builder: (context, state) => const RecentTasksScreen(),
      ),

      // Trash route
      GoRoute(path: '/trash', builder: (context, state) => const TrashScreen()),

      // Search route
      GoRoute(
        path: '/search',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          return SearchScreen(
            initialQuery: extra?['query'],
            folderId: extra?['folderId'],
          );
        },
      ),

      // Settings route
      GoRoute(
        path: '/settings',
        builder: (context, state) => const SettingsScreen(),
      ),
    ],
    errorBuilder: (context, state) => const NotFoundScreen(),
    redirect: _handleRedirect,
  );

  /// Handle redirects
  String? _handleRedirect(BuildContext context, GoRouterState state) {
    // Handle any redirects here
    return null;
  }
}
