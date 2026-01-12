import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/search_provider.dart';
import '../providers/map_provider.dart';
import '../../domain/entities/place.dart';
import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_text_styles.dart';

class SearchBarWidget extends ConsumerStatefulWidget {
  const SearchBarWidget({super.key});

  @override
  ConsumerState<SearchBarWidget> createState() => _SearchBarWidgetState();
}

class _SearchBarWidgetState extends ConsumerState<SearchBarWidget> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  bool _showResults = false;

  @override
  void dispose() {
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    if (query.isNotEmpty) {
      ref.read(searchProvider.notifier).search(query);
      setState(() {
        _showResults = true;
      });
    } else {
      ref.read(searchProvider.notifier).clearSearch();
      setState(() {
        _showResults = false;
      });
    }
  }

  void _onPlaceSelected(Place place) {
    // Centrer la carte sur le lieu sélectionné
    ref.read(mapProvider.notifier).selectPlace(place);
    
    // Fermer les résultats de recherche
    setState(() {
      _showResults = false;
    });
    _focusNode.unfocus();
    _searchController.clear();
    ref.read(searchProvider.notifier).clearSearch();
  }

  @override
  Widget build(BuildContext context) {
    final searchState = ref.watch(searchProvider);

    return Column(
      children: [
        Material(
          elevation: 4,
          borderRadius: BorderRadius.circular(12),
          child: TextField(
            controller: _searchController,
            focusNode: _focusNode,
            onChanged: _onSearchChanged,
            onTap: () {
              if (_searchController.text.isNotEmpty) {
                setState(() {
                  _showResults = true;
                });
              }
            },
            decoration: InputDecoration(
              hintText: 'Rechercher un lieu...',
              prefixIcon: const Icon(Icons.search, color: AppColors.primary),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                        ref.read(searchProvider.notifier).clearSearch();
                        setState(() {
                          _showResults = false;
                        });
                        _focusNode.unfocus();
                      },
                    )
                  : null,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
            ),
          ),
        ),
        // Résultats de recherche
        if (_showResults && searchState.query.isNotEmpty)
          Material(
            elevation: 8,
            borderRadius: const BorderRadius.vertical(
              bottom: Radius.circular(12),
            ),
            child: Container(
              constraints: const BoxConstraints(maxHeight: 300),
              child: _buildResults(searchState),
            ),
          ),
      ],
    );
  }

  Widget _buildResults(SearchState searchState) {
    if (searchState.isLoading) {
      return const Padding(
        padding: EdgeInsets.all(16.0),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (searchState.error != null && searchState.results.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(16.0),
        child: Text(
          searchState.error!,
          style: AppTextStyles.body.copyWith(color: AppColors.error),
        ),
      );
    }

    if (searchState.results.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(16.0),
        child: Text('Aucun résultat trouvé'),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      itemCount: searchState.results.length,
      itemBuilder: (context, index) {
        final place = searchState.results[index];
        return ListTile(
          leading: const Icon(Icons.place, color: AppColors.primary),
          title: Text(place.name, style: AppTextStyles.body),
          subtitle: place.address != null
              ? Text(place.address!, style: AppTextStyles.caption)
              : place.description != null
                  ? Text(place.description!, style: AppTextStyles.caption)
                  : null,
          onTap: () => _onPlaceSelected(place),
        );
      },
    );
  }
}
