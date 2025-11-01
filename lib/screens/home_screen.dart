import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/food.dart';
import '../services/storage_service.dart';
import '../widgets/food_card.dart';
import 'add_edit_food_screen.dart';
import 'recipes_screen.dart';

class FoodInventoryNotifier extends ChangeNotifier {
  final StorageService _storageService = StorageService();
  List<Food> _foods = [];
  String _searchQuery = '';

  List<Food> get foods {
    return _getFilteredFoods();
  }

  String get searchQuery => _searchQuery;

  FoodInventoryNotifier() {
    _loadFoods();
  }

  void _loadFoods() {
    _foods = _storageService.getAllFoods();
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  List<Food> _getFilteredFoods() {
    List<Food> filtered = _foods;

    if (_searchQuery.isNotEmpty) {
      filtered = filtered
          .where(
            (food) =>
                food.name.toLowerCase().contains(_searchQuery.toLowerCase()),
          )
          .toList();
    }

    return filtered;
  }

  void addFood(Food food) {
    _storageService.addFood(food);
    _loadFoods();
  }

  void updateFood(Food food) {
    _storageService.updateFood(food);
    _loadFoods();
  }

  void deleteFood(String id) {
    _storageService.deleteFood(id);
    _loadFoods();
  }

  List<Food> searchFoods(String query) {
    return _storageService.searchFoods(query);
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late FoodInventoryNotifier _notifier;
  final TextEditingController _searchController = TextEditingController();
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _notifier = FoodInventoryNotifier();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _notifier.dispose();
    super.dispose();
  }

  void _navigateToAddFood() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddEditFoodScreen()),
    );
    if (result is Food) {
      _notifier.addFood(result);
    }
  }

  void _navigateToEditFood(Food food) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AddEditFoodScreen(food: food)),
    );
    if (result is Food) {
      _notifier.updateFood(result);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _notifier,
      child: Scaffold(
        appBar: AppBar(
          title: Row(
            children: [
              Icon(Icons.restaurant, color: const Color(0xFFFF9800)),
              const SizedBox(width: 8),
              Text(
                'foodly',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: const Color(0xFFFF9800),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          elevation: 0,
          backgroundColor: const Color(0xFF1E1E1E),
        ),
        body: _selectedIndex == 0 ? _buildInventoryView() : _buildRecipesView(),
        bottomNavigationBar: NavigationBar(
          onDestinationSelected: (int index) {
            setState(() {
              _selectedIndex = index;
            });
          },
          selectedIndex: _selectedIndex,
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.inventory_2),
              label: 'Inventory',
            ),
            NavigationDestination(
              icon: Icon(Icons.restaurant),
              label: 'Recipes',
            ),
          ],
        ),
        floatingActionButton: _selectedIndex == 0
            ? FloatingActionButton(
                onPressed: _navigateToAddFood,
                child: const Icon(Icons.add),
              )
            : null,
      ),
    );
  }

  Widget _buildInventoryView() {
    return Consumer<FoodInventoryNotifier>(
      builder: (context, notifier, _) {
        final foods = notifier.foods;

        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: SearchBar(
                controller: _searchController,
                hintText: 'Search foods...',
                leading: const Icon(Icons.search),
                trailing: [
                  if (_searchController.text.isNotEmpty)
                    IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                        _notifier.setSearchQuery('');
                      },
                    ),
                ],
                onChanged: (value) {
                  _notifier.setSearchQuery(value);
                },
              ),
            ),
            if (foods.isEmpty)
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: const Color(0xFF2D2D2D),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.inbox_outlined,
                          size: 64,
                          color: const Color(0xFFFF9800).withValues(alpha: 0.6),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _searchController.text.isNotEmpty
                            ? 'No foods match your search'
                            : 'No foods added yet',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: const Color(0xFFBDBDBD),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Tap the + button to add a food item',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: const Color(0xFF9E9E9E),
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  itemCount: foods.length,
                  itemBuilder: (context, index) {
                    final food = foods[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: FoodCard(
                        key: ValueKey(food.id),
                        food: food,
                        onEdit: () => _navigateToEditFood(food),
                        onDelete: () {
                          _notifier.deleteFood(food.id);
                        },
                      ),
                    );
                  },
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _buildRecipesView() {
    return Consumer<FoodInventoryNotifier>(
      builder: (context, notifier, _) {
        return RecipesScreen(foods: notifier.foods);
      },
    );
  }
}
