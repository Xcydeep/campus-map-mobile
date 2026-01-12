import 'package:flutter/material.dart';

enum CourseViewType {
  timeline,
  list,
}

class CourseListWidget extends StatelessWidget {
  final List<dynamic> courses;
  final CourseViewType viewType;
  final ValueChanged<dynamic> onCoursePressed;
  final ValueChanged<dynamic> onRoomPressed;

  const CourseListWidget({
    super.key,
    required this.courses,
    required this.viewType,
    required this.onCoursePressed,
    required this.onRoomPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: courses.length,
      itemBuilder: (context, index) {
        final course = courses[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            title: Text(course.toString()),
            onTap: () => onCoursePressed(course),
          ),
        );
      },
    );
  }
}
