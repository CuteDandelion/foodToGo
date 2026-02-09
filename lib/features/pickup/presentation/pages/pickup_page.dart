import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:foodbegood/features/pickup/presentation/bloc/pickup_bloc.dart';
import 'package:foodbegood/shared/services/mock_data_service.dart';
import 'package:foodbegood/config/routes.dart';
import 'package:foodbegood/shared/widgets/animations.dart';
import 'package:foodbegood/shared/widgets/custom_icons.dart' as custom_icons;
import 'package:foodbegood/shared/widgets/animated_progress.dart';

/// Food selection page with category grid
class PickupPage extends StatelessWidget {
  const PickupPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => PickupBloc()..add(const PickupLoadCategories()),
      child: const _PickupPageContent(),
    );
  }
}

class _PickupPageContent extends StatelessWidget {
  const _PickupPageContent();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pick Up My Meal'),
        centerTitle: true,
      ),
      body: BlocConsumer<PickupBloc, PickupState>(
        listener: (context, state) {
          if (state.status == PickupStatus.created) {
            AppHaptics.success();
            // Navigate to QR code page
            context.goQRCode(
              pickupId: state.pickupId!,
              qrData: state.qrCodeData!,
              expiresAt: state.expiresAt!,
              items: state.selectedItems,
            );
          }

          if (state.errorMessage != null) {
            AppHaptics.error();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.errorMessage!),
                backgroundColor: Theme.of(context).colorScheme.error,
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state.status == PickupStatus.initial) {
            return const Center(child: CircularProgressIndicator());
          }

          return Column(
            children: [
              // Header
              FadeInAnimation(
                child: Padding(
                  padding: EdgeInsets.all(16.r),
                  child: Column(
                    children: [
                      Text(
                        'Select Your Items',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        'Choose up to 5 items for your meal',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Theme.of(context).colorScheme.onSurface.withAlpha(153),
                            ),
                      ),
                    ],
                  ),
                ),
              ),

              // Food Container Animation
              _FoodContainer(state: state),

              // Selected Items Count
              if (state.selectedItems.isNotEmpty)
                FadeInAnimation(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${state.selectedItems.length}/5 items selected',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        TextButton.icon(
                          onPressed: () {
                            context.read<PickupBloc>().add(const PickupClearSelection());
                          },
                          icon: const Icon(Icons.clear_all, size: 18),
                          label: const Text('Clear'),
                        ),
                      ],
                    ),
                  ),
                ),

              // Food Categories Grid
              Expanded(
                child: _FoodCategoryGrid(state: state),
              ),

              // Bottom Action Bar
              _BottomActionBar(state: state),
            ],
          );
        },
      ),
    );
  }
}

/// Animated food container widget
class _FoodContainer extends StatelessWidget {
  final PickupState state;

  const _FoodContainer({required this.state});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return FadeInAnimation(
      child: Container(
        margin: EdgeInsets.all(16.r),
        padding: EdgeInsets.all(20.r),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              colorScheme.primary.withAlpha(26),
              colorScheme.primary.withAlpha(10),
            ],
          ),
          borderRadius: BorderRadius.circular(24.r),
          border: Border.all(
            color: colorScheme.primary.withAlpha(51),
            width: 2,
          ),
        ),
        child: Column(
          children: [
            // Container visualization
            Container(
              height: 120.h,
              width: double.infinity,
              decoration: BoxDecoration(
                color: colorScheme.surface,
                borderRadius: BorderRadius.circular(16.r),
                border: Border.all(
                  color: colorScheme.outline.withAlpha(51),
                ),
              ),
              child: state.selectedItems.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            custom_icons.FoodIcons.meals,
                            size: 40.w,
                            color: colorScheme.onSurface.withAlpha(102),
                          ),
                          SizedBox(height: 8.h),
                          Text(
                            'Your container is empty',
                            style: TextStyle(
                              color: colorScheme.onSurface.withAlpha(102),
                            ),
                          ),
                        ],
                      ),
                    )
                  : _AnimatedFoodItems(items: state.selectedItems),
            ),

            SizedBox(height: 12.h),

            // Fill progress with animation
            AnimatedProgressBar(
              progress: state.selectedItems.length / 5,
              height: 8,
              showGlow: true,
            ),
          ],
        ),
      ),
    );
  }
}

