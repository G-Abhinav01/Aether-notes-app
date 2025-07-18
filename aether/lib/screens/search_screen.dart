import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:aether/models/models.dart';
import 'package:aether/services/search_service.dart';
import 'package:aether/services/navigation_service.dart';
import 'package:aether/widgets/content_list_item.dart';
import 'package:aether/widgets/breadcrumb_navigation.dart';

class SearchScreen extends StatefulWidget {
  final String? initialQuery;
  final String? folderId;

  const SearchScreen({super.key, this.initialQuery, this.folderId});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  List<ContentItem> _searchResults = [];
  List<String> _suggestions = [];
  bool _isLoading = false;
  bool _showSuggestions = false;
  ContentType? _selectedType;
  List<String> _selectedTags = [];
  List<String> _availableTags = [];

  @override
  void initState() {
    super.initState();
    if (widget.initialQuery != null) {
      _searchController.text = widget.initialQuery!;
      _performSearch();
    }
    _loadAvailableTags();
    _searchFocusNode.addListener(_onFocusChange);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _onFocusChange() {
    if (_searchFocusNode.hasFocus && _searchController.text.isNotEmpty) {
      _loadSuggestions();
    } else {
      setState(() {
        _showSuggestions = false;
      });
    }
  }

  Future<void> _loadAvailableTags() async {
    try {
      final searchService = Provider.of<SearchService>(context, listen: false);
      final tags = await searchService.getAllTags(folderId: widget.folderId);
      setState(() {
        _availableTags = tags;
      });
    } catch (e) {
      // Handle error silently
    }
  }

  Future<void> _loadSuggestions() async {
    if (_searchController.text.trim().isEmpty) {
      setState(() {
        _suggestions = [];
        _showSuggestions = false;
      });
      return;
    }

    try {
      final searchService = Provider.of<SearchService>(context, listen: false);
      final suggestions = await searchService.getSearchSuggestions(
        _searchController.text,
      );
      setState(() {
        _suggestions = suggestions;
        _showSuggestions = suggestions.isNotEmpty;
      });
    } catch (e) {
      setState(() {
        _suggestions = [];
        _showSuggestions = false;
      });
    }
  }

  Future<void> _performSearch() async {
    final query = _searchController.text.trim();
    if (query.isEmpty) {
      setState(() {
        _searchResults = [];
        _showSuggestions = false;
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _showSuggestions = false;
    });

    try {
      final searchService = Provider.of<SearchService>(context, listen: false);

      List<ContentItem> results;

      if (_selectedTags.isNotEmpty) {
        // Search by tags
        results = await searchService.searchByTags(
          _selectedTags,
          folderId: widget.folderId,
        );
        // Filter by query if provided
        if (query.isNotEmpty) {
          results = results
              .where(
                (item) =>
                    item.name.toLowerCase().contains(query.toLowerCase()) ||
                    (item is Note &&
                        item.content.toLowerCase().contains(
                          query.toLowerCase(),
                        )),
              )
              .toList();
        }
      } else if (_selectedType != null) {
        // Search by type
        results = await searchService.searchByType(
          query,
          _selectedType!,
          folderId: widget.folderId,
        );
      } else {
        // General search
        results = await searchService.search(query, folderId: widget.folderId);
      }

      setState(() {
        _searchResults = results;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Search failed: $e')));
      }
    }
  }

  void _onSuggestionTap(String suggestion) {
    _searchController.text = suggestion;
    _searchFocusNode.unfocus();
    _performSearch();
  }

  void _clearSearch() {
    _searchController.clear();
    setState(() {
      _searchResults = [];
      _suggestions = [];
      _showSuggestions = false;
      _selectedType = null;
      _selectedTags.clear();
    });
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => _FilterDialog(
        selectedType: _selectedType,
        selectedTags: _selectedTags,
        availableTags: _availableTags,
        onApply: (type, tags) {
          setState(() {
            _selectedType = type;
            _selectedTags = tags;
          });
          _performSearch();
        },
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          TextField(
            controller: _searchController,
            focusNode: _searchFocusNode,
            decoration: InputDecoration(
              hintText: 'Search content... (use # for filename only)',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (_selectedType != null || _selectedTags.isNotEmpty)
                    IconButton(
                      icon: const Icon(Icons.filter_alt),
                      onPressed: _showFilterDialog,
                      color: Theme.of(context).colorScheme.primary,
                    )
                  else
                    IconButton(
                      icon: const Icon(Icons.filter_alt_outlined),
                      onPressed: _showFilterDialog,
                    ),
                  if (_searchController.text.isNotEmpty)
                    IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: _clearSearch,
                    ),
                ],
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onChanged: (value) {
              if (value.isNotEmpty) {
                _loadSuggestions();
              } else {
                setState(() {
                  _showSuggestions = false;
                  _searchResults = [];
                });
              }
            },
            onSubmitted: (value) => _performSearch(),
          ),

          // Active filters display
          if (_selectedType != null || _selectedTags.isNotEmpty) ...[
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [
                if (_selectedType != null)
                  Chip(
                    label: Text(_selectedType!.name),
                    onDeleted: () {
                      setState(() {
                        _selectedType = null;
                      });
                      _performSearch();
                    },
                  ),
                ..._selectedTags.map(
                  (tag) => Chip(
                    label: Text(tag),
                    onDeleted: () {
                      setState(() {
                        _selectedTags.remove(tag);
                      });
                      _performSearch();
                    },
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSuggestions() {
    if (!_showSuggestions || _suggestions.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: _suggestions
            .map(
              (suggestion) => ListTile(
                leading: const Icon(Icons.search),
                title: Text(suggestion),
                onTap: () => _onSuggestionTap(suggestion),
              ),
            )
            .toList(),
      ),
    );
  }

  Widget _buildSearchResults() {
    if (_isLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_searchResults.isEmpty && _searchController.text.isNotEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.search_off,
                size: 64,
                color: Theme.of(context).colorScheme.outline,
              ),
              const SizedBox(height: 16),
              Text(
                'No results found',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Text(
                'Try different keywords or remove filters',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.outline,
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (_searchResults.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.search,
                size: 64,
                color: Theme.of(context).colorScheme.outline,
              ),
              const SizedBox(height: 16),
              Text(
                'Start searching',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Text(
                'Enter keywords to find your content',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.outline,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: _searchResults.length,
      itemBuilder: (context, index) {
        final item = _searchResults[index];
        return ContentListItem(
          item: item,
          onTap: () {
            final navigationService = Provider.of<NavigationService>(
              context,
              listen: false,
            );
            navigationService.navigateToItem(context, item);
          },
          showPath: true, // Show the path context in search results
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Search'), elevation: 0),
      body: Column(
        children: [
          const BreadcrumbNavigation(),
          _buildSearchBar(),
          Expanded(
            child: Stack(
              children: [_buildSearchResults(), _buildSuggestions()],
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterDialog extends StatefulWidget {
  final ContentType? selectedType;
  final List<String> selectedTags;
  final List<String> availableTags;
  final Function(ContentType?, List<String>) onApply;

  const _FilterDialog({
    required this.selectedType,
    required this.selectedTags,
    required this.availableTags,
    required this.onApply,
  });

  @override
  State<_FilterDialog> createState() => _FilterDialogState();
}

class _FilterDialogState extends State<_FilterDialog> {
  ContentType? _selectedType;
  List<String> _selectedTags = [];

  @override
  void initState() {
    super.initState();
    _selectedType = widget.selectedType;
    _selectedTags = List.from(widget.selectedTags);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Filter Search'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Content Type Filter
            const Text(
              'Content Type:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [
                FilterChip(
                  label: const Text('All'),
                  selected: _selectedType == null,
                  onSelected: (selected) {
                    setState(() {
                      _selectedType = selected ? null : _selectedType;
                    });
                  },
                ),
                ...ContentType.values.map(
                  (type) => FilterChip(
                    label: Text(type.name),
                    selected: _selectedType == type,
                    onSelected: (selected) {
                      setState(() {
                        _selectedType = selected ? type : null;
                      });
                    },
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Tags Filter
            if (widget.availableTags.isNotEmpty) ...[
              const Text(
                'Tags:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: widget.availableTags
                    .map(
                      (tag) => FilterChip(
                        label: Text(tag),
                        selected: _selectedTags.contains(tag),
                        onSelected: (selected) {
                          setState(() {
                            if (selected) {
                              _selectedTags.add(tag);
                            } else {
                              _selectedTags.remove(tag);
                            }
                          });
                        },
                      ),
                    )
                    .toList(),
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            setState(() {
              _selectedType = null;
              _selectedTags.clear();
            });
          },
          child: const Text('Clear All'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () {
            widget.onApply(_selectedType, _selectedTags);
            Navigator.pop(context);
          },
          child: const Text('Apply'),
        ),
      ],
    );
  }
}
