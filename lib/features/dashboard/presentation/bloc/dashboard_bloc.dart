import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../shared/services/mock_data_service.dart';

// Events
abstract class DashboardEvent extends Equatable {
  const DashboardEvent();

  @override
  List<Object?> get props => [];
}

class DashboardLoaded extends DashboardEvent {
  final String? userId;
  const DashboardLoaded({this.userId});

  @override
  List<Object?> get props => [userId];
}

class DashboardRefreshed extends DashboardEvent {
  const DashboardRefreshed();
}

// States
abstract class DashboardState extends Equatable {
  const DashboardState();

  @override
  List<Object?> get props => [];
}

class DashboardInitial extends DashboardState {}

class DashboardLoading extends DashboardState {}

class DashboardLoadSuccess extends DashboardState {
  final DashboardData data;
  const DashboardLoadSuccess(this.data);

  @override
  List<Object?> get props => [data];
}

class DashboardError extends DashboardState {
  final String message;
  const DashboardError(this.message);

  @override
  List<Object?> get props => [message];
}

// BLoC
class DashboardBloc extends Bloc<DashboardEvent, DashboardState> {
  final MockDataService _mockDataService;

  DashboardBloc({MockDataService? mockDataService})
      : _mockDataService = mockDataService ?? MockDataService(),
        super(DashboardInitial()) {
    on<DashboardLoaded>(_onLoaded);
    on<DashboardRefreshed>(_onRefreshed);
  }

  Future<void> _onLoaded(
    DashboardLoaded event,
    Emitter<DashboardState> emit,
  ) async {
    emit(DashboardLoading());
    try {
      final data = _mockDataService.getDashboardForUser(event.userId ?? '1');
      emit(DashboardLoadSuccess(data));
    } catch (e) {
      emit(DashboardError('Failed to load dashboard: $e'));
    }
  }

  Future<void> _onRefreshed(
    DashboardRefreshed event,
    Emitter<DashboardState> emit,
  ) async {
    emit(DashboardLoading());
    try {
      final data = _mockDataService.getDashboardForUser('1');
      emit(DashboardLoadSuccess(data));
    } catch (e) {
      emit(DashboardError('Failed to refresh dashboard: $e'));
    }
  }
}
