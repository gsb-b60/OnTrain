import 'package:flutter/material.dart';
import 'package:ontrain/UI/headerBar.dart';
import 'package:ontrain/controller/ptController.dart';
import 'package:ontrain/core/constrants/app_colors.dart';
import 'package:ontrain/core/constrants/app_size.dart';
import 'package:ontrain/feature/PTDisplay/ptlistpage.dart';
import 'package:provider/provider.dart';

class Specialty {
  final String title;
  final String description;
  final IconData icon;

  Specialty({
    required this.title,
    required this.description,
    required this.icon,
  });
}

class SpecialtiesScreen extends StatelessWidget {
  SpecialtiesScreen({super.key});

  final List<Specialty> specialties = [
    Specialty(
      title: "Weight Loss",
      description: "Programs focused on fat burning and healthy weight reduction.",
      icon: Icons.fitness_center,
    ),
    Specialty(
      title: "Bodybuilding",
      description: "Muscle hypertrophy and strength training for peak physique.",
      icon: Icons.accessibility_new,
    ),
    Specialty(
      title: "Yoga & Flexibility",
      description: "Enhance your range of motion and find inner peace.",
      icon: Icons.self_improvement,
    ),
    Specialty(
      title: "Cardio & HIIT",
      description: "High-intensity interval training to boost heart health.",
      icon: Icons.speed,
    ),
    Specialty(
      title: "Nutrition Coaching",
      description: "Personalized meal plans and dietary guidance.",
      icon: Icons.restaurant,
    ),
    Specialty(
      title: "Rehabilitation",
      description: "Recover from injuries with specialized corrective exercises.",
      icon: Icons.healing,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.light,
      body: Column(
        children: [
          const HeaderBar(title: "Specialties"),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Search Bar
                TextField(
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: 'Search specialties...',
                    fillColor: AppColors.greyAqua,
                    hintStyle: const TextStyle(color: AppColors.aquaTeal),
                    filled: true,
                    prefixIcon: const Icon(Icons.search, color: AppColors.aquaTeal),
                    contentPadding: const EdgeInsets.symmetric(vertical: 15),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide.none,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: AppColors.aquaTeal, width: 1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  "Browse Categories",
                  style: TextStyle(
                    fontSize: AppSizes.medium,
                    fontWeight: FontWeight.bold,
                    color: AppColors.aquaTeal,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 0.85,
              ),
              itemCount: specialties.length,
              itemBuilder: (context, index) {
                final specialty = specialties[index];
                return GestureDetector(
                  onTap: () {
                    context.read<PTController>().filterBySpecialty(
                      specialty.title,
                    );
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PTListpage(
                          initialSpecialty: specialty.title,
                        ),
                      ),
                    );
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.light,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.greyAqua, width: 2),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.black.withValues(alpha: 0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.greyAqua,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            specialty.icon,
                            color: AppColors.aquaTeal,
                            size: 32,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          specialty.title,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: AppColors.black,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          specialty.description,
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          // Primary Action at the bottom
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                height: 50,
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: AppGradients.focus,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: const Center(
                  child: Text(
                    "Back to Home",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.light,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
