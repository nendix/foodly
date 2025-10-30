import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/food.dart';
import '../services/storage_service.dart';
import '../widgets/food_card.dart';
import 'add_edit_food_screen.dart';
import 'recipes_screen.dart';

enum SortOption { name, expiryDate, quantity }

class FoodInventoryNotifier extends ChangeNotifier {
  final StorageService _storageService = StorageService();
  List<Food> _foods = [];
  String _searchQuery = '';
  SortOption _sortOption = SortOption.expiryDate;

  List<Food> get foods {
    return _getFilteredAndSortedFoods();
  }

  String get searchQuery => _searchQuery;
  SortOption get sortOption => _sortOption;

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

  void setSortOption(SortOption option) {
    _sortOption = option;
    notifyListeners();
  }

  List<Food> _getFilteredAndSortedFoods() {
    List<Food> filtered = _foods;

    if (_searchQuery.isNotEmpty) {
      filtered = filtered
          .where(
            (food) =>
                food.name.toLowerCase().contains(_searchQuery.toLowerCase()),
          )
          .toList();
    }

    switch (_sortOption) {
      case SortOption.name:
        filtered.sort((a, b) => a.name.compareTo(b.name));
        break;
      case SortOption.expiryDate:
        filtered.sort((a, b) {
          final aExpired = a.isExpired;
          final bExpired = b.isExpired;
          if (aExpired && !bExpired) return -1;
          if (!aExpired && bExpired) return 1;

          final aExpiringSoon = a.expiringSoon;
          final bExpiringSoon = b.expiringSoon;
          if (aExpiringSoon && !bExpiringSoon) return -1;
          if (!aExpiringSoon && bExpiringSoon) return 1;

          if (a.expiryDate != null && b.expiryDate != null) {
            return a.expiryDate!.compareTo(b.expiryDate!);
          }
          return 0;
        });
        break;
      case SortOption.quantity:
        filtered.sort((a, b) => b.quantity.compareTo(a.quantity));
        break;
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
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Food added successfully')),
        );
      }
    }
  }

  void _navigateToEditFood(Food food) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AddEditFoodScreen(food: food)),
    );
    if (result is Food) {
      _notifier.updateFood(result);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Food updated successfully')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _notifier,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Foodly'),
          centerTitle: true,
          elevation: 0,
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
        final hasExpiredItems = foods.any((f) => f.isExpired);
        final hasExpiringItems = foods.any((f) => f.expiringSoon);

        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                spacing: 12,
                children: [
                  SearchBar(
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
                  Row(
                    children: [
                      Expanded(
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            spacing: 8,
                            children: [
                              if (hasExpiredItems)
                                Chip(
                                  label: const Text('Expired Items'),
                                  backgroundColor: Colors.red[100],
                                  labelStyle: TextStyle(color: Colors.red[900]),
                                  avatar: Icon(
                                    Icons.warning,
                                    size: 18,
                                    color: Colors.red[900],
                                  ),
                                ),
                              if (hasExpiringItems)
                                Chip(
                                  label: const Text('Expiring Soon'),
                                  backgroundColor: Colors.orange[100],
                                  labelStyle: TextStyle(
                                    color: Colors.orange[900],
                                  ),
                                  avatar: Icon(
                                    Icons.schedule,
                                    size: 18,
                                    color: Colors.orange[900],
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                      DropdownButton<SortOption>(
                        value: notifier.sortOption,
                        items: [
                          DropdownMenuItem(
                            value: SortOption.expiryDate,
                            child: const Text('Expiry'),
                          ),
                          DropdownMenuItem(
                            value: SortOption.name,
                            child: const Text('Name'),
                          ),
                          DropdownMenuItem(
                            value: SortOption.quantity,
                            child: const Text('Qty'),
                          ),
                        ],
                        onChanged: (option) {
                          if (option != null) {
                            _notifier.setSortOption(option);
                          }
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
            if (foods.isEmpty)
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.inbox_outlined,
                        size: 64,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _searchController.text.isNotEmpty
                            ? 'No foods match your search'
                            : 'No foods added yet',
                        style: Theme.of(
                          context,
                        ).textTheme.bodyLarge?.copyWith(color: Colors.grey),
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
                    return FoodCard(
                      food: food,
                      onEdit: () => _navigateToEditFood(food),
                      onDelete: () {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Delete Food'),
                            content: Text('Remove ${food.name}?'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text('Cancel'),
                              ),
                              TextButton(
                                onPressed: () {
                                  _notifier.deleteFood(food.id);
                                  Navigator.pop(context);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Food deleted'),
                                    ),
                                  );
                                },
                                child: const Text('Delete'),
                              ),
                            ],
                          ),
                        );
                      },
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
