import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/category.dart';
import '../providers/transaction_provider.dart';
import '../services/category_service.dart';
import '../theme/app_theme.dart';
import 'add_category_screen.dart';

class ManageCategoriesScreen extends StatefulWidget {
  const ManageCategoriesScreen({super.key});

  @override
  State<ManageCategoriesScreen> createState() => _ManageCategoriesScreenState();
}

class _ManageCategoriesScreenState extends State<ManageCategoriesScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final CategoryService _categoryService = CategoryService();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _addCategory(String type) async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => AddCategoryScreen(type: type),
      ),
    );

    if (result == true && mounted) {
      // Categories already reloaded in AddCategoryScreen
    }
  }

  Future<void> _editCategory(Category category) async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => AddCategoryScreen(
          type: category.type,
          existingCategory: category,
        ),
      ),
    );

    if (result == true && mounted) {
      // Categories already reloaded in AddCategoryScreen
    }
  }

  Future<void> _deleteCategory(Category category) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.cardDark,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Supprimer la catégorie?'),
        content: Text(
          'Êtes-vous sûr de vouloir supprimer "${category.name}"?\n\nLes transactions associées ne seront pas supprimées.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.expenseRed,
            ),
            child: const Text('Supprimer', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      setState(() => _isLoading = true);
      try {
        await _categoryService.deleteCategory(category.id);
        
        if (mounted) {
          await context.read<TransactionProvider>().loadCategories();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Catégorie supprimée'),
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
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gérer les catégories'),
        backgroundColor: AppTheme.primaryDark,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppTheme.incomeGreen,
          indicatorWeight: 3,
          labelColor: AppTheme.incomeGreen,
          unselectedLabelColor: AppTheme.textMuted,
          tabs: const [
            Tab(
              icon: Icon(Icons.arrow_upward),
              text: 'Dépenses',
            ),
            Tab(
              icon: Icon(Icons.arrow_downward),
              text: 'Revenus',
            ),
          ],
        ),
      ),
      body: Stack(
        children: [
          Consumer<TransactionProvider>(
            builder: (context, provider, _) {
              return TabBarView(
                controller: _tabController,
                children: [
                  _buildCategoryList(provider.expenseCategories, 'expense'),
                  _buildCategoryList(provider.incomeCategories, 'income'),
                ],
              );
            },
          ),
          if (_isLoading)
            Container(
              color: Colors.black54,
              child: const Center(
                child: CircularProgressIndicator(color: AppTheme.incomeGreen),
              ),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          final type = _tabController.index == 0 ? 'expense' : 'income';
          _addCategory(type);
        },
        backgroundColor: AppTheme.incomeGreen,
        icon: const Icon(Icons.add, color: Colors.black),
        label: const Text(
          'Ajouter',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  Widget _buildCategoryList(List<Category> categories, String type) {
    if (categories.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: AppTheme.surfaceDark,
                borderRadius: BorderRadius.circular(25),
              ),
              child: Icon(
                type == 'expense' ? Icons.category_outlined : Icons.account_balance_wallet_outlined,
                size: 50,
                color: AppTheme.textMuted,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Aucune catégorie',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: AppTheme.textSecondary,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Appuyez sur "Ajouter" pour créer\nvotre première catégorie',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.textMuted,
                  ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: categories.length,
      itemBuilder: (context, index) {
        final category = categories[index];
        final color = _parseColor(category.color);

        return Dismissible(
          key: Key(category.id),
          direction: DismissDirection.endToStart,
          background: Container(
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 24),
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: AppTheme.expenseRed.withAlpha(50),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.delete_outline, color: AppTheme.expenseRed, size: 28),
                SizedBox(height: 4),
                Text(
                  'Supprimer',
                  style: TextStyle(color: AppTheme.expenseRed, fontSize: 12),
                ),
              ],
            ),
          ),
          confirmDismiss: (_) async {
            await _deleteCategory(category);
            return false;
          },
          child: GestureDetector(
            onTap: () => _editCategory(category),
            child: Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.cardDark,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: color.withAlpha(50)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: color.withAlpha(38),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(
                      _getCategoryIcon(category.icon),
                      color: color,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          category.name,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Appuyez pour modifier',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: AppTheme.textMuted,
                              ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceDark,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.edit_outlined,
                      color: AppTheme.textMuted,
                      size: 20,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Color _parseColor(String hexColor) {
    try {
      return Color(int.parse(hexColor.replaceFirst('#', '0xFF')));
    } catch (e) {
      return AppTheme.accentBlue;
    }
  }

  IconData _getCategoryIcon(String iconName) {
    final icons = {
      'restaurant': Icons.restaurant,
      'directions_car': Icons.directions_car,
      'shopping_bag': Icons.shopping_bag,
      'receipt': Icons.receipt,
      'medical_services': Icons.medical_services,
      'sports_esports': Icons.sports_esports,
      'school': Icons.school,
      'more_horiz': Icons.more_horiz,
      'work': Icons.work,
      'laptop': Icons.laptop,
      'trending_up': Icons.trending_up,
      'card_giftcard': Icons.card_giftcard,
      'replay': Icons.replay,
      'category': Icons.category,
      'home': Icons.home,
      'flight': Icons.flight,
      'pets': Icons.pets,
      'fitness_center': Icons.fitness_center,
      'movie': Icons.movie,
      'music_note': Icons.music_note,
      'phone': Icons.phone,
      'wifi': Icons.wifi,
      'electric_bolt': Icons.electric_bolt,
      'water_drop': Icons.water_drop,
      'savings': Icons.savings,
      'attach_money': Icons.attach_money,
    };
    return icons[iconName] ?? Icons.category;
  }
}
