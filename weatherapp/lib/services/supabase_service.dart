import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/city_model.dart';

class SupabaseService {
  static final SupabaseService instance = SupabaseService._init();
  SupabaseService._init();

  bool _isInitialized = false;

  // Initialize Supabase with the provided project URL and publishable key.
  Future<void> initialize() async {
    if (_isInitialized) return;
    try {
      await Supabase.initialize(
        url: 'https://lpnlmfjfoutqiemdvmig.supabase.co',
        publishableKey: 'sb_publishable_ap20LKFOkMisSvY7t-d0ng_vfCE-Shx',
      );
      _isInitialized = true;
      debugPrint('Supabase initialized successfully!');
    } catch (e) {
      debugPrint('Supabase initialization error: $e');
    }
  }

  SupabaseClient? get client {
    try {
      return Supabase.instance.client;
    } catch (e) {
      return null;
    }
  }

  // Sync saved cities to Supabase if connected
  Future<void> syncCitiesToCloud(List<CityLocation> cities) async {
    try {
      final supabase = client;
      if (supabase == null) return;
      
      for (var city in cities) {
        await supabase.from('saved_cities').upsert({
          'city_name': city.cityName,
          'country': city.country,
          'latitude': city.latitude,
          'longitude': city.longitude,
          'is_favourite': city.isFavourite,
        });
      }
    } catch (e) {
      debugPrint('Supabase sync cities error: $e');
    }
  }

  // Fetch saved cities from Supabase cloud database
  Future<List<CityLocation>> fetchCitiesFromCloud() async {
    try {
      final supabase = client;
      if (supabase == null) return [];

      final response = await supabase.from('saved_cities').select();
      final data = response as List<dynamic>;
      return data.map((item) {
        return CityLocation(
          cityName: item['city_name'] ?? '',
          country: item['country'] ?? '',
          latitude: (item['latitude'] as num?)?.toDouble() ?? 0.0,
          longitude: (item['longitude'] as num?)?.toDouble() ?? 0.0,
          isFavourite: item['is_favourite'] ?? false,
        );
      }).toList();
    } catch (e) {
      debugPrint('Supabase fetch cities error: $e');
      return [];
    }
  }
}
