import 'package:flutter/material.dart';
import '../data/database_helper.dart';
import '../models/city_model.dart';
import '../services/weather_service.dart';
import '../theme/app_theme.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<CityLocation> _searchResults = [];
  List<RecentSearch> _recentSearches = [];
  List<CityLocation> _savedCities = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadLocalData();
  }

  Future<void> _loadLocalData() async {
    final recents = await DatabaseHelper.instance.getRecentSearches();
    final saved = await DatabaseHelper.instance.getSavedCities();
    setState(() {
      _recentSearches = recents;
      _savedCities = saved;
    });
  }

  Future<void> _performSearch(String query) async {
    if (query.trim().isEmpty) {
      setState(() {
        _searchResults = [];
        _isLoading = false;
      });
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final results = await WeatherService.instance.searchCities(query);
      setState(() {
        _searchResults = results;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Search City'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              autofocus: true,
              onChanged: _performSearch,
              decoration: InputDecoration(
                hintText: 'Search city, airport, or region...',
                prefixIcon: const Icon(Icons.search, color: AppTheme.primary),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () {
                          _searchController.clear();
                          _performSearch('');
                        },
                      )
                    : null,
                filled: true,
                fillColor: AppTheme.surfaceContainerLowest,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: const BorderSide(color: AppTheme.outlineVariant),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: const BorderSide(color: AppTheme.outlineVariant),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: const BorderSide(color: AppTheme.primary, width: 2),
                ),
              ),
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _searchResults.isNotEmpty
                    ? ListView.builder(
                        itemCount: _searchResults.length,
                        itemBuilder: (context, index) {
                          final city = _searchResults[index];
                          return ListTile(
                            leading: const CircleAvatar(
                              backgroundColor: AppTheme.surfaceContainerLow,
                              child: Icon(Icons.location_city, color: AppTheme.primary),
                            ),
                            title: Text(city.cityName, style: const TextStyle(fontWeight: FontWeight.bold)),
                            subtitle: Text(city.country),
                            trailing: IconButton(
                              icon: const Icon(Icons.star_border, color: AppTheme.secondary),
                              onPressed: () async {
                                await DatabaseHelper.instance.insertCity(city);
                                if (!context.mounted) return;
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('${city.cityName} added to saved cities!')),
                                );
                                _loadLocalData();
                              },
                            ),
                            onTap: () async {
                              // Save to recent searches
                              await DatabaseHelper.instance.addRecentSearch(
                                RecentSearch(
                                  cityName: city.cityName,
                                  country: city.country,
                                  latitude: city.latitude,
                                  longitude: city.longitude,
                                ),
                              );
                              if (!context.mounted) return;
                              Navigator.pop(context, city);
                            },
                          );
                        },
                      )
                    : _searchController.text.isNotEmpty
                        ? const Center(child: Text('No cities found'))
                        : ListView(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            children: [
                              if (_recentSearches.isNotEmpty) ... [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text('Recent Searches', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                    TextButton(
                                      onPressed: () async {
                                        await DatabaseHelper.instance.clearRecentSearches();
                                        _loadLocalData();
                                      },
                                      child: const Text('Clear all'),
                                    ),
                                  ],
                                ),
                                ..._recentSearches.map((r) => ListTile(
                                      leading: const Icon(Icons.history, color: AppTheme.outline),
                                      title: Text(r.cityName),
                                      subtitle: Text(r.country),
                                      onTap: () {
                                        Navigator.pop(
                                          context,
                                          CityLocation(
                                            cityName: r.cityName,
                                            country: r.country,
                                            latitude: r.latitude,
                                            longitude: r.longitude,
                                          ),
                                        );
                                      },
                                    )),
                                const Divider(height: 32),
                              ],
                              const Text('Saved & Worldwide Locations', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                              const SizedBox(height: 8),
                              ..._savedCities.map((city) => ListTile(
                                    leading: const CircleAvatar(
                                      backgroundColor: AppTheme.surfaceContainerHigh,
                                      child: Icon(Icons.star, color: AppTheme.primary),
                                    ),
                                    title: Text(city.cityName, style: const TextStyle(fontWeight: FontWeight.bold)),
                                    subtitle: Text(city.country),
                                    trailing: IconButton(
                                      icon: const Icon(Icons.delete_outline, color: AppTheme.outline),
                                      onPressed: () async {
                                        if (city.id != null) {
                                          await DatabaseHelper.instance.deleteCity(city.id!);
                                          _loadLocalData();
                                        }
                                      },
                                    ),
                                    onTap: () {
                                      Navigator.pop(context, city);
                                    },
                                  )),
                            ],
                          ),
          ),
        ],
      ),
    );
  }
}
