import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/responsive.dart';
import '../data/datasources/gym_services.dart';

class EventsScreen extends StatefulWidget {
  const EventsScreen({super.key});

  @override
  State<EventsScreen> createState() => _EventsScreenState();
}

class _EventsScreenState extends State<EventsScreen> {
  final GymService _gymService = GymService();
  List<Map<String, dynamic>> _gyms = [];
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _loadGyms();
  }

  Future<void> _loadGyms() async {
    final gyms = await _gymService.fetchNearbyGyms();
    if (mounted) {
      setState(() {
        _gyms = gyms;
        _isLoading = false;
        if (gyms.isEmpty) {
          _errorMessage = "No gyms found nearby.";
        }
      });
    }
  }

  // 1. Open Navigation to a Specific Gym (Card Click)
  Future<void> _openNavigation(double lat, double lng) async {
    final Uri url = Uri.parse("google.navigation:q=$lat,$lng");
    _launchUri(url);
  }

  // 2. Open "Bird's Eye View" of All Gyms (Top Button Click)
  Future<void> _openFullMapView() async {
    // This searches "gyms" near the user's current location in the Maps App
    final Uri url = Uri.parse("https://www.google.com/maps/search/gyms/");
    _launchUri(url);
  }

  Future<void> _launchUri(Uri url) async {
    try {
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      } else {
        // Fallback for generic web link if native app fails
        await launchUrl(url, mode: LaunchMode.platformDefault);
      }
    } catch (e) {
      debugPrint("Error launching map: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final responsive = Responsive(context);

    // Modern Green Gradient
    const gradientColors = [
      Color(0xFF4CAF50), // Lighter Green
      Color(0xFF2E7D32), // Darker Green
    ];

    return Scaffold(
      backgroundColor: gradientColors.last,
      body: Stack(
        children: [
          // --- DECORATIVE BACKGROUND ---
          Container(
            height: responsive.hp(40),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: gradientColors,
              ),
            ),
          ),
          Positioned(
            top: -responsive.hp(10),
            right: -responsive.wp(20),
            child: Container(
              width: responsive.wp(60),
              height: responsive.wp(60),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
            ),
          ),

          // --- MAIN CONTENT ---
          SafeArea(
            bottom: false,
            child: Column(
              children: [
                // HEADER
                Padding(
                  padding: EdgeInsets.symmetric(
                      horizontal: responsive.wp(6), vertical: responsive.hp(2)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Navigation Row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _GlassIconButton(
                            icon: Icons.arrow_back,
                            onTap: () => Navigator.pop(context),
                            responsive: responsive,
                          ),
                          // ✅ FUNCTIONAL MAP BUTTON
                          _GlassTagButton(
                            text: "View on Map",
                            icon: Icons.map_outlined,
                            responsive: responsive,
                            onTap: _openFullMapView, // Now clickable!
                          ),
                        ],
                      ),

                      SizedBox(height: responsive.hp(3)),

                      // Title Block
                      Row(
                        children: [
                          Icon(Icons.near_me_rounded,
                              color: Colors.white70, size: responsive.hp(2)),
                          SizedBox(width: responsive.wp(2)),
                          Text(
                            "Current Location",
                            style: TextStyle(
                                color: Colors.white70,
                                fontSize: responsive.hp(1.6),
                                fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                      SizedBox(height: responsive.hp(0.5)),
                      Text(
                        "Nearby Gyms",
                        style: TextStyle(
                          fontSize: responsive.hp(3.8),
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          height: 1.1,
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: responsive.hp(1)),

                // LIST SECTION
                Expanded(
                  child: Container(
                    width: double.infinity,
                    decoration: const BoxDecoration(
                      color: AppColors.scaffoldBackground,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(35),
                        topRight: Radius.circular(35),
                      ),
                    ),
                    child: _isLoading
                        ? const Center(
                            child: CircularProgressIndicator(
                                color: Color(0xFF4CAF50)))
                        : _gyms.isEmpty
                            ? _buildEmptyState(responsive)
                            : ListView.separated(
                                padding: EdgeInsets.fromLTRB(
                                    responsive.wp(6),
                                    responsive.hp(4),
                                    responsive.wp(6),
                                    responsive.hp(5)),
                                itemCount: _gyms.length,
                                separatorBuilder: (context, index) =>
                                    SizedBox(height: responsive.hp(2)),
                                itemBuilder: (context, index) {
                                  final gym = _gyms[index];
                                  return _GymCard(
                                    gym: gym,
                                    responsive: responsive,
                                    onTap: () {
                                      if (gym['lat'] != null &&
                                          gym['lng'] != null) {
                                        _openNavigation(gym['lat'], gym['lng']);
                                      }
                                    },
                                  );
                                },
                              ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(Responsive responsive) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.location_off_rounded,
              size: responsive.hp(8), color: Colors.white24),
          SizedBox(height: responsive.hp(2)),
          Text(_errorMessage,
              style: const TextStyle(color: AppColors.textSecondary)),
        ],
      ),
    );
  }
}

// --- COMPONENTS ---

class _GymCard extends StatelessWidget {
  final Map<String, dynamic> gym;
  final Responsive responsive;
  final VoidCallback onTap;

  const _GymCard(
      {required this.gym, required this.responsive, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: responsive.hp(14),
        decoration: BoxDecoration(
          color: AppColors.cardSurface,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 10,
              offset: const Offset(0, 5),
            )
          ],
        ),
        child: Row(
          children: [
            // IMAGE
            Hero(
              tag: gym['name'],
              child: Container(
                width: responsive.wp(30),
                height: double.infinity,
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(24),
                      bottomLeft: Radius.circular(24)),
                ),
                child: ClipRRect(
                  borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(24),
                      bottomLeft: Radius.circular(24)),
                  child: Image.network(
                    gym['image'],
                    fit: BoxFit.cover,
                    cacheWidth: 300,
                    frameBuilder: (context, child, frame, wasSync) {
                      if (wasSync) return child;
                      return AnimatedOpacity(
                        opacity: frame == null ? 0 : 1,
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeOut,
                        child: child,
                      );
                    },
                    errorBuilder: (_, __, ___) => Container(
                        color: Colors.grey[850],
                        child: const Icon(Icons.fitness_center,
                            color: Colors.white24)),
                  ),
                ),
              ),
            ),

            // INFO
            Expanded(
              child: Padding(
                padding: EdgeInsets.all(responsive.wp(3.5)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Top
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                gym['name'],
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: responsive.hp(1.9),
                                    fontWeight: FontWeight.bold),
                              ),
                              SizedBox(height: responsive.hp(0.4)),
                              Text(
                                gym['address'],
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                    color: Colors.white54,
                                    fontSize: responsive.hp(1.4)),
                              ),
                            ],
                          ),
                        ),
                        Row(
                          children: [
                            Icon(Icons.star_rounded,
                                color: Colors.amber, size: responsive.hp(1.8)),
                            SizedBox(width: responsive.wp(1)),
                            Text(gym['rating'],
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: responsive.hp(1.5),
                                    fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ],
                    ),

                    // Bottom
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            _StatusDot(
                                isOpen: gym['isOpen'], responsive: responsive),
                            SizedBox(width: responsive.wp(3)),
                            Icon(Icons.directions_run,
                                color: Colors.white38,
                                size: responsive.hp(1.6)),
                            SizedBox(width: responsive.wp(1)),
                            Text(gym['distance'],
                                style: TextStyle(
                                    color: Colors.white54,
                                    fontSize: responsive.hp(1.5))),
                          ],
                        ),
                        CircleAvatar(
                          radius: responsive.hp(1.8),
                          backgroundColor: const Color(0xFF4CAF50),
                          child: Icon(Icons.navigation_rounded,
                              color: Colors.white, size: responsive.hp(1.8)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// --- HELPER BUTTONS ---

class _GlassIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final Responsive responsive;

  const _GlassIconButton(
      {required this.icon, required this.onTap, required this.responsive});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(responsive.wp(2.5)),
        decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.15),
            shape: BoxShape.circle),
        child: Icon(icon, color: Colors.white, size: responsive.hp(2.5)),
      ),
    );
  }
}

// ✅ NEW CLICKABLE BUTTON
class _GlassTagButton extends StatelessWidget {
  final String text;
  final IconData icon;
  final Responsive responsive;
  final VoidCallback onTap; // Action trigger

  const _GlassTagButton({
    required this.text,
    required this.icon,
    required this.responsive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
            horizontal: responsive.wp(3), vertical: responsive.hp(0.8)),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.white, size: responsive.hp(2)),
            SizedBox(width: responsive.wp(1.5)),
            Text(
              text,
              style: TextStyle(
                color: Colors.white,
                fontSize: responsive.hp(1.5),
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusDot extends StatelessWidget {
  final bool isOpen;
  final Responsive responsive;

  const _StatusDot({required this.isOpen, required this.responsive});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
          horizontal: responsive.wp(2), vertical: responsive.hp(0.4)),
      decoration: BoxDecoration(
        color: (isOpen ? Colors.green : Colors.red).withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        isOpen ? "Open" : "Closed",
        style: TextStyle(
            color: isOpen ? Colors.greenAccent : Colors.redAccent,
            fontSize: responsive.hp(1.2),
            fontWeight: FontWeight.bold),
      ),
    );
  }
}
