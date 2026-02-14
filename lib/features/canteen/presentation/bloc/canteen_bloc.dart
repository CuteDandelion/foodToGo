import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../shared/services/mock_data_service.dart';

// Events
abstract class CanteenEvent extends Equatable {
  const CanteenEvent();

  @override
  List<Object?> get props => [];
}

class CanteenDashboardLoaded extends CanteenEvent {
  const CanteenDashboardLoaded();
}

class CanteenDashboardRefreshed extends CanteenEvent {
  const CanteenDashboardRefreshed();
}

class CanteenRequestApproved extends CanteenEvent {
  final String requestId;
  const CanteenRequestApproved(this.requestId);

  @override
  List<Object?> get props => [requestId];
}

class CanteenRequestRejected extends CanteenEvent {
  final String requestId;
  const CanteenRequestRejected(this.requestId);

  @override
  List<Object?> get props => [requestId];
}

// States
abstract class CanteenState extends Equatable {
  const CanteenState();

  @override
  List<Object?> get props => [];
}

class CanteenInitial extends CanteenState {}

class CanteenLoading extends CanteenState {}

class CanteenLoadSuccess extends CanteenState {
  final CanteenDashboard dashboard;
  final List<CanteenRequest> requests;

  const CanteenLoadSuccess({
    required this.dashboard,
    required this.requests,
  });

  CanteenLoadSuccess copyWith({
    CanteenDashboard? dashboard,
    List<CanteenRequest>? requests,
  }) {
    return CanteenLoadSuccess(
      dashboard: dashboard ?? this.dashboard,
      requests: requests ?? this.requests,
    );
  }

  @override
  List<Object?> get props => [dashboard, requests];
}

class CanteenError extends CanteenState {
  final String message;
  const CanteenError(this.message);

  @override
  List<Object?> get props => [message];
}

// BLoC
class CanteenBloc extends Bloc<CanteenEvent, CanteenState> {
  final MockDataService _mockDataService;

  CanteenBloc({MockDataService? mockDataService})
      : _mockDataService = mockDataService ?? MockDataService(),
        super(CanteenInitial()) {
    on<CanteenDashboardLoaded>(_onLoaded);
    on<CanteenDashboardRefreshed>(_onRefreshed);
    on<CanteenRequestApproved>(_onRequestApproved);
    on<CanteenRequestRejected>(_onRequestRejected);
  }

  Future<void> _onLoaded(
    CanteenDashboardLoaded event,
    Emitter<CanteenState> emit,
  ) async {
    emit(CanteenLoading());
    try {
      final dashboard = _mockDataService.getCanteenDashboard();
      final requests = _mockDataService.getCanteenRequests();
      emit(CanteenLoadSuccess(dashboard: dashboard, requests: requests));
    } catch (e) {
      emit(CanteenError('Failed to load dashboard: $e'));
    }
  }

  Future<void> _onRefreshed(
    CanteenDashboardRefreshed event,
    Emitter<CanteenState> emit,
  ) async {
    try {
      final dashboard = _mockDataService.getCanteenDashboard();
      final requests = _mockDataService.getCanteenRequests();
      emit(CanteenLoadSuccess(dashboard: dashboard, requests: requests));
    } catch (e) {
      emit(CanteenError('Failed to refresh dashboard: $e'));
    }
  }

  Future<void> _onRequestApproved(
    CanteenRequestApproved event,
    Emitter<CanteenState> emit,
  ) async {
    final current = state;
    if (current is! CanteenLoadSuccess) return;
    final updated =
        current.requests.where((r) => r.id != event.requestId).toList();
    emit(current.copyWith(requests: updated));
  }

  Future<void> _onRequestRejected(
    CanteenRequestRejected event,
    Emitter<CanteenState> emit,
  ) async {
    final current = state;
    if (current is! CanteenLoadSuccess) return;
    final updated =
        current.requests.where((r) => r.id != event.requestId).toList();
    emit(current.copyWith(requests: updated));
  }
}
