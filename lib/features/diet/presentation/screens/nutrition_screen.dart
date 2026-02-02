import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/responsive.dart';
import '../../data/models/fruit_model.dart'; // ✅ Import your new model
import 'fruit_detail_screen.dart';

class NutritionScreen extends StatefulWidget {
  const NutritionScreen({super.key});

  @override
  State<NutritionScreen> createState() => _NutritionScreenState();
}

class _NutritionScreenState extends State<NutritionScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";

  // ✅ USE THE MODEL DATA instead of hardcoded maps
  // (Ensure 'defaultFruits' is defined in fruit_model.dart as we discussed)
  final List<FruitModel> allFruits = defaultFruits;

  List<FruitModel> get _filteredFruits {
    if (_searchQuery.isEmpty) return allFruits;
    return allFruits
        .where((fruit) =>
        fruit.name.toLowerCase().contains(_searchQuery.toLowerCase()))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final responsive = Responsive(context);
    const Color healthyGlowColor = Color(0xFF2ED573);

    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      body: Stack(
        children: [
          // 1. TOP GLOW DECORATION
          Positioned(
            top: -responsive.hp(15),
            right: -responsive.wp(25),
            child: Container(
              width: responsive.wp(90),
              height: responsive.wp(90),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: healthyGlowColor.withValues(alpha:0.2),
                    blurRadius: 120,
                    spreadRadius: 40,
                  ),
                ],
              ),
            ),
          ),

          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 2. HEADER SECTION
              SafeArea(
                bottom: false,
                child: Padding(
                  padding: EdgeInsets.fromLTRB(
                      responsive.wp(6),
                      responsive.hp(1),
                      responsive.wp(6),
                      0
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Back Button
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          padding: EdgeInsets.all(responsive.wp(3)),
                          decoration: BoxDecoration(
                            color: AppColors.cardSurface,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: Colors.white10),
                          ),
                          child: Icon(
                              Icons.arrow_back_ios_new_rounded,
                              color: Colors.white,
                              size: responsive.hp(2.2)
                          ),
                        ),
                      ),
                      SizedBox(height: responsive.hp(3)),

                      // Title
                      Text(
                        "Nutrition &\nHealthy Food",
                        style: TextStyle(
                          fontSize: responsive.hp(3.8),
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          height: 1.1,
                          fontFamily: "Plus Jakarta Sans",
                        ),
                      ),
                      SizedBox(height: responsive.hp(3)),

                      // Search Bar
                      Container(
                        height: responsive.hp(6.5),
                        decoration: BoxDecoration(
                          color: AppColors.cardSurface,
                          borderRadius: BorderRadius.circular(22),
                          border: Border.all(color: Colors.white.withValues(alpha:0.05)),
                        ),
                        child: TextField(
                          controller: _searchController,
                          onChanged: (value) => setState(() => _searchQuery = value),
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: responsive.hp(1.8)
                          ),
                          decoration: InputDecoration(
                            hintText: "Search fruits...",
                            hintStyle: TextStyle(
                                color: Colors.white38,
                                fontSize: responsive.hp(1.8)
                            ),
                            prefixIcon: Icon(
                                Icons.search,
                                color: healthyGlowColor,
                                size: responsive.hp(2.5)
                            ),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(
                                horizontal: responsive.wp(5),
                                vertical: responsive.hp(1.5)
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(height: responsive.hp(3)),

              // 3. FRUIT LIST
              Expanded(
                child: ListView.separated(
                  padding: EdgeInsets.fromLTRB(
                      responsive.wp(6),
                      0,
                      responsive.wp(6),
                      responsive.hp(5)
                  ),
                  itemCount: _filteredFruits.length,
                  separatorBuilder: (_, __) => SizedBox(height: responsive.hp(2)),
                  itemBuilder: (context, index) {
                    final fruit = _filteredFruits[index];
                    return _FruitCard(
                      responsive: responsive,
                      // ✅ PASSING DATA FROM MODEL
                      name: fruit.name,
                      calories: "${fruit.caloriesPer100g}",
                      imageUrl: fruit.imageUrl,
                      accentColor: fruit.color,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => FruitDetailScreen(fruit: fruit),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// Helper Widget (Same as before)
class _FruitCard extends StatelessWidget {
  final Responsive responsive;
  final String name;
  final String calories;
  final String imageUrl;
  final Color accentColor;
  final VoidCallback onTap;

  const _FruitCard({
    required this.responsive,
    required this.name,
    required this.calories,
    required this.imageUrl,
    required this.accentColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: responsive.hp(14),
        decoration: BoxDecoration(
          color: AppColors.cardSurface,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha:0.25),
              blurRadius: 15,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                    responsive.wp(6),
                    responsive.hp(2),
                    responsive.wp(2),
                    responsive.hp(2)
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      name,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: responsive.hp(2.4),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: responsive.hp(1)),
                    Row(
                      children: [
                        Icon(
                            Icons.local_fire_department_rounded,
                            size: responsive.hp(2),
                            color: accentColor
                        ),
                        SizedBox(width: responsive.wp(1)),
                        Text(
                          "$calories kcal",
                          style: TextStyle(
                            color: accentColor,
                            fontWeight: FontWeight.bold,
                            fontSize: responsive.hp(1.8),
                          ),
                        ),
                        Text(
                          " / 100g",
                          style: TextStyle(
                            color: Colors.white38,
                            fontSize: responsive.hp(1.5),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            Container(
              width: responsive.wp(32),
              height: double.infinity,
              decoration: BoxDecoration(
                color: accentColor.withValues(alpha:0.15),
                borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(28),
                  bottomRight: Radius.circular(28),
                  bottomLeft: Radius.circular(60),
                  topLeft: Radius.circular(15),
                ),
              ),
              child: Padding(
                padding: EdgeInsets.all(responsive.wp(3)),
                child: Hero(
                  tag: name,
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      image: DecorationImage(
                        image: AssetImage(imageUrl),   // ✅ NEW
                        fit: BoxFit.cover,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: accentColor.withValues(alpha:0.4),
                          blurRadius: 12,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}