/// Animated food items inside container
class _AnimatedFoodItems extends StatelessWidget {
  final List<FoodCategory> items;

  const _AnimatedFoodItems({required this.items});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(12.r),
      child: Wrap(
        spacing: 8.w,
        runSpacing: 8.h,
        alignment: WrapAlignment.center,
        children: items.asMap().entries.map((entry) {
          final index = entry.key;
          final item = entry.value;
          return TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.0, end: 1.0),
            duration: Duration(milliseconds: 300 + (index * 100)),
            curve: Curves.elasticOut,
            builder: (context, value, child) {
              return Transform.scale(
                scale: value,
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 12.w,
                    vertical: 8.h,
                  ),
                  decoration: BoxDecoration(
                    color: _parseColor(item.color).withAlpha(51),
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(
                      color: _parseColor(item.color).withAlpha(128),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        custom_icons.FoodCategoryIcons.getIcon(item.name),
                        size: 20.w,
                        color: _parseColor(item.color),
                      ),
                      SizedBox(width: 4.w),
                      Text(
                        item.name,
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w600,
                          color: _parseColor(item.color),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        }).toList(),
      ),
    );
  }

  Color _parseColor(String hexColor) {
    final hex = hexColor.replaceFirst('#', '');
    return Color(int.parse('FF$hex', radix: 16));
  }
}

/// Food category grid with staggered animation
class _FoodCategoryGrid extends StatelessWidget {
  final PickupState state;

  const _FoodCategoryGrid({required this.state});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: EdgeInsets.all(16.r),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1.3,
        crossAxisSpacing: 12.w,
        mainAxisSpacing: 12.h,
      ),
      itemCount: state.categories.length,
      itemBuilder: (context, index) {
        final category = state.categories[index];
        final count = state.selectedItems.where((c) => c.id == category.id).length;
        final isMaxed = count >= category.maxPerPickup;
        final isAtTotalLimit = state.selectedItems.length >= 5;

        return StaggeredAnimation(
          index: index,
          child: _FoodCategoryCard(
            category: category,
            selectedCount: count,
            isMaxed: isMaxed,
            isAtTotalLimit: isAtTotalLimit,
            onTap: () {
              if (isMaxed || isAtTotalLimit) {
                AppHaptics.error();
                return;
              }
              AppHaptics.lightImpact();
              context.read<PickupBloc>().add(PickupCategorySelected(category));
            },
            onRemove: count > 0
                ? () {
                    AppHaptics.lightImpact();
                    context.read<PickupBloc>().add(PickupCategoryDeselected(category));
                  }
                : null,
          ),
        );
      },
    );
  }
}

/// Individual food category card with press animation
class _FoodCategoryCard extends StatefulWidget {
  final FoodCategory category;
  final int selectedCount;
  final bool isMaxed;
  final bool isAtTotalLimit;
  final VoidCallback onTap;
  final VoidCallback? onRemove;

  const _FoodCategoryCard({
    required this.category,
    required this.selectedCount,
    required this.isMaxed,
    required this.isAtTotalLimit,
    required this.onTap,
    this.onRemove,
  });

  @override
  State<_FoodCategoryCard> createState() => _FoodCategoryCardState();
}

