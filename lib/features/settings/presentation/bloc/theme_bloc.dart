import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../config/constants.dart';
import '../../../../core/storage/storage_manager.dart';

// Events
abstract class ThemeEvent extends Equatable {
  const ThemeEvent();

  @override
  List<Object?> get props => [];
}

class ThemeInitialized extends ThemeEvent {}

class ThemeToggled extends ThemeEvent {}

class ThemeChanged extends ThemeEvent {
  final bool isDarkMode;

  const ThemeChanged(this.isDarkMode);

  @override
  List<Object?> get props => [isDarkMode];
}

// States
class ThemeState extends Equatable {
  final bool isDarkMode;

  const ThemeState({this.isDarkMode = false});

  @override
  List<Object?> get props => [isDarkMode];
}

// BLoC
class ThemeBloc extends Bloc<ThemeEvent, ThemeState> {
  final StorageManager _storage;

  ThemeBloc({StorageManager? storage})
      : _storage = storage ?? StorageManager(),
        super(const ThemeState()) {
    on<ThemeInitialized>(_onInitialized);
    on<ThemeToggled>(_onToggled);
    on<ThemeChanged>(_onChanged);

    add(ThemeInitialized());
  }

  Future<void> _onInitialized(
    ThemeInitialized event,
    Emitter<ThemeState> emit,
  ) async {
    final isDarkMode = await _storage.prefs.getBool(AppConstants.storageKeyTheme) ?? false;
    emit(ThemeState(isDarkMode: isDarkMode));
  }

  Future<void> _onToggled(
    ThemeToggled event,
    Emitter<ThemeState> emit,
  ) async {
    final newState = !state.isDarkMode;
    await _storage.prefs.setBool(AppConstants.storageKeyTheme, newState);
    emit(ThemeState(isDarkMode: newState));
  }

  Future<void> _onChanged(
    ThemeChanged event,
    Emitter<ThemeState> emit,
  ) async {
    await _storage.prefs.setBool(AppConstants.storageKeyTheme, event.isDarkMode);
    emit(ThemeState(isDarkMode: event.isDarkMode));
  }
}
