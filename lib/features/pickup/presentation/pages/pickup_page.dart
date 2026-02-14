import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../config/routes.dart';
import '../../../../config/theme.dart';
import '../../../../shared/widgets/shimmer_loading.dart';
import '../../domain/entities/food_item.dart';
import '../bloc/pickup_bloc.dart';
import '../widgets/food_item_card.dart';
import '../widgets/horizontal_category_tabs.dart';

/// Redesigned pickup page with horizontal scrolling categories
class PickupPage extends StatefulWidget {
  const PickupPage({super.key});

  @override
  State<PickupPage> createState() => _PickupPageState();
}

class _PickupPageState extends State<PickupPage> {
  @override
  void initState() {
    super.initState();
    // Load items when page is first shown
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<PickupBloc>().add(const PickupLoadItems());
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return const _PickupPageContent();
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

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, dynamic result) async {
        if (didPop) return;
        final navigator = Navigator.of(context);
        final shouldPop = await _onWillPop();
        if (shouldPop && mounted) {
          navigator.pop();
        }
      },
      child: Container(
        decoration: BoxDecoration(
          gradient: isDark
              ? AppTheme.darkBackgroundGradient
              : AppTheme.lightBackgroundGradient,
        ),
        child: Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () async {
                final navigator = Navigator.of(context);
                final shouldPop = await _onWillPop();
                if (shouldPop && mounted) {
                  navigator.pop();
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
                return const _PickupLoadingState();
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
                  SizedBox(height: 16.h),

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
      ),
    );
  }

  Widget _buildFoodItemsList(BuildContext context, PickupState state) {
    final filteredItems = state.foodItems
        .where((item) => item.category == state.selectedCategory)
        .toList();

    return Container(
      height: 180.h,
      margin: EdgeInsets.symmetric(horizontal: 16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            state.selectedCategory.displayName,
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 12.h),
          Expanded(
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: filteredItems.length,
              itemBuilder: (context, index) {
                final item = filteredItems[index];
                final selectionCount =
                    state.selectedItems.where((i) => i.id == item.id).length;
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
                      context.read<PickupBloc>().add(PickupItemSelected(item));
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
        margin: EdgeInsets.all(16.r),
        padding: EdgeInsets.all(16.r),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(20.r),
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
                    SizedBox(width: 8.w),
                    Text(
                      'Your Container',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                  decoration: BoxDecoration(
                    color: state.selectedItems.length >= 5
                        ? AppTheme.error.withValues(alpha: 0.1)
                        : theme.colorScheme.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  child: Text(
                    '${state.selectedItems.length}/5',
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: state.selectedItems.length >= 5
                          ? AppTheme.error
                          : theme.colorScheme.primary,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16.h),
            if (state.selectedItems.isEmpty)
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.touch_app,
                        size: 48.r,
                        color:
                            theme.colorScheme.onSurface.withValues(alpha: 0.3),
                      ),
                      SizedBox(height: 12.h),
                      Text(
                        'Tap items above to add them',
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: theme.colorScheme.onSurface
                              .withValues(alpha: 0.5),
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              Expanded(
                child: SingleChildScrollView(
                  child: Wrap(
                    spacing: 8.w,
                    runSpacing: 8.h,
                    children: state.selectedItems
                        .asMap()
                        .entries
                        .map((entry) => _SelectedItemTag(
                              emoji: entry.value.category.icon,
                              name: entry.value.name,
                              onRemove: () {
                                HapticFeedback.lightImpact();
                                context.read<PickupBloc>().add(
                                      PickupItemDeselected(entry.value),
                                    );
                              },
                            ))
                        .toList(),
                  ),
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
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
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
                  context
                      .read<PickupBloc>()
                      .add(const PickupNavigateToTimeSlot());
                  context.goTimeSlot();
                }
              : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: theme.colorScheme.primary,
            foregroundColor: theme.colorScheme.onPrimary,
            padding: EdgeInsets.symmetric(vertical: 16.h),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.r),
            ),
            disabledBackgroundColor: Colors.grey[300],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.access_time),
              SizedBox(width: 12.w),
              Text(
                'Select Pickup Time',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(width: 8.w),
              if (canContinue)
                Container(
                  padding: EdgeInsets.all(4.r),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.onPrimary.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    '${state.selectedItems.length}',
                    style: TextStyle(
                      fontSize: 12.sp,
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

/// Loading state for pickup page with shimmer effect
class _PickupLoadingState extends StatelessWidget {
  const _PickupLoadingState();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Category tabs shimmer
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
          child: Row(
            children: List.generate(
              3,
              (index) => Expanded(
                child: Padding(
                  padding: EdgeInsets.only(right: index < 2 ? 8.w : 0),
                  child: const ShimmerListItem(),
                ),
              ),
            ),
          ),
        ),
        SizedBox(height: 16.h),

        // Food items shimmer
        Expanded(
          child: ListView.builder(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            itemCount: 4,
            itemBuilder: (context, index) => const ShimmerListItem(),
          ),
        ),

        // Selected items container shimmer
        Container(
          margin: EdgeInsets.all(16.r),
          padding: EdgeInsets.all(16.r),
          child: const ShimmerMetricCard(),
        ),
      ],
    );
  }
}

/// Pill-shaped tag for a selected food item
class _SelectedItemTag extends StatelessWidget {
  final String emoji;
  final String name;
  final VoidCallback onRemove;

  const _SelectedItemTag({
    required this.emoji,
    required this.name,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(
          color: isDark ? AppTheme.darkBorder : AppTheme.lightBorder,
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(emoji, style: TextStyle(fontSize: 16.sp)),
          SizedBox(width: 6.w),
          Text(
            name,
            style: TextStyle(
              fontSize: 13.sp,
              fontWeight: FontWeight.w500,
              color: theme.colorScheme.onSurface,
            ),
          ),
          SizedBox(width: 6.w),
          GestureDetector(
            onTap: onRemove,
            child: Container(
              width: 18.r,
              height: 18.r,
              decoration: const BoxDecoration(
                color: AppTheme.error,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.close,
                size: 11.r,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
