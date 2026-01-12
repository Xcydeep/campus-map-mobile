import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_text_styles.dart';
import '../../../../routes/app_router.dart';
import '../../../map/presentation/providers/search_provider.dart';
import '../../../map/presentation/widgets/search_filters_widget.dart';
import '../../../map/presentation/widgets/search_results_list.dart';

class SearchScreen extends ConsumerStatefulWidget {
  final String? initialQuery;

  const SearchScreen({
    super.key,
    this.initialQuery,
  });

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  late TextEditingController _searchController;
  late FocusNode _searchFocusNode;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(text: widget.initialQuery);
    _searchFocusNode = FocusNode();
    
    // Auto-focus sur le champ de recherche
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _searchFocusNode.requestFocus();
      
      if (widget.initialQuery != null && widget.initialQuery!.isNotEmpty) {
        ref.read(searchProvider.notifier).search(widget.initialQuery!);
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final searchState = ref.watch(searchProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Barre de recherche
            _buildSearchHeader(context),

            // Filtres
            if (searchState.activeFilters.isNotEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: SearchFiltersWidget(),
              ),

            // Contenu
            Expanded(
              child: _buildContent(searchState),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () => context.navigateBack(),
            icon: const Icon(Icons.arrow_back),
            color: AppColors.textPrimary,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Hero(
              tag: 'search_bar',
              child: Material(
                color: Colors.transparent,
                child: TextField(
                  controller: _searchController,
                  focusNode: _searchFocusNode,
                  style: AppTextStyles.body,
                  decoration: InputDecoration(
                    hintText: 'Rechercher un lieu, un cours...',
                    hintStyle: AppTextStyles.searchHint,
                    border: InputBorder.none,
                    prefixIcon: Icon(
                      Icons.search,
                      color: AppColors.textSecondary,
                    ),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            onPressed: () {
                              _searchController.clear();
                              ref.read(searchProvider.notifier).clearSearch();
                            },
                            icon: const Icon(Icons.clear),
                            color: AppColors.textSecondary,
                          )
                        : null,
                  ),
                  onChanged: (value) {
                    ref.read(searchProvider.notifier).search(value);
                  },
                  onSubmitted: (value) {
                    ref.read(searchProvider.notifier).search(value);
                  },
                ),
              ),
            ),
          ),
          IconButton(
            onPressed: () {
              _showFiltersBottomSheet(context);
            },
            icon: const Icon(Icons.tune),
            color: AppColors.primary,
          ),
        ],
      ),
    );
  }

  Widget _buildContent(SearchState searchState) {
    if (_searchController.text.isEmpty) {
      return _buildRecentSearches();
    }

    if (searchState.isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (searchState.error != null) {
      return _buildError(searchState.error!);
    }

    if (searchState.results.isEmpty) {
      return _buildEmptyState();
    }

    return const SearchResultsList();
  }

  Widget _buildRecentSearches() {
    final recentSearches = ref.watch(searchProvider).recentSearches;

    if (recentSearches.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search,
              size: 64,
              color: AppColors.textHint,
            ),
            const SizedBox(height: 16),
            Text(
              'Recherchez un lieu ou un cours',
              style: AppTextStyles.body.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Recherches récentes',
              style: AppTextStyles.h6,
            ),
            TextButton(
              onPressed: () {
                ref.read(searchProvider.notifier).clearRecentSearches();
              },
              child: Text(
                'Effacer tout',
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.primary,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...recentSearches.map((search) {
          return ListTile(
            leading: Icon(
              Icons.history,
              color: AppColors.textSecondary,
            ),
            title: Text(search, style: AppTextStyles.body),
            trailing: IconButton(
              onPressed: () {
                ref.read(searchProvider.notifier).removeRecentSearch(search);
              },
              icon: const Icon(Icons.close),
              color: AppColors.textSecondary,
            ),
            onTap: () {
              _searchController.text = search;
              ref.read(searchProvider.notifier).search(search);
            },
          );
        }),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off,
            size: 64,
            color: AppColors.textHint,
          ),
          const SizedBox(height: 16),
          Text(
            'Aucun résultat trouvé',
            style: AppTextStyles.h6,
          ),
          const SizedBox(height: 8),
          Text(
            'Essayez avec d\'autres mots-clés',
            style: AppTextStyles.body.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildError(String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: AppColors.error,
          ),
          const SizedBox(height: 16),
          Text(
            'Une erreur est survenue',
            style: AppTextStyles.h6,
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              error,
              style: AppTextStyles.body.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              ref.read(searchProvider.notifier).search(_searchController.text);
            },
            icon: const Icon(Icons.refresh),
            label: const Text('Réessayer'),
          ),
        ],
      ),
    );
  }

  void _showFiltersBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Filtres',
                  style: AppTextStyles.h5,
                ),
                TextButton(
                  onPressed: () {
                    ref.read(searchProvider.notifier).clearFilters();
                    Navigator.pop(context);
                  },
                  child: const Text('Réinitialiser'),
                ),
              ],
            ),
            const SizedBox(height: 20),
            const SearchFiltersWidget(isInBottomSheet: true),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  ref.read(searchProvider.notifier).applyFilters();
                },
                child: const Text('Appliquer'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}