import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../state/crm_state.dart';
import '../models/crm_models.dart';

class TasksScreen extends ConsumerStatefulWidget {
  const TasksScreen({super.key});

  @override
  ConsumerState<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends ConsumerState<TasksScreen> {
  int _selectedDayIndex = 1; // Tuesday (Today)

  final List<String> _weekDays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  final List<int> _dates = [9, 10, 11, 12, 13, 14, 15];

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(crmProvider);

    final pendingTasks = state.tasks.where((t) => !t.done).toList();
    final completedTasks = state.tasks.where((t) => t.done).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F1EB),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 24.0, bottom: 8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Task Queue',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF1A1A1A),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${pendingTasks.length} pending · ${completedTasks.length} completed',
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFF64748B),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),

          // Horizontal calendar list
          Padding(
            padding: const EdgeInsets.only(bottom: 12.0, top: 4.0),
            child: SizedBox(
              height: 64,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                itemCount: _weekDays.length,
                itemBuilder: (context, index) {
                  final isSelected = index == _selectedDayIndex;
                  final isToday = index == 1; // Tuesday
                  final dayName = _weekDays[index];
                  final dayDate = _dates[index];

                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4.0),
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedDayIndex = index;
                        });
                      },
                      child: Container(
                        width: 48,
                        decoration: BoxDecoration(
                          color: isSelected ? const Color(0xFF1A1A1A) : Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: Colors.black.withOpacity(0.06)),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.02),
                              blurRadius: 4,
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              dayName.toUpperCase(),
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: isSelected ? const Color(0xFFF5F1EB) : const Color(0xFF475569),
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '$dayDate',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w900,
                                color: isSelected ? const Color(0xFFF5F1EB) : const Color(0xFF1A1A1A),
                              ),
                            ),
                            if (isToday && !isSelected) ...[
                              const SizedBox(height: 2),
                              Container(
                                width: 4,
                                height: 4,
                                decoration: const BoxDecoration(
                                  color: Color(0xFFF43F5E),
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),

          // Tasks List
          Expanded(
            child: state.tasks.isEmpty
                ? const Center(
                    child: Text(
                      'No tasks for this day',
                      style: TextStyle(
                        color: Color(0xFF94A3B8),
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  )
                : ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                    children: [
                      // Pending Tasks list
                      if (pendingTasks.isNotEmpty)
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: pendingTasks.length,
                          itemBuilder: (context, index) {
                            final task = pendingTasks[index];
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 10.0),
                              child: _buildTaskCard(task),
                            );
                          },
                        ),

                      // Completed Title header
                      if (completedTasks.isNotEmpty) ...[
                        const Padding(
                          padding: EdgeInsets.only(left: 4.0, top: 12.0, bottom: 8.0),
                          child: Text(
                            'COMPLETED',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1.0,
                              color: Color(0xFF64748B),
                            ),
                          ),
                        ),
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: completedTasks.length,
                          itemBuilder: (context, index) {
                            final task = completedTasks[index];
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 10.0),
                              child: _buildTaskCard(task),
                            );
                          },
                        ),
                      ],
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildTaskCard(Task task) {
    Color scBg = const Color(0xFFF1F5F9);
    Color scText = const Color(0xFF475569);
    if (task.stage == 'NEW') {
      scBg = const Color(0xFFDBEAFE);
      scText = const Color(0xFF1D4ED8);
    } else if (task.stage == 'CONTACTED') {
      scBg = const Color(0xFFE0E7FF);
      scText = const Color(0xFF4338CA);
    } else if (task.stage == 'APPLIED') {
      scBg = const Color(0xFFF3E8FF);
      scText = const Color(0xFF7E22CE);
    } else if (task.stage == 'MEETING SCHEDULED' || task.stage == 'VERIFICATION PENDING') {
      scBg = const Color(0xFFFEF3C7);
      scText = const Color(0xFFD97706);
    }

    return Opacity(
      opacity: task.done ? 0.5 : 1.0,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.black.withOpacity(0.06)),
        ),
        padding: const EdgeInsets.all(16.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Checked indicator button
            GestureDetector(
              onTap: () {
                ref.read(crmProvider.notifier).toggleTask(task.id);
              },
              child: Container(
                width: 20,
                height: 20,
                margin: const EdgeInsets.only(top: 2),
                decoration: BoxDecoration(
                  color: task.done ? const Color(0xFF10B981) : Colors.white,
                  border: Border.all(
                    color: task.done ? const Color(0xFF10B981) : const Color(0xFFCBD5E1),
                    width: 2,
                  ),
                  borderRadius: BorderRadius.circular(6),
                ),
                alignment: Alignment.center,
                child: task.done
                    ? const Icon(
                        LucideIcons.check,
                        size: 12,
                        color: Colors.white,
                      )
                    : null,
              ),
            ),
            const SizedBox(width: 12),

            // Middle info details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              task.title,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF1A1A1A),
                                decoration: task.done ? TextDecoration.lineThrough : null,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              task.lead,
                              style: const TextStyle(
                                fontSize: 11,
                                color: Color(0xFF94A3B8),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF5F1EB),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          LucideIcons.rotateCw,
                          size: 12,
                          color: const Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // Bottom tags metadata
                  Row(
                    children: [
                      Text(
                        task.time,
                        style: const TextStyle(
                          fontSize: 10,
                          color: Color(0xFF94A3B8),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        width: 3,
                        height: 3,
                        decoration: const BoxDecoration(
                          color: Color(0xFFCBD5E1),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        decoration: BoxDecoration(
                          color: scBg,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        child: Text(
                          task.stage,
                          style: TextStyle(
                            color: scText,
                            fontSize: 8,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
