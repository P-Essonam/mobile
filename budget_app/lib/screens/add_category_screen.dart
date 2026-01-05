import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/category.dart';
import '../providers/transaction_provider.dart';
import '../services/category_service.dart';
import '../theme/app_theme.dart';

class AddCategoryScreen extends StatefulWidget {
  final String type; // 'expense' ou 'income'
  final Category? existingCategory;

  const AddCategoryScreen({
    super.key,
    required this.type,
    this.existingCategory,
  });

  @override
  State<AddCategoryScreen> createState() => _AddCategoryScreenState();
}

class _AddCategoryScreenState extends State<AddCategoryScreen> {
  final _nameController = TextEditingController();
  final CategoryService _categoryService = CategoryService();
  
  String _selectedIcon = 'category';
  String _selectedColor = '#FF6B6B';
  bool _isSubmitting = false;

  static const List<Map<String, dynamic>> availableIcons = [
    {'name': 'restaurant', 'icon': Icons.restaurant, 'label': 'Restaurant'},
    {'name': 'directions_car', 'icon': Icons.directions_car, 'label': 'Transport'},
    {'name': 'shopping_bag', 'icon': Icons.shopping_bag, 'label': 'Shopping'},
    {'name': 'receipt', 'icon': Icons.receipt, 'label': 'Factures'},
    {'name': 'medical_services', 'icon': Icons.medical_services, 'label': 'Santé'},
    {'name': 'sports_esports', 'icon': Icons.sports_esports, 'label': 'Loisirs'},
    {'name': 'school', 'icon': Icons.school, 'label': 'Éducation'},
    {'name': 'work', 'icon': Icons.work, 'label': 'Travail'},
    {'name': 'laptop', 'icon': Icons.laptop, 'label': 'Tech'},
    {'name': 'trending_up', 'icon': Icons.trending_up, 'label': 'Investissement'},
    {'name': 'card_giftcard', 'icon': Icons.card_giftcard, 'label': 'Cadeau'},
    {'name': 'home', 'icon': Icons.home, 'label': 'Maison'},
    {'name': 'flight', 'icon': Icons.flight, 'label': 'Voyage'},
    {'name': 'pets', 'icon': Icons.pets, 'label': 'Animaux'},
    {'name': 'fitness_center', 'icon': Icons.fitness_center, 'label': 'Sport'},
    {'name': 'movie', 'icon': Icons.movie, 'label': 'Cinéma'},
    {'name': 'music_note', 'icon': Icons.music_note, 'label': 'Musique'},
    {'name': 'phone', 'icon': Icons.phone, 'label': 'Téléphone'},
    {'name': 'wifi', 'icon': Icons.wifi, 'label': 'Internet'},
    {'name': 'electric_bolt', 'icon': Icons.electric_bolt, 'label': 'Électricité'},
    {'name': 'water_drop', 'icon': Icons.water_drop, 'label': 'Eau'},
    {'name': 'savings', 'icon': Icons.savings, 'label': 'Épargne'},
    {'name': 'attach_money', 'icon': Icons.attach_money, 'label': 'Argent'},
    {'name': 'more_horiz', 'icon': Icons.more_horiz, 'label': 'Autres'},
  ];

  static const List<String> availableColors = [
    '#FF6B6B', // Red
    '#4ECDC4', // Teal
    '#A855F7', // Purple
    '#FFA726', // Orange
    '#00D09C', // Green
    '#3B82F6', // Blue
    '#EC4899', // Pink
    '#22C55E', // Lime
    '#F59E0B', // Amber
    '#6366F1', // Indigo
    '#14B8A6', // Cyan
    '#EF4444', // Red bright
  ];

