import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/food.dart';
import '../providers/food_inventory_notifier.dart';
import '../services/navigation_service.dart';
import '../theme/theme.dart';
import '../widgets/food_card.dart';
import '../widgets/empty_state_widget.dart';
import 'recipes_screen.dart';

class InventoryScreen extends StatefulWidget {
  const InventoryScreen({super.key});

  @override
  State<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen> {
  late FoodInventoryNotifier _notifier;
  final TextEditingController _searchController = TextEditingController();
  final NavigationService _navigationService = NavigationService();
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
    final result = await _navigationService.navigateToAddFood(context);
    if (result is Food) {
      _notifier.addFood(result);
    }
  }

  void _navigateToEditFood(Food food) async {
    final result = await _navigationService.navigateToEditFood(context, food);
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
              Icon(Icons.restaurant, color: AppColors.accentOrange),
              const SizedBox(width: 8),
              Text(
                'foodly',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: AppColors.accentOrange,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          elevation: 0,
          backgroundColor: AppColors.surfaceDark,
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
              EmptyStateWidget(searchQuery: _searchController.text)
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
