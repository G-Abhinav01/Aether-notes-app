import 'package:aether/models/models.dart';
import 'package:aether/repositories/content_repository.dart';

class SearchService {
  final ContentRepository _contentRepository;

  SearchService(this._contentRepository);

  /// Search for content items based on query
  /// Supports special syntax:
  /// - #query: search only in filenames
  /// - Regular query: search in content and filenames
  Future<List<ContentItem>> search(String query, {String? folderId}) async {
    if (query.trim().isEmpty) return [];

    final trimmedQuery = query.trim();
    final bool filenameOnly = trimmedQuery.startsWith('#');
    final String searchTerm = filenameOnly
        ? trimmedQuery.substring(1).trim()
        : trimmedQuery;

    if (searchTerm.isEmpty) return [];

    try {
      return await _contentRepository.searchContent(
        searchTerm,
        folderId: folderId,
        filenameOnly: filenameOnly,
      );
    } catch (e) {
      throw Exception('Search failed: $e');
    }
  }

  /// Get search suggestions based on partial query
  Future<List<String>> getSearchSuggestions(String query) async {
    if (query.trim().isEmpty) return [];

    try {
      // Get recent search terms and content names that match
      final suggestions = <String>[];

      // Add filename suggestions
      final items = await _contentRepository.searchContent(query, limit: 5);
      for (final item in items) {
        if (item.name.toLowerCase().contains(query.toLowerCase())) {
          suggestions.add(item.name);
        }
      }

      return suggestions.take(10).toList();
    } catch (e) {
      return [];
    }
  }

  /// Search within a specific content type
  Future<List<ContentItem>> searchByType(
    String query,
    ContentType type, {
    String? folderId,
  }) async {
    if (query.trim().isEmpty) return [];

    try {
      final allResults = await search(query, folderId: folderId);
      return allResults.where((item) => item.type == type).toList();
    } catch (e) {
      throw Exception('Type-specific search failed: $e');
    }
  }

  /// Search for items with specific tags
  Future<List<ContentItem>> searchByTags(
    List<String> tags, {
    String? folderId,
  }) async {
    if (tags.isEmpty) return [];

    try {
      return await _contentRepository.getItemsByTags(tags, folderId: folderId);
    } catch (e) {
      throw Exception('Tag search failed: $e');
    }
  }

  /// Get all unique tags in the system
  Future<List<String>> getAllTags({String? folderId}) async {
    try {
      return await _contentRepository.getAllTags(folderId: folderId);
    } catch (e) {
      return [];
    }
  }
}
