import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../../config/routes.dart';
import '../bloc/pickup_bloc.dart';

/// Page for selecting pickup time slot
class TimeSlotSelectionPage extends StatelessWidget {
  const TimeSlotSelectionPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF1B5E20) : const Color(0xFFE8F5E9),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Select Pickup Time',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      body: BlocConsumer<PickupBloc, PickupState>(
        listener: (context, state) {
          if (state.status == PickupStatus.submitted) {
            // Navigate to confirmation page
            context.goConfirmation();
          }
        },
        builder: (context, state) {
          return Column(
            children: [
              // Selected items summary
              _buildSelectedItemsSummary(context, state),
              
              // Calendar
              _buildCalendar(context, state),
              
              // Time slots
              Expanded(
                child: _buildTimeSlots(context, state),
              ),
              
              // Confirm button
              _buildConfirmButton(context, state),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSelectedItemsSummary(BuildContext context, PickupState state) {
    final theme = Theme.of(context);
    
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
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
            children: [
              Icon(
                Icons.shopping_bag_outlined,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Text(
                'Selected Items (${state.selectedItems.length})',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: state.selectedItems.map((item) {
              return Chip(
                label: Text(
                  item.name,
                  style: const TextStyle(fontSize: 12),
                ),
                backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.1),
                side: BorderSide.none,
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildCalendar(BuildContext context, PickupState state) {
    final theme = Theme.of(context);
    final now = DateTime.now();
    final days = List.generate(7, (index) => now.add(Duration(days: index)));

    return Container(
      height: 100,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: days.length,
        itemBuilder: (context, index) {
          final day = days[index];
          final isSelected = state.availableTimeSlots.isNotEmpty && 
              state.availableTimeSlots.first.date.day == day.day;
          final isToday = day.day == now.day;

          return GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              context.read<PickupBloc>().add(PickupLoadTimeSlots(day));
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 70,
              margin: const EdgeInsets.only(right: 12),
              decoration: BoxDecoration(
                color: isSelected
                    ? theme.colorScheme.primary
                    : isToday
                        ? theme.colorScheme.primary.withValues(alpha: 0.1)
                        : theme.cardColor,
                borderRadius: BorderRadius.circular(16),
                border: isToday && !isSelected
                    ? Border.all(color: theme.colorScheme.primary, width: 2)
                    : null,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    DateFormat('EEE').format(day),
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: isSelected
                          ? theme.colorScheme.onPrimary
                          : theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${day.day}',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: isSelected
                          ? theme.colorScheme.onPrimary
                          : theme.colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 4),
                  if (isToday)
                    Text(
                      'Today',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: isSelected
                            ? theme.colorScheme.onPrimary
                            : theme.colorScheme.primary,
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTimeSlots(BuildContext context, PickupState state) {
    final theme = Theme.of(context);

    if (state.status == PickupStatus.loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.availableTimeSlots.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.access_time,
              size: 48,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
            ),
            const SizedBox(height: 16),
            Text(
              'No available time slots',
              style: TextStyle(
                fontSize: 16,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      margin: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Available Times',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                childAspectRatio: 2.5,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemCount: state.availableTimeSlots.length,
              itemBuilder: (context, index) {
                final slot = state.availableTimeSlots[index];
                final isSelected = state.selectedTimeSlot?.id == slot.id;
                final isAvailable = slot.isAvailable;

                return GestureDetector(
                  onTap: isAvailable
                      ? () {
                          HapticFeedback.lightImpact();
                          context
                              .read<PickupBloc>()
                              .add(PickupTimeSlotSelected(slot));
                        }
                      : null,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? theme.colorScheme.primary
                          : isAvailable
                              ? theme.cardColor
                              : Colors.grey[300],
                      borderRadius: BorderRadius.circular(12),
                      border: isSelected
                          ? null
                          : Border.all(
                              color: isAvailable
                                  ? theme.colorScheme.primary.withValues(alpha: 0.3)
                                  : Colors.grey[400]!,
                            ),
                    ),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            slot.time,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: isSelected
                                  ? theme.colorScheme.onPrimary
                                  : isAvailable
                                      ? theme.colorScheme.onSurface
                                      : Colors.grey[600],
                            ),
                          ),
                          if (isAvailable && slot.availableSpots != null)
                            Text(
                              '${slot.availableSpots} spots',
                              style: TextStyle(
                                fontSize: 10,
                                color: isSelected
                                    ? theme.colorScheme.onPrimary.withValues(alpha: 0.8)
                                    : theme.colorScheme.onSurface.withValues(alpha: 0.6),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConfirmButton(BuildContext context, PickupState state) {
    final theme = Theme.of(context);
    final canConfirm = state.selectedTimeSlot != null;

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
          onPressed: canConfirm
              ? () {
                  HapticFeedback.mediumImpact();
                  context.read<PickupBloc>().add(const PickupSubmitToCanteen());
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
              if (state.status == PickupStatus.confirming)
                const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              else
                const Icon(Icons.send),
              const SizedBox(width: 12),
              Text(
                state.status == PickupStatus.confirming
                    ? 'Sending to Canteen...'
                    : 'Send to Canteen',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
