import 'package:flutter/material.dart';
import '../data/database_helper.dart';
import '../models/city_model.dart';
import '../models/weather_model.dart';
import '../services/weather_service.dart';
import '../theme/app_theme.dart';
import 'search_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 1; // Default to Explore tab matching Google Stitch design
  WeatherData? _weatherData;
  bool _isLoading = true;
  CityLocation _currentLocation = CityLocation(
    cityName: 'New York',
    country: 'US',
    latitude: 40.7128,
    longitude: -74.0060,
  );
  List<CityLocation> _savedCities = [];
  List<RecentSearch> _recentSearches = [];
  String _selectedCategory = 'all';

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    setState(() => _isLoading = true);
    try {
      // Automatically attempt to fetch device GPS location
      final gpsLocation = await WeatherService.instance.getCurrentUserLocation();
      if (gpsLocation != null) {
        _currentLocation = gpsLocation;
      } else {
        final saved = await DatabaseHelper.instance.getSavedCities();
        if (saved.isNotEmpty) {
          _currentLocation = saved.first;
        }
      }
      final saved = await DatabaseHelper.instance.getSavedCities();
      final recents = await DatabaseHelper.instance.getRecentSearches();
      setState(() {
        _savedCities = saved;
        _recentSearches = recents;
      });
      await _fetchWeatherForCurrentLocation();
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _fetchWeatherForCurrentLocation() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final weather = await WeatherService.instance.getWeather(
        latitude: _currentLocation.latitude,
        longitude: _currentLocation.longitude,
        cityName: _currentLocation.cityName,
        country: _currentLocation.country,
      );
      setState(() {
        _weatherData = weather;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _navigateToSearch() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const SearchScreen()),
    );
    if (!mounted) return;
    if (result != null && result is CityLocation) {
      setState(() {
        _currentLocation = result;
      });
      await DatabaseHelper.instance.insertCity(result);
      if (!mounted) return;
      _loadInitialData();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Image.network(
              'https://lh3.googleusercontent.com/aida/AEtjO1VM9wTUXLShznzBRaHpEDpux9ArLZE1CxnUICn2a9tmf03Ewg4DVZTnZftuiAH-o_zSTCiEleG4WEgo9vQ1cVibMZu7SgUgRnGZJEYBMb3690toIR9-LAMmg09tw9s9gkjh5RpEm8KMaKJXkqYxqjcIalt0_ippL0T6H7lvQ-DJ7PadIh1plH9FrTzfQ5OmUOuf7o4DnjHsPttsOVOxVDTHNtRjewSKxaHC3TOS7VvQsmV-swyuNIfqWKs',
              height: 28,
              errorBuilder: (context, error, stackTrace) => const Icon(Icons.cloud, color: AppTheme.primary),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: _navigateToSearch,
              child: Row(
                children: [
                  Text(_currentLocation.cityName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppTheme.onSurface)),
                  const SizedBox(width: 4),
                  const Icon(Icons.near_me, size: 14, color: AppTheme.secondary),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.my_location),
            onPressed: () async {
              setState(() => _isLoading = true);
              final gps = await WeatherService.instance.getCurrentUserLocation();
              if (!mounted) return;
              if (gps != null) {
                setState(() => _currentLocation = gps);
                await _fetchWeatherForCurrentLocation();
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Location detected successfully via GPS!')),
                );
              } else {
                setState(() => _isLoading = false);
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Unable to detect GPS location. Please check permissions.')),
                );
              }
            },
            tooltip: 'Detect GPS Location',
          ),
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('No new weather alerts')),
              );
            },
            tooltip: 'Notifications',
          ),
          Padding(
            padding: const EdgeInsets.only(right: 12.0),
            child: CircleAvatar(
              radius: 16,
              backgroundColor: AppTheme.primary,
              child: IconButton(
                icon: const Icon(Icons.person, size: 16, color: Colors.white),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const SettingsScreen()),
                  );
                },
              ),
            ),
          ),
        ],
      ),
      body: _buildCurrentTabBody(),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppTheme.surface.withValues(alpha: 0.85),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF12345A).withValues(alpha: 0.06),
              blurRadius: 12,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
            if (index == 4) {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsScreen()),
              );
            }
          },
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.transparent,
          elevation: 0,
          selectedItemColor: AppTheme.primary,
          unselectedItemColor: AppTheme.onSurfaceVariant,
          selectedLabelStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
          unselectedLabelStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500),
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.cloud_outlined),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.travel_explore),
              label: 'Explore',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.map_outlined),
              label: 'Maps',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.favorite_outline),
              label: 'Saved',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.settings_outlined),
              label: 'Settings',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrentTabBody() {
    switch (_currentIndex) {
      case 0:
        return _buildHomeTab();
      case 1:
        return _buildExploreTab();
      case 2:
        return _buildMapsTab();
      case 3:
        return _buildSavedTab();
      case 4:
        return _buildExploreTab();
      default:
        return _buildExploreTab();
    }
  }

  // --- HOME TAB ---
  Widget _buildHomeTab() {
    return RefreshIndicator(
      onRefresh: _loadInitialData,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (_isLoading && _weatherData == null)
            const Center(child: Padding(padding: EdgeInsets.all(48), child: CircularProgressIndicator()))
          else if (_weatherData != null) ...[
            Container(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF1769E0), Color(0xFF2589F4), Color(0xFF87CEEB)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.secondary.withValues(alpha: 0.2),
                    blurRadius: 36,
                    offset: const Offset(0, 16),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _weatherData!.cityName,
                            style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                          ),
                          Text(
                            _weatherData!.country,
                            style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 14),
                          ),
                        ],
                      ),
                      Icon(
                        _getIconData(_weatherData!.conditionIcon),
                        color: Colors.white,
                        size: 48,
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Text(
                    '${_weatherData!.temperature.round()}°',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 72,
                      fontWeight: FontWeight.w200,
                      letterSpacing: -2,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _weatherData!.conditionText,
                        style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600),
                      ),
                      Text(
                        'Feels like ${_weatherData!.apparentTemperature.round()}°',
                        style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 14),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const Text('Telemetry & Conditions', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.onSurface)),
            const SizedBox(height: 12),
            GridView.count(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              childAspectRatio: 1.5,
              children: [
                _buildTelemetryCard(Icons.air, 'WIND SPEED', '${_weatherData!.windSpeed} km/h', 'Direction ${_weatherData!.windDirection}°'),
                _buildTelemetryCard(Icons.water_drop, 'HUMIDITY', '${_weatherData!.humidity}%', 'Comfortable'),
                _buildTelemetryCard(Icons.umbrella, 'PRECIPITATION', '${_weatherData!.precipitation} mm', 'Low chance'),
                _buildTelemetryCard(Icons.wb_sunny_outlined, 'UV INDEX', '${_weatherData!.uvIndex}', 'Moderate protection'),
              ],
            ),
          ],
        ],
      ),
    );
  }

  // --- EXPLORE TAB ---
  Widget _buildExploreTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        GestureDetector(
          onTap: _navigateToSearch,
          child: Container(
            height: 56,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: AppTheme.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(28),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.primary.withValues(alpha: 0.08),
                  blurRadius: 24,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Row(
              children: const [
                Icon(Icons.search, color: AppTheme.primary),
                SizedBox(width: 12),
                Expanded(child: Text('Search city, airport, or region...', style: TextStyle(color: AppTheme.outline))),
                Icon(Icons.mic, color: AppTheme.primary, size: 20),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 44,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              _buildFilterChip('all', 'All', Icons.public),
              _buildFilterChip('trending', 'Trending', Icons.trending_up),
              _buildFilterChip('aqi', 'Air Quality', Icons.air),
              _buildFilterChip('capitals', 'Capitals', Icons.account_balance),
              _buildFilterChip('coastlines', 'Coastlines', Icons.tsunami),
            ],
          ),
        ),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: const [
                Icon(Icons.history, color: AppTheme.secondary, size: 20),
                SizedBox(width: 6),
                Text('Recent Searches', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ],
            ),
            TextButton(
              onPressed: () async {
                await DatabaseHelper.instance.clearRecentSearches();
                _loadInitialData();
              },
              child: const Text('Clear all', style: TextStyle(color: AppTheme.primary, fontSize: 12)),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ...(_recentSearches.isEmpty
            ? [
                _buildRecentCard('New York', 'US', 'Clear skies • Gentle breeze', '62°', Icons.wb_sunny),
                _buildRecentCard('London', 'UK', 'Light rain • Damp mist', '55°', Icons.water_drop),
                _buildRecentCard('Tokyo', 'JP', 'Sunny • High visibility', '68°', Icons.wb_sunny),
              ]
            : _recentSearches.map((r) => _buildRecentCard(r.cityName, r.country, 'Recently searched', '60°', Icons.history))),
        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: const [
                Icon(Icons.public, color: AppTheme.primary, size: 22),
                SizedBox(width: 6),
                Text('Worldwide Highlights', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ],
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppTheme.surfaceContainerHigh,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text('Live Feed', style: TextStyle(color: AppTheme.primary, fontSize: 11, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
        const SizedBox(height: 12),
        GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          childAspectRatio: 1.15,
          children: [
            _buildHighlightCard('Paris', 'France • Central', '59°', 'Partly Cloudy', 'H: 64° L: 51°', Icons.cloud),
            _buildHighlightCard('Sydney', 'Australia • Coast', '75°', 'Sunny & Warm', 'H: 79° L: 65°', Icons.wb_sunny),
            _buildHighlightCard('Zurich', 'Switzerland • Alpine', '52°', 'Atmospheric Mist', 'H: 56° L: 46°', Icons.foggy),
            _buildHighlightCard('Vancouver', 'Canada • West Coast', '54°', 'Dense Overcast', 'H: 57° L: 48°', Icons.cloud),
          ],
        ),
      ],
    );
  }

  // --- MAPS TAB ---
  Widget _buildMapsTab() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.map, size: 64, color: AppTheme.primary),
            SizedBox(height: 16),
            Text('Worldwide Interactive Radar & Synoptic Satellite Maps', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
            SizedBox(height: 8),
            Text('Live precipitation overlay, jet stream trajectory, and thermal infrared satellite imagery.', style: TextStyle(color: AppTheme.onSurfaceVariant, fontSize: 13), textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }

  // --- SAVED TAB ---
  Widget _buildSavedTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text('Saved Locations', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        ...(_savedCities.isEmpty
            ? [
                _buildSavedCityTile('New York', 'United States', '62°', 'Clear'),
                _buildSavedCityTile('London', 'United Kingdom', '55°', 'Light Rain'),
                _buildSavedCityTile('Tokyo', 'Japan', '68°', 'Sunny'),
                _buildSavedCityTile('Paris', 'France', '59°', 'Partly Cloudy'),
              ]
            : _savedCities.map((c) => _buildSavedCityTile(c.cityName, c.country, '65°', 'Fair'))),
      ],
    );
  }

  Widget _buildFilterChip(String id, String label, IconData icon) {
    final isSelected = _selectedCategory == id;
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: FilterChip(
        selected: isSelected,
        label: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: isSelected ? Colors.white : AppTheme.primary),
            const SizedBox(width: 6),
            Text(label),
          ],
        ),
        selectedColor: AppTheme.primary,
        backgroundColor: AppTheme.surfaceContainerLow,
        labelStyle: TextStyle(color: isSelected ? Colors.white : AppTheme.onSurface, fontWeight: FontWeight.bold, fontSize: 12),
        onSelected: (val) {
          setState(() => _selectedCategory = id);
        },
      ),
    );
  }

  Widget _buildRecentCard(String city, String country, String desc, String temp, IconData icon) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primary.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: AppTheme.surfaceContainerLow,
                child: Icon(icon, color: AppTheme.primary, size: 20),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(city, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                      const SizedBox(width: 6),
                      Text(country, style: const TextStyle(color: AppTheme.onSurfaceVariant, fontSize: 12)),
                    ],
                  ),
                  Text(desc, style: const TextStyle(color: AppTheme.onSurfaceVariant, fontSize: 12)),
                ],
              ),
            ],
          ),
          Row(
            children: [
              Text(temp, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              const SizedBox(width: 8),
              const Icon(Icons.close, size: 16, color: AppTheme.outline),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHighlightCard(String city, String subtitle, String temp, String condition, String highLow, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primary.withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(city, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16), overflow: TextOverflow.ellipsis),
                    Text(subtitle, style: const TextStyle(color: AppTheme.onSurfaceVariant, fontSize: 10), overflow: TextOverflow.ellipsis),
                  ],
                ),
              ),
              Icon(icon, color: AppTheme.secondary, size: 22),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(temp, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 22)),
                  Text(condition, style: const TextStyle(color: AppTheme.onSurfaceVariant, fontSize: 11)),
                ],
              ),
              Text(highLow, style: const TextStyle(color: AppTheme.primary, fontSize: 10, fontWeight: FontWeight.bold)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSavedCityTile(String city, String country, String temp, String condition) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      elevation: 0,
      color: AppTheme.surfaceContainerLowest,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ListTile(
        leading: const CircleAvatar(backgroundColor: AppTheme.surfaceContainerLow, child: Icon(Icons.location_city, color: AppTheme.primary)),
        title: Text(city, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text('$country • $condition'),
        trailing: Text(temp, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
      ),
    );
  }

  Widget _buildTelemetryCard(IconData icon, String title, String value, String subtitle) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.outlineVariant.withValues(alpha: 0.6)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(icon, color: AppTheme.primary, size: 18),
              const SizedBox(width: 8),
              Text(title, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.outline)),
            ],
          ),
          Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.onSurface)),
          Text(subtitle, style: const TextStyle(fontSize: 11, color: AppTheme.onSurfaceVariant)),
        ],
      ),
    );
  }

  IconData _getIconData(String name) {
    switch (name) {
      case 'wb_sunny5':
      case 'wb_sunny':
        return Icons.wb_sunny;
      case 'partly_cloudy_day':
        return Icons.cloud;
      case 'rainy':
        return Icons.water_drop;
      case 'thunderstorm':
        return Icons.flash_on;
      case 'ac_unit':
        return Icons.ac_unit;
      case 'foggy':
        return Icons.foggy;
      default:
        return Icons.wb_sunny;
    }
  }
}