  @override
  void initState() {
    super.initState();
    if (widget.existingCategory != null) {
      _nameController.text = widget.existingCategory!.name;
      _selectedIcon = widget.existingCategory!.icon;
      _selectedColor = widget.existingCategory!.color;
    } else {
      _selectedColor = widget.type == 'expense' ? '#FF6B6B' : '#00D09C';
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Color _parseColor(String hexColor) {
    try {
      return Color(int.parse(hexColor.replaceFirst('#', '0xFF')));
    } catch (e) {
      return AppTheme.accentBlue;
    }
  }

  IconData _getIconData(String iconName) {
    for (var item in availableIcons) {
      if (item['name'] == iconName) {
        return item['icon'];
      }
    }
    return Icons.category;
  }

  Future<void> _submit() async {
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez entrer un nom pour la catégorie'),
          backgroundColor: AppTheme.expenseRed,
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      if (widget.existingCategory != null) {
        // Modifier
        await _categoryService.updateCategory(
          id: widget.existingCategory!.id,
          name: _nameController.text.trim(),
          icon: _selectedIcon,
          color: _selectedColor,
        );
      } else {
        // Créer
        await _categoryService.createCategory(
          name: _nameController.text.trim(),
          type: widget.type,
          icon: _selectedIcon,
          color: _selectedColor,
        );
      }

      if (mounted) {
        await context.read<TransactionProvider>().loadCategories();
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.existingCategory != null 
                ? 'Catégorie modifiée' 
                : 'Catégorie ajoutée'),
            backgroundColor: AppTheme.incomeGreen,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: $e'),
            backgroundColor: AppTheme.expenseRed,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.existingCategory != null;
    final selectedColor = _parseColor(_selectedColor);
    final isExpense = widget.type == 'expense';

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(isEditing 
            ? 'Modifier la catégorie' 
            : 'Nouvelle catégorie ${isExpense ? "dépense" : "revenu"}'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Preview Card
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    selectedColor.withAlpha(50),
                    selectedColor.withAlpha(20),
                  ],
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: selectedColor.withAlpha(100)),
              ),
              child: Column(
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: selectedColor.withAlpha(50),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Icon(
                      _getIconData(_selectedIcon),
                      color: selectedColor,
                      size: 40,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _nameController.text.isEmpty 
                        ? 'Nom de la catégorie' 
                        : _nameController.text,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: selectedColor.withAlpha(50),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      isExpense ? 'Dépense' : 'Revenu',
                      style: TextStyle(
                        color: selectedColor,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Name Field
            Text(
              'Nom de la catégorie',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _nameController,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                hintText: 'Ex: Restaurant, Salaire...',
                filled: true,
                fillColor: AppTheme.surfaceDark,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: selectedColor, width: 2),
                ),
                prefixIcon: Icon(Icons.label_outline, color: selectedColor),
              ),
              textCapitalization: TextCapitalization.sentences,
            ),
            const SizedBox(height: 32),

            // Icon Selection
            Text(
              'Choisir une icône',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 6,
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
              ),
              itemCount: availableIcons.length,
              itemBuilder: (context, index) {
                final iconData = availableIcons[index];
                final isSelected = _selectedIcon == iconData['name'];

                return GestureDetector(
                  onTap: () {
                    setState(() => _selectedIcon = iconData['name']);
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? selectedColor.withAlpha(50)
                          : AppTheme.surfaceDark,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected ? selectedColor : Colors.transparent,
                        width: 2,
                      ),
                    ),
                    child: Icon(
                      iconData['icon'],
                      color: isSelected ? selectedColor : AppTheme.textMuted,
                      size: 24,
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 32),

            // Color Selection
            Text(
              'Choisir une couleur',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: availableColors.map((colorHex) {
                final color = _parseColor(colorHex);
                final isSelected = _selectedColor == colorHex;

                return GestureDetector(
                  onTap: () {
                    setState(() => _selectedColor = colorHex);
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isSelected ? Colors.white : Colors.transparent,
                        width: 3,
                      ),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: color.withAlpha(150),
                                blurRadius: 12,
                                spreadRadius: 2,
                              ),
                            ]
                          : null,
                    ),
                    child: isSelected
                        ? const Icon(Icons.check, color: Colors.white, size: 24)
                        : null,
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 40),

            // Submit Button
            ElevatedButton(
              onPressed: _isSubmitting ? null : _submit,
              style: ElevatedButton.styleFrom(
                backgroundColor: selectedColor,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: _isSubmitting
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Text(
                      isEditing ? 'Modifier la catégorie' : 'Ajouter la catégorie',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

