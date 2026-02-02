import 'dart:convert';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;

class GymService {
  // 🔴 KEEP YOUR EXISTING KEY
  static const String _apiKey = '';

  /// Helper to get current GPS location with permission checks
  Future<Position?> getCurrentLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return null;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          return null;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        return null;
      }

      return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
    } catch (e) {
      return null;
    }
  }

  /// Fetches gyms using the Google Places API (New)
  Future<List<Map<String, dynamic>>> fetchNearbyGyms() async {
    try {
      final position = await getCurrentLocation();

      if (position == null) {
        return [];
      }

      // 1. New API Endpoint
      final url =
          Uri.parse('https://places.googleapis.com/v1/places:searchNearby');

      // 2. Request Body
      final body = jsonEncode({
        "includedTypes": ["gym"],
        "maxResultCount": 20,
        "locationRestriction": {
          "circle": {
            "center": {
              "latitude": position.latitude,
              "longitude": position.longitude
            },
            "radius": 5000.0 // 5km radius
          }
        }
      });

      // 3. Headers
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'X-Goog-Api-Key': _apiKey,
          // Requesting specific fields to save data/cost
          'X-Goog-FieldMask':
              'places.displayName,places.formattedAddress,places.location,places.rating,places.photos,places.regularOpeningHours'
        },
        body: body,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // Check if 'places' exists in the response
        if (!data.containsKey('places')) {
          return [];
        }

        final places = data['places'] as List;

        return places.map((place) {
          final location = place['location'];
          final double placeLat = location['latitude'];
          final double placeLng = location['longitude'];

          // Calculate Distance from user
          final distanceMeters = Geolocator.distanceBetween(
              position.latitude, position.longitude, placeLat, placeLng);
          final distanceKm = (distanceMeters / 1000).toStringAsFixed(1);

          // Get Image (Google Photo or Fallback)
          String image =
              "https://images.unsplash.com/photo-1534438327276-14e5300c3a48?auto=format&fit=crop&w=600&q=80";
          if (place['photos'] != null && (place['photos'] as List).isNotEmpty) {
            final photoName = place['photos'][0]['name'];
            // Construct the photo URL
            image =
                'https://places.googleapis.com/v1/$photoName/media?key=$_apiKey&maxHeightPx=400&maxWidthPx=400';
          }

          return {
            "name": place['displayName']?['text'] ?? "Unknown Gym",
            "distance": "$distanceKm km",
            "rating": (place['rating'] ?? 0.0).toString(),
            "address": place['formattedAddress'] ?? "Address not available",
            "image": image,
            "isOpen": place['regularOpeningHours']?['openNow'] ?? false,
            // Lat/Lng needed for opening the map
            "lat": placeLat,
            "lng": placeLng,
          };
        }).toList();
      } else {
        return [];
      }
    } catch (e) {
      return [];
    }
  }
}
