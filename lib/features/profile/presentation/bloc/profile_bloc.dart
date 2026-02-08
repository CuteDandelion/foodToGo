import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:foodbegood/shared/services/mock_data_service.dart';

export 'package:foodbegood/shared/services/mock_data_service.dart' show User, Profile;

part 'profile_event.dart';
part 'profile_state.dart';

/// BLoC for managing user profile
class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final MockDataService _mockDataService;

  ProfileBloc({
    MockDataService? mockDataService,
  })  : _mockDataService = mockDataService ?? MockDataService(),
        super(const ProfileState()) {
    on<ProfileLoad>(_onLoad);
    on<ProfileUpdate>(_onUpdate);
    on<ProfilePhotoUpdate>(_onPhotoUpdate);
    on<ProfileClear>(_onClear);
  }

  Future<void> _onLoad(
    ProfileLoad event,
    Emitter<ProfileState> emit,
  ) async {
    emit(state.copyWith(status: ProfileStatus.loading));

    try {
      // For Phase 1 local-first, use mock user directly
      // In production, this would get current user ID from storage
      final user = _mockDataService.getUserByStudentId('61913042');
      
      if (user == null) {
        emit(state.copyWith(
          status: ProfileStatus.error,
          errorMessage: 'User not found',
        ));
        return;
      }

      // Get dashboard data for stats
      final dashboardData = _mockDataService.getDashboardForUser(user.id);

      emit(state.copyWith(
        status: ProfileStatus.loaded,
        user: user,
        totalMeals: dashboardData.totalMeals,
        monthlyAverage: dashboardData.monthlyAverage,
        currentStreak: dashboardData.currentStreak,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: ProfileStatus.error,
        errorMessage: 'Failed to load profile: $e',
      ));
    }
  }

  Future<void> _onUpdate(
    ProfileUpdate event,
    Emitter<ProfileState> emit,
  ) async {
    emit(state.copyWith(status: ProfileStatus.updating));

    try {
      // In a real app, this would update the backend
      await Future.delayed(const Duration(milliseconds: 500));

      // Update local state
      final updatedUser = User(
        id: state.user!.id,
        studentId: state.user!.studentId,
        passwordHash: state.user!.passwordHash,
        role: state.user!.role,
        profile: Profile(
          firstName: event.firstName ?? state.user!.profile.firstName,
          lastName: event.lastName ?? state.user!.profile.lastName,
          photoPath: state.user!.profile.photoPath,
          department: event.department ?? state.user!.profile.department,
          yearOfStudy: event.yearOfStudy ?? state.user!.profile.yearOfStudy,
        ),
      );

      emit(state.copyWith(
        status: ProfileStatus.loaded,
        user: updatedUser,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: ProfileStatus.error,
        errorMessage: 'Failed to update profile: $e',
      ));
    }
  }

  Future<void> _onPhotoUpdate(
    ProfilePhotoUpdate event,
    Emitter<ProfileState> emit,
  ) async {
    emit(state.copyWith(status: ProfileStatus.updating));

    try {
      // In a real app, this would upload the photo
      await Future.delayed(const Duration(milliseconds: 500));

      // Update local state
      final updatedUser = User(
        id: state.user!.id,
        studentId: state.user!.studentId,
        passwordHash: state.user!.passwordHash,
        role: state.user!.role,
        profile: Profile(
          firstName: state.user!.profile.firstName,
          lastName: state.user!.profile.lastName,
          photoPath: event.photoPath,
          department: state.user!.profile.department,
          yearOfStudy: state.user!.profile.yearOfStudy,
        ),
      );

      emit(state.copyWith(
        status: ProfileStatus.loaded,
        user: updatedUser,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: ProfileStatus.error,
        errorMessage: 'Failed to update photo: $e',
      ));
    }
  }

  void _onClear(
    ProfileClear event,
    Emitter<ProfileState> emit,
  ) {
    emit(const ProfileState());
  }
}
