import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:aether/repositories/content_repository.dart';
import 'package:aether/services/navigation_service.dart';
import 'package:aether/models/models.dart';

class BreadcrumbNavigation extends StatelessWidget {
  const BreadcrumbNavigation({super.key});

  @override
  Widget build(BuildContext context) {
    final navigationService = Provider.of<NavigationService>(context);
    final contentRepository = Provider.of<ContentRepository>(context);
    final breadcrumbs = navigationService.getBreadcrumbs();
    
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
        borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            for (int i = 0; i < breadcrumbs.length; i++)
              FutureBuilder<Folder?>(
                future: breadcrumbs[i] != null 
                    ? contentRepository.getFolder(breadcrumbs[i]!)
                    : null,
                builder: (context, snapshot) {
                  final folderName = breadcrumbs[i] == null
                      ? 'Home'
                      : snapshot.data?.name ?? 'Folder';
                  
                  final isLast = i == breadcrumbs.length - 1;
                  
                  return Row(
                    children: [
                      if (i > 0) 
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4.0),
                          child: Icon(
                            Icons.chevron_right, 
                            size: 16,
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                        ),
                      InkWell(
                        onTap: () {
                          if (isLast) return; // Don't navigate if already at this location
                          
                          navigationService.navigateToBreadcrumb(i);
                          if (i == 0) {
                            context.go('/');
                          } else {
                            final folderId = breadcrumbs[i];
                            context.go('/folder/$folderId');
                          }
                        },
                        borderRadius: BorderRadius.circular(4),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                          child: Row(
                            children: [
                              Icon(
                                i == 0 ? Icons.home : Icons.folder,
                                size: 16,
                                color: isLast 
                                    ? Theme.of(context).colorScheme.primary
                                    : Theme.of(context).colorScheme.onSurfaceVariant,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                folderName,
                                style: TextStyle(
                                  fontWeight: isLast ? FontWeight.bold : FontWeight.normal,
                                  color: isLast 
                                      ? Theme.of(context).colorScheme.primary
                                      : Theme.of(context).colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}