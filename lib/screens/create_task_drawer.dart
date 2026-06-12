import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../state/crm_state.dart';
import '../models/crm_models.dart';

class CreateTaskDrawer extends ConsumerStatefulWidget {
  final String leadName;
  const CreateTaskDrawer({super.key, required this.leadName});

  @override
  ConsumerState<CreateTaskDrawer> createState() => _CreateTaskDrawerState();
}

class _CreateTaskDrawerState extends ConsumerState<CreateTaskDrawer> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _timeController = TextEditingController(text: '10:00 AM');

  int _selectedDayIndex = 1; // Tuesday (Today)
  String _selectedType = 'CALL';

  final List<String> _weekDays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  final List<int> _dates = [9, 10, 11, 12, 13, 14, 15];
  final List<String> _types = ['CALL', 'WHATSAPP', 'EMAIL', 'VERIFY'];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 16,
        right: 16,
        top: 16,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header drag line
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFFE2E8F0),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Create Task',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w900,
              color: Color(0xFF1A1A1A),
            ),
          ),
          const SizedBox(height: 12),

          // Associated lead (read only)
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: const Color(0xFFF5F1EB),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.black.withOpacity(0.06)),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              children: [
                const Icon(
                  LucideIcons.users,
                  size: 13,
                  color: Color(0xFF64748B),
                ),
                const SizedBox(width: 8),
                const Text(
                  'Associated Lead: ',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF64748B),
                  ),
                ),
                Text(
                  widget.leadName,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1A1A1A),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Task Title input
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.black.withOpacity(0.12)),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            child: TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                hintText: 'Enter task description (e.g. Call to discuss fees)...',
                hintStyle: TextStyle(
                  color: Color(0xFF64748B),
                  fontSize: 13,
                ),
                border: InputBorder.none,
              ),
              style: const TextStyle(
                color: Color(0xFF1A1A1A),
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Calendar due date select
          const Text(
            'DUE DATE',
            style: TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
              color: Color(0xFF64748B),
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 54,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _weekDays.length,
              itemBuilder: (context, index) {
                final isSelected = index == _selectedDayIndex;
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedDayIndex = index;
                      });
                    },
                    child: Container(
                      width: 44,
                      decoration: BoxDecoration(
                        color: isSelected ? const Color(0xFF1A1A1A) : const Color(0xFFF5F1EB),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            _weekDays[index].toUpperCase(),
                            style: TextStyle(
                              fontSize: 8,
                              fontWeight: FontWeight.bold,
                              color: isSelected ? const Color(0xFFF5F1EB) : const Color(0xFF64748B),
                            ),
                          ),
                          Text(
                            '${_dates[index]}',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: isSelected ? const Color(0xFFF5F1EB) : const Color(0xFF1A1A1A),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 16),

          // Task Type chips
          const Text(
            'TASK TYPE',
            style: TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
              color: Color(0xFF64748B),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: _types.map((type) {
              final isSelected = _selectedType == type;
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4.0),
                  child: OutlinedButton(
                    onPressed: () {
                      setState(() {
                        _selectedType = type;
                      });
                    },
                    style: OutlinedButton.styleFrom(
                      backgroundColor: isSelected ? const Color(0xFF1A1A1A) : const Color(0xFFF5F1EB),
                      side: BorderSide(color: isSelected ? const Color(0xFF1A1A1A) : Colors.black.withOpacity(0.08)),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                    child: Text(
                      type,
                      style: TextStyle(
                        color: isSelected ? const Color(0xFFF5F1EB) : const Color(0xFF475569),
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),

          // Due Time input
          const Text(
            'DUE TIME',
            style: TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
              color: Color(0xFF64748B),
            ),
          ),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFFF5F1EB),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.black.withOpacity(0.06)),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: TextField(
              controller: _timeController,
              decoration: const InputDecoration(
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.symmetric(vertical: 10),
              ),
              style: const TextStyle(
                color: Color(0xFF1A1A1A),
                fontSize: 13,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Save button
          ElevatedButton(
            onPressed: () {
              final title = _titleController.text.trim();
              if (title.isNotEmpty) {
                final newTask = Task(
                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                  title: title,
                  lead: widget.leadName,
                  time: _timeController.text.trim(),
                  stage: _selectedType,
                  stageColor: 'bg-indigo-100 text-indigo-700',
                  done: false,
                );

                ref.read(crmProvider.notifier).addTask(newTask);
                Navigator.of(context).pop();

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Task scheduled successfully!')),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1A1A1A),
              foregroundColor: const Color(0xFFF5F1EB),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              minimumSize: const Size(double.infinity, 50),
            ),
            child: const Text(
              'Save Task',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
