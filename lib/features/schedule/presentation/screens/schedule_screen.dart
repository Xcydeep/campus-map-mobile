import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_text_styles.dart';
import '../../../../routes/app_router.dart';
import '../../../map/presentation/providers/schedule_provider.dart';
import '../../../map/presentation/widgets/course_list_widget.dart';
import '../../../map/presentation/widgets/schedule_filter_widget.dart';
import '../../../map/presentation/widgets/calendar_header_widget.dart';

class ScheduleScreen extends ConsumerStatefulWidget {
  const ScheduleScreen({super.key});

  @override
  ConsumerState<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends ConsumerState<ScheduleScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  DateTime selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    
    // Charger les cours du jour
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(scheduleProvider.notifier).loadCoursesForDate(selectedDate);
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheduleState = ref.watch(scheduleProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Planning des cours'),
        leading: IconButton(
          onPressed: () => context.navigateBack(),
          icon: const Icon(Icons.arrow_back),
        ),
        actions: [
          IconButton(
            onPressed: () {
              _showFilterBottomSheet(context);
            },
            icon: const Icon(Icons.filter_list),
          ),
          IconButton(
            onPressed: () {
              _showSearchDialog(context);
            },
            icon: const Icon(Icons.search),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Par horaire'),
            Tab(text: 'Par salle'),
          ],
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textSecondary,
          indicatorColor: AppColors.primary,
        ),
      ),
      body: Column(
        children: [
          // En-tête du calendrier
          CalendarHeaderWidget(
            selectedDate: selectedDate,
            onDateChanged: (date) {
              setState(() {
                selectedDate = date;
              });
              ref.read(scheduleProvider.notifier).loadCoursesForDate(date);
            },
          ),

          // Filtres actifs
          if (scheduleState.activeFilters.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: ScheduleFilterWidget(
                filters: scheduleState.activeFilters,
                onFilterRemoved: (filter) {
                  ref.read(scheduleProvider.notifier).removeFilter(filter);
                },
              ),
            ),

          // Contenu des tabs
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildTimelineView(scheduleState),
                _buildRoomView(scheduleState),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // Ouvrir la vue carte avec les salles
          context.navigateBack();
          // TODO: Centrer la carte sur les salles de cours
        },
        icon: const Icon(Icons.map),
        label: const Text('Voir sur la carte'),
        backgroundColor: AppColors.primary,
      ),
    );
  }

  Widget _buildTimelineView(ScheduleState scheduleState) {
    if (scheduleState.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (scheduleState.error != null) {
      return _buildError(scheduleState.error!);
    }

    if (scheduleState.courses.isEmpty) {
      return _buildEmptyState('Aucun cours prévu pour cette date');
    }

    return CourseListWidget(
      courses: scheduleState.courses,
      viewType: CourseViewType.timeline,
      onCoursePressed: (course) {
        context.navigateToCourseDetail(course.id);
      },
      onRoomPressed: (course) {
        // Naviguer vers la carte et centrer sur la salle
        context.navigateBack();
        // TODO: Centrer la carte sur la salle
      },
    );
  }

  Widget _buildRoomView(ScheduleState scheduleState) {
    if (scheduleState.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (scheduleState.error != null) {
      return _buildError(scheduleState.error!);
    }

    if (scheduleState.roomsWithCourses.isEmpty) {
      return _buildEmptyState('Aucune salle disponible');
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: scheduleState.roomsWithCourses.length,
      itemBuilder: (context, index) {
        final roomData = scheduleState.roomsWithCourses[index];
        return _buildRoomCard(roomData);
      },
    );
  }

  Widget _buildRoomCard(Map<String, dynamic> roomData) {
    final room = roomData['room'];
    final courses = roomData['courses'] as List;
    final currentCourse = courses.firstWhere(
      (c) => c.isOngoing(),
      orElse: () => null,
    );

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: () {
          // Naviguer vers la carte et centrer sur cette salle
          context.navigateBack();
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.meeting_room,
                      color: AppColors.primary,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          room['name'],
                          style: AppTextStyles.h6,
                        ),
                        Text(
                          '${courses.length} cours aujourd\'hui',
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  _buildRoomStatusBadge(currentCourse),
                ],
              ),
              if (currentCourse != null) ...[
                const SizedBox(height: 12),
                const Divider(),
                const SizedBox(height: 12),
                Text(
                  'En cours maintenant:',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  currentCourse.name,
                  style: AppTextStyles.body.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  currentCourse.formatTime(),
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRoomStatusBadge(dynamic currentCourse) {
    final status = currentCourse != null ? 'Occupée' : 'Libre';
    final color = currentCourse != null 
        ? AppColors.roomOccupied 
        : AppColors.roomAvailable;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        status,
        style: AppTextStyles.roomStatus,
      ),
    );
  }

  Widget _buildEmptyState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.calendar_today_outlined,
            size: 64,
            color: AppColors.textHint,
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: AppTextStyles.body.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildError(String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: AppColors.error,
          ),
          const SizedBox(height: 16),
          Text(
            'Une erreur est survenue',
            style: AppTextStyles.h6,
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              error,
              style: AppTextStyles.body.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              ref.read(scheduleProvider.notifier).loadCoursesForDate(selectedDate);
            },
            icon: const Icon(Icons.refresh),
            label: const Text('Réessayer'),
          ),
        ],
      ),
    );
  }

  void _showFilterBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Filtrer les cours',
              style: AppTextStyles.h5,
            ),
            const SizedBox(height: 20),
            _buildFilterOption('Niveau', Icons.school),
            _buildFilterOption('Département', Icons.business),
            _buildFilterOption('Type de cours', Icons.category),
            _buildFilterOption('Enseignant', Icons.person),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Appliquer'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterOption(String title, IconData icon) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primary),
      title: Text(title, style: AppTextStyles.body),
      trailing: const Icon(Icons.chevron_right),
      onTap: () {
        // TODO: Implémenter la sélection de filtre
      },
    );
  }

  void _showSearchDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Rechercher un cours'),
        content: TextField(
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Nom du cours, code, enseignant...',
            prefixIcon: Icon(Icons.search),
          ),
          onSubmitted: (value) {
            ref.read(scheduleProvider.notifier).searchCourse(value);
            Navigator.pop(context);
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
        ],
      ),
    );
  }
}