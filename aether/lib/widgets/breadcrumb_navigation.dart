import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:aether/services/navigation_service.dart';
import 'package:aether/repositories/content_repository.dart';
import 'package:aether/models/models.dart';

/// Breadcrumb navigation widget for folder hierarchy
class BreadcrumbNavigation extends StatelessWidget {
  const BreadcrumbNavigation({super.key});

  @override
  Widget build(BuildContext context) {
    final navigationService = Provider.of<NavigationService>(context);
    final contentRepository = Provider.of<ContentRepository>(context);

    return FutureBuilder<List<Folder?>>(
      future: _buildBreadcrumbFolders(navigationService, contentRepository),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox(
            height: 40,
            child: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError || !snapshot.hasData) {
          return const SizedBox.shrink();
        }

        final folders = snapshot.data!;

        return Container(
          height: 40,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: folders.length,
            separatorBuilder: (context, index) => const Padding(
              padding: EdgeInsets.symmetric(horizontal: 4),
              child: Icon(Icons.chevron_right, size: 16, color: Colors.grey),
            ),
            itemBuilder: (context, index) {
              final folder = folders[index];
              final isLast = index == folders.length - 1;

              return GestureDetector(
                onTap: isLast
                    ? null
                    : () => _navigateToBreadcrumb(context, index),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: isLast
                        ? Theme.of(context).primaryColor.withOpacity(0.1)
                        : null,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    folder?.name ?? 'Home',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: isLast ? FontWeight.w600 : FontWeight.w400,
                      color: isLast
                          ? Theme.of(context).primaryColor
                          : Theme.of(context).textTheme.bodyMedium?.color,
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  /// Build list of folders for breadcrumb display
  Future<List<Folder?>> _buildBreadcrumbFolders(
    NavigationService navigationService,
    ContentRepository contentRepository,
  ) async {
    final breadcrumbs = navigationService.getBreadcrumbs();
    final List<Folder?> folders = [];

    for (final folderId in breadcrumbs) {
      if (folderId == null) {
        folders.add(null); // Root folder
      } else {
        try {
          final item = await contentRepository.getItemById(folderId);
          if (item is Folder) {
            folders.add(item);
          } else {
            folders.add(null); // Fallback if item is not a folder
          }
        } catch (e) {
          folders.add(null); // Fallback on error
        }
      }
    }

    return folders;
  }

  /// Navigate to a specific breadcrumb position
  void _navigateToBreadcrumb(BuildContext context, int index) {
    final navigationService = Provider.of<NavigationService>(
      context,
      listen: false,
    );
    navigationService.navigateToBreadcrumb(index);

    // Navigate using GoRouter
    final folderId = navigationService.currentFolderId;
    if (folderId == null) {
      context.go('/');
    } else {
      context.go('/folder/$folderId');
    }
  }
}

/// Back button widget for navigation
class NavigationBackButton extends StatelessWidget {
  const NavigationBackButton({super.key});

  @override
  Widget build(BuildContext context) {
    final navigationService = Provider.of<NavigationService>(context);

    if (!navigationService.canNavigateBack()) {
      return const SizedBox.shrink();
    }

    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () => _navigateBack(context),
      tooltip: 'Back',
    );
  }

  /// Navigate back to previous folder
  void _navigateBack(BuildContext context) {
    final navigationService = Provider.of<NavigationService>(
      context,
      listen: false,
    );
    final previousFolderId = navigationService.navigateBack();

    // Navigate using GoRouter
    if (previousFolderId == null) {
      context.go('/');
    } else {
      context.go('/folder/$previousFolderId');
    }
  }
}
