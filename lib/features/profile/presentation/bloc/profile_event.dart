part of 'profile_bloc.dart';

/// Events for ProfileBloc
abstract class ProfileEvent extends Equatable {
  const ProfileEvent();

  @override
  List<Object?> get props => [];
}

/// Load profile data
class ProfileLoad extends ProfileEvent {
  const ProfileLoad();
}

/// Update profile information
class ProfileUpdate extends ProfileEvent {
  final String? firstName;
  final String? lastName;
  final String? department;
  final int? yearOfStudy;

  const ProfileUpdate({
    this.firstName,
    this.lastName,
    this.department,
    this.yearOfStudy,
  });

  @override
  List<Object?> get props => [
        firstName,
        lastName,
        department,
        yearOfStudy,
      ];
}

/// Update profile photo
class ProfilePhotoUpdate extends ProfileEvent {
  final String? photoPath;

  const ProfilePhotoUpdate(this.photoPath);

  @override
  List<Object?> get props => [photoPath];
}

/// Load meal history for profile user
class ProfileMealHistoryLoad extends ProfileEvent {
  final String? userId;

  const ProfileMealHistoryLoad({this.userId});

  @override
  List<Object?> get props => [userId];
}

/// Clear profile state
class ProfileClear extends ProfileEvent {
  const ProfileClear();
}
