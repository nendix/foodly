import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/food.dart';
import '../providers/pantry_notifier.dart';
import '../services/navigation_service.dart';
import '../theme/theme.dart';
import '../widgets/food_card.dart';
import '../widgets/empty_state_widget.dart';
import '../widgets/snackbar_helper.dart';
import 'recipes_screen.dart';
import 'tutorial_screen.dart';

class PantryScreen extends StatefulWidget {
  const PantryScreen({super.key});

  @override
  State<PantryScreen> createState() => _PantryScreenState();
}

class _PantryScreenState extends State<PantryScreen> {
  late PantryNotifier _notifier;
  final TextEditingController _searchController = TextEditingController();
  final NavigationService _navigationService = NavigationService();
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _notifier = PantryNotifier();
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
      _notifier.addItem(result);
    }
  }

  void _navigateToEditFood(Food food) async {
    final result = await _navigationService.navigateToEditFood(context, food);
    if (result is Food) {
      _notifier.updateItem(result);
    }
  }

  void _showTutorial() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const TutorialScreen()),
    );
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
              SizedBox(width: AppSpacing.xxs),
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
          actions: [
            IconButton(
              icon: const Icon(Icons.help_outline),
              onPressed: _showTutorial,
            ),
          ],
        ),
        body: Stack(
          children: [
            _selectedIndex == 0 ? _buildPantryView() : _buildRecipesView(),
            if (_selectedIndex == 0)
              Positioned(
                right: AppSpacing.lg,
                bottom: AppSpacing.lg,
                child: FloatingActionButton(
                  onPressed: _navigateToAddFood,
                  child: const Icon(Icons.add),
                ),
              ),
          ],
        ),
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
              label: 'Pantry',
            ),
            NavigationDestination(
              icon: Icon(Icons.restaurant),
              label: 'Recipes',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPantryView() {
    return Consumer<PantryNotifier>(
      builder: (context, notifier, _) {
        final items = notifier.items;

        if (notifier.error != null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            showErrorSnackbar(context, notifier.error!);
          });
        }

        return Column(
          children: [
            Padding(
              padding: EdgeInsets.all(AppSpacing.lg),
              child: SearchBar(
                controller: _searchController,
                hintText: 'Search items...',
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
            if (items.isEmpty)
              EmptyStateWidget(
                icon: Icons.inbox_outlined,
                title: _searchController.text.isNotEmpty
                    ? 'No items match your search'
                    : 'No items added yet',
                subtitle: 'Tap the + button to add an item',
              )
            else
              Expanded(
                child: ListView.builder(
                  padding: EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg,
                    vertical: AppSpacing.sm,
                  ),
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final item = items[index];
                    return Padding(
                      padding: EdgeInsets.only(bottom: AppSpacing.sm),
                      child: FoodCard(
                        key: ValueKey(item.id),
                        food: item,
                        onEdit: () => _navigateToEditFood(item),
                        onDelete: () {
                          final itemName = item.name;
                          _notifier.deleteItem(item.id);
                          showDeleteSnackbar(
                            context,
                            itemName,
                            () => _notifier.restoreLastDeletedItem(),
                          );
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
    return Consumer<PantryNotifier>(
      builder: (context, notifier, _) {
        return RecipesScreen(foods: notifier.items);
      },
    );
  }
}
