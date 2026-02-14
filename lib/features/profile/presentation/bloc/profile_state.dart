part of 'profile_bloc.dart';

/// Status of profile operations
enum ProfileStatus {
  initial,
  loading,
  loaded,
  updating,
  error,
}

/// State for ProfileBloc
class ProfileState extends Equatable {
  final ProfileStatus status;
  final User? user;
  final int totalMeals;
  final double monthlyAverage;
  final int currentStreak;
  final List<Map<String, dynamic>> mealHistory;
  final bool isMealHistoryLoading;
  final String? mealHistoryErrorMessage;
  final String? errorMessage;

  const ProfileState({
    this.status = ProfileStatus.initial,
    this.user,
    this.totalMeals = 0,
    this.monthlyAverage = 0,
    this.currentStreak = 0,
    this.mealHistory = const [],
    this.isMealHistoryLoading = false,
    this.mealHistoryErrorMessage,
    this.errorMessage,
  });

  ProfileState copyWith({
    ProfileStatus? status,
    User? user,
    int? totalMeals,
    double? monthlyAverage,
    int? currentStreak,
    List<Map<String, dynamic>>? mealHistory,
    bool? isMealHistoryLoading,
    String? mealHistoryErrorMessage,
    String? errorMessage,
  }) {
    return ProfileState(
      status: status ?? this.status,
      user: user ?? this.user,
      totalMeals: totalMeals ?? this.totalMeals,
      monthlyAverage: monthlyAverage ?? this.monthlyAverage,
      currentStreak: currentStreak ?? this.currentStreak,
      mealHistory: mealHistory ?? this.mealHistory,
      isMealHistoryLoading: isMealHistoryLoading ?? this.isMealHistoryLoading,
      mealHistoryErrorMessage: mealHistoryErrorMessage,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        status,
        user,
        totalMeals,
        monthlyAverage,
        currentStreak,
        mealHistory,
        isMealHistoryLoading,
        mealHistoryErrorMessage,
        errorMessage,
      ];
}
