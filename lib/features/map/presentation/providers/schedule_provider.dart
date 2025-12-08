import 'package:flutter_riverpod/legacy.dart';

class ScheduleState {
  final bool isLoading;
  final String? error;
  final List<dynamic> courses;
  final List<Map<String, dynamic>> roomsWithCourses;
  final List<String> activeFilters;

  const ScheduleState({
    this.isLoading = false,
    this.error,
    this.courses = const [],
    this.roomsWithCourses = const [],
    this.activeFilters = const [],
  });

  ScheduleState copyWith({
    bool? isLoading,
    String? error,
    List<dynamic>? courses,
    List<Map<String, dynamic>>? roomsWithCourses,
    List<String>? activeFilters,
  }) {
    return ScheduleState(
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      courses: courses ?? this.courses,
      roomsWithCourses: roomsWithCourses ?? this.roomsWithCourses,
      activeFilters: activeFilters ?? this.activeFilters,
    );
  }
}

class ScheduleNotifier extends StateNotifier<ScheduleState> {
  ScheduleNotifier() : super(const ScheduleState());

  void loadCoursesForDate(DateTime date) {
    state = state.copyWith(isLoading: true, error: null);
    // TODO: Implémenter le chargement des cours
    state = state.copyWith(isLoading: false);
  }

  void removeFilter(String filter) {
    final newFilters = List<String>.from(state.activeFilters)..remove(filter);
    state = state.copyWith(activeFilters: newFilters);
  }

  void searchCourse(String query) {
    // TODO: Implémenter la recherche de cours
  }
}

final scheduleProvider = StateNotifierProvider<ScheduleNotifier, ScheduleState>(
  (ref) {
    return ScheduleNotifier();
  },
);
