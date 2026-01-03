import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/category.dart';

class CategoryService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // Get all categories for current user
  Future<List<Category>> getCategories() async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) throw Exception('User not authenticated');

    final response = await _supabase
        .from('categories')
        .select()
        .eq('user_id', userId)
        .order('name');

    return (response as List)
        .map((json) => Category.fromJson(json))
        .toList();
  }

  // Get categories by type (income or expense)
  Future<List<Category>> getCategoriesByType(String type) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) throw Exception('User not authenticated');

    final response = await _supabase
        .from('categories')
        .select()
        .eq('user_id', userId)
        .eq('type', type)
        .order('name');

    return (response as List)
        .map((json) => Category.fromJson(json))
        .toList();
  }

  // Get expense categories
  Future<List<Category>> getExpenseCategories() async {
    return getCategoriesByType('expense');
  }

  // Get income categories
  Future<List<Category>> getIncomeCategories() async {
    return getCategoriesByType('income');
  }

  // Create a new category
  Future<Category> createCategory({
    required String name,
    required String type,
    required String icon,
    required String color,
  }) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) throw Exception('User not authenticated');

    final response = await _supabase.from('categories').insert({
      'user_id': userId,
      'name': name,
      'type': type,
      'icon': icon,
      'color': color,
    }).select().single();

    return Category.fromJson(response);
  }

  // Update a category
  Future<Category> updateCategory({
    required String id,
    String? name,
    String? icon,
    String? color,
  }) async {
    final updates = <String, dynamic>{};
    if (name != null) updates['name'] = name;
    if (icon != null) updates['icon'] = icon;
    if (color != null) updates['color'] = color;

    final response = await _supabase
        .from('categories')
        .update(updates)
        .eq('id', id)
        .select()
        .single();

    return Category.fromJson(response);
  }

  // Delete a category
  Future<void> deleteCategory(String id) async {
    await _supabase.from('categories').delete().eq('id', id);
  }
}