class _FoodCategoryCardState extends State<_FoodCategoryCard> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final categoryColor = _parseColor(widget.category.color);
    final isSelected = widget.selectedCount > 0;
    final isDisabled = widget.isMaxed || widget.isAtTotalLimit;

    return GestureDetector(
      onTapDown: isDisabled ? null : (_) => setState(() => _isPressed = true),
      onTapUp: isDisabled
          ? null
          : (_) {
              setState(() => _isPressed = false);
              widget.onTap();
            },
      onTapCancel: isDisabled ? null : () => setState(() => _isPressed = false),
      child: AnimatedScale(
        scale: _isPressed ? 0.95 : 1.0,
        duration: const Duration(milliseconds: 100),
        curve: Curves.easeOutCubic,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            color: isSelected
                ? categoryColor.withAlpha(51)
                : colorScheme.surface,
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(
              color: isSelected
                  ? categoryColor
                  : isDisabled
                      ? colorScheme.outline.withAlpha(51)
                      : colorScheme.outline.withAlpha(128),
              width: isSelected ? 2 : 1,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: categoryColor.withAlpha(51),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : null,
          ),
          child: Stack(
            children: [
              // Main content
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    custom_icons.AnimatedIconWidget(
                      icon: custom_icons.FoodCategoryIcons.getIcon(widget.category.name),
                      size: 40.w,
                      color: isDisabled
                          ? colorScheme.onSurface.withAlpha(102)
                          : categoryColor,
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      widget.category.name,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: isDisabled
                                ? colorScheme.onSurface.withAlpha(102)
                                : colorScheme.onSurface,
                          ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      'Max ${widget.category.maxPerPickup}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurface.withAlpha(128),
                          ),
                    ),
                  ],
                ),
              ),

              // Selected count badge
              if (isSelected)
                Positioned(
                  top: 8.h,
                  right: 8.w,
                  child: ScaleAnimation(
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 8.w,
                        vertical: 4.h,
                      ),
                      decoration: BoxDecoration(
                        color: categoryColor,
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Text(
                        '${widget.selectedCount}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                ),

              // Remove button
              if (isSelected && widget.onRemove != null)
                Positioned(
                  bottom: 8.h,
                  right: 8.w,
                  child: GestureDetector(
                    onTap: widget.onRemove,
                    child: Container(
                      padding: EdgeInsets.all(4.r),
                      decoration: BoxDecoration(
                        color: colorScheme.error.withAlpha(26),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.remove,
                        size: 16.w,
                        color: colorScheme.error,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Color _parseColor(String hexColor) {
    final hex = hexColor.replaceFirst('#', '');
    return Color(int.parse('FF$hex', radix: 16));
  }
}

/// Bottom action bar with confirm button
class _BottomActionBar extends StatelessWidget {
  final PickupState state;

  const _BottomActionBar({required this.state});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isCreating = state.status == PickupStatus.creating;

    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: Border(
          top: BorderSide(
            color: colorScheme.outline.withAlpha(26),
          ),
        ),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Selected items summary
            if (state.selectedItems.isNotEmpty)
              FadeInAnimation(
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(12.r),
                  margin: EdgeInsets.only(bottom: 12.h),
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Wrap(
                    spacing: 8.w,
                    runSpacing: 8.h,
                    children: state.selectedItems.map((item) {
                      return Chip(
                        avatar: Icon(
                          custom_icons.FoodCategoryIcons.getIcon(item.name),
                          size: 18.w,
                        ),
                        label: Text(item.name),
                        backgroundColor: _parseColor(item.color).withAlpha(26),
                        side: BorderSide(
                          color: _parseColor(item.color).withAlpha(77),
                        ),
                        visualDensity: VisualDensity.compact,
                      );
                    }).toList(),
                  ),
                ),
              ),

            // Confirm button with gradient
            SizedBox(
              width: double.infinity,
              height: 56.h,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                decoration: BoxDecoration(
                  gradient: isCreating || state.selectedItems.isEmpty
                      ? null
                      : const LinearGradient(
                          colors: [Color(0xFF10B981), Color(0xFF059669)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                  color: isCreating || state.selectedItems.isEmpty
                      ? colorScheme.primary.withAlpha(128)
                      : null,
                  borderRadius: BorderRadius.circular(14.r),
                  boxShadow: isCreating || state.selectedItems.isEmpty
                      ? null
                      : [
                          BoxShadow(
                            color: const Color(0xFF10B981).withAlpha(102),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                ),
                child: FilledButton.icon(
                  onPressed: isCreating || state.selectedItems.isEmpty
                      ? null
                      : () {
                          AppHaptics.mediumImpact();
                          context.read<PickupBloc>().add(const PickupCreate());
                        },
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    disabledBackgroundColor: Colors.transparent,
                  ),
                  icon: isCreating
                      ? SizedBox(
                          width: 20.w,
                          height: 20.w,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: colorScheme.onPrimary,
                          ),
                        )
                      : const Icon(Icons.check_circle_outline),
                  label: Text(
                    isCreating
                        ? 'Creating...'
                        : 'Confirm Pickup (${state.selectedItems.length})',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _parseColor(String hexColor) {
    final hex = hexColor.replaceFirst('#', '');
    return Color(int.parse('FF$hex', radix: 16));
  }
}
