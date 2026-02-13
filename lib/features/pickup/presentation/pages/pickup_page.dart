import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../config/routes.dart';
import '../../domain/entities/food_item.dart';
import '../bloc/pickup_bloc.dart';
import '../widgets/food_item_card.dart';
import '../widgets/horizontal_category_tabs.dart';

/// Redesigned pickup page with horizontal scrolling categories
class PickupPage extends StatelessWidget {
  const PickupPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => PickupBloc()..add(const PickupLoadItems()),
      child: const _PickupPageContent(),
    );
  }
}

class _PickupPageContent extends StatefulWidget {
  const _PickupPageContent();

  @override
  State<_PickupPageContent> createState() => _PickupPageContentState();
}

class _PickupPageContentState extends State<_PickupPageContent> {
  Future<bool> _onWillPop() async {
    final state = context.read<PickupBloc>().state;
    if (state.selectedItems.isNotEmpty) {
      return await showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Discard Selection?'),
              content: const Text('Your food selection will be lost.'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('CANCEL'),
                ),
                FilledButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: const Text('DISCARD'),
                ),
              ],
            ),
          ) ??
          false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        backgroundColor: isDark ? const Color(0xFF1B5E20) : const Color(0xFFE8F5E9),
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () async {
              if (await _onWillPop()) {
                if (mounted) {
                  Navigator.pop(context);
                }
              }
            },
          ),
          title: const Text(
            'Pick Up My Meal',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          centerTitle: true,
        ),
        body: BlocConsumer<PickupBloc, PickupState>(
          listener: (context, state) {
            if (state.errorMessage != null) {
              HapticFeedback.vibrate();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.errorMessage!),
                  backgroundColor: theme.colorScheme.error,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            }
          },
          builder: (context, state) {
            if (state.status == PickupStatus.initial ||
                state.status == PickupStatus.loading) {
              return const Center(child: CircularProgressIndicator());
            }

            return Column(
              children: [
                // Category tabs
                HorizontalCategoryTabs(
                  selectedCategory: state.selectedCategory,
                  onCategorySelected: (category) {
                    HapticFeedback.lightImpact();
                    context
                        .read<PickupBloc>()
                        .add(PickupCategoryChanged(category));
                  },
                ),
                const SizedBox(height: 16),

                // Food items list (horizontal scrolling)
                _buildFoodItemsList(context, state),

                // Selected items container
                _buildSelectedItemsContainer(context, state),

                // Continue button
                _buildContinueButton(context, state),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildFoodItemsList(BuildContext context, PickupState state) {
    final filteredItems = state.foodItems
        .where((item) => item.category == state.selectedCategory)
        .toList();

    return Container(
      height: 180,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            state.selectedCategory.displayName,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: filteredItems.length,
              itemBuilder: (context, index) {
                final item = filteredItems[index];
                final selectionCount = state.selectedItems
                    .where((i) => i.id == item.id)
                    .length;
                final isSelected = selectionCount > 0;

                return FoodItemCard(
                  foodItem: item,
                  isSelected: isSelected,
                  selectionCount: selectionCount > 0 ? selectionCount : null,
                  onTap: () {
                    if (isSelected && selectionCount >= 2) {
                      // Deselect if at max
                      context
                          .read<PickupBloc>()
                          .add(PickupItemDeselected(item));
                    } else {
                      // Select
                      context
                          .read<PickupBloc>()
                          .add(PickupItemSelected(item));
                    }
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSelectedItemsContainer(BuildContext context, PickupState state) {
    final theme = Theme.of(context);

    return Expanded(
      child: Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.shopping_basket,
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Your Container',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: state.selectedItems.length >= 5
                        ? Colors.red.withValues(alpha: 0.1)
                        : theme.colorScheme.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${state.selectedItems.length}/5',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: state.selectedItems.length >= 5
                          ? Colors.red
                          : theme.colorScheme.primary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (state.selectedItems.isEmpty)
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.touch_app,
                        size: 48,
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Tap items above to add them',
                        style: TextStyle(
                          fontSize: 14,
                          color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Tap items here to remove them',
                        style: TextStyle(
                          fontSize: 12,
                          color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              Expanded(
                child: ListView.builder(
                  itemCount: state.selectedItems.length,
                  itemBuilder: (context, index) {
                    final item = state.selectedItems[index];
                    return Dismissible(
                      key: Key('${item.id}_$index'),
                      direction: DismissDirection.endToStart,
                      onDismissed: (_) {
                        HapticFeedback.lightImpact();
                        context
                            .read<PickupBloc>()
                            .add(PickupItemDeselected(item));
                      },
                      background: Container(
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 16),
                        decoration: BoxDecoration(
                          color: Colors.red.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.delete,
                          color: Colors.red,
                        ),
                      ),
                      child: ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Center(
                            child: Text(
                              item.category.icon,
                              style: const TextStyle(fontSize: 20),
                            ),
                          ),
                        ),
                        title: Text(
                          item.name,
                          style: const TextStyle(fontWeight: FontWeight.w500),
                        ),
                        subtitle: Text(
                          item.category.displayName,
                          style: TextStyle(
                            fontSize: 12,
                            color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                          ),
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.close, size: 20),
                          onPressed: () {
                            HapticFeedback.lightImpact();
                            context
                                .read<PickupBloc>()
                                .add(PickupItemDeselected(item));
                          },
                        ),
                        onTap: () {
                          HapticFeedback.lightImpact();
                          context
                              .read<PickupBloc>()
                              .add(PickupItemDeselected(item));
                        },
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildContinueButton(BuildContext context, PickupState state) {
    final theme = Theme.of(context);
    final canContinue = state.selectedItems.isNotEmpty;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: ElevatedButton(
          onPressed: canContinue
              ? () {
                  HapticFeedback.mediumImpact();
                  context.read<PickupBloc>().add(const PickupNavigateToTimeSlot());
                  context.goTimeSlot();
                }
              : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: theme.colorScheme.primary,
            foregroundColor: theme.colorScheme.onPrimary,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            disabledBackgroundColor: Colors.grey[300],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.access_time),
              const SizedBox(width: 12),
              Text(
                'Select Pickup Time',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 8),
              if (canContinue)
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.onPrimary.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    '${state.selectedItems.length}',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onPrimary,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
