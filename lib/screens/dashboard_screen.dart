import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../state/crm_state.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(crmProvider);
    final hour = DateTime.now().hour;
    final greeting = hour < 12 ? 'Morning' : hour < 17 ? 'Afternoon' : 'Evening';

    // Calculate metrics
    final newLeadsCount = state.leads.where((l) => l.stage == 'NEW').length;
    final pendingTasksCount = state.tasks.where((t) => !t.done).length;

    // Pipeline data counts
    final stages = ['NEW', 'CONTACTED', 'QUALIFIED', 'APPLIED', 'CONVERTED'];
    final stageColors = [
      const Color(0xFF3B82F6),
      const Color(0xFF6366F1),
      const Color(0xFF14B8A6),
      const Color(0xFFF59E0B),
      const Color(0xFF10B981)
    ];
    final stageCounts = stages.map((stage) {
      return state.leads.where((l) => l.stage == stage).length;
    }).toList();
    final totalPipeline = stageCounts.reduce((a, b) => a + b);

    // Today's Followups (from state tasks/leads)
    final followUps = state.leads.take(3).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F1EB),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Bar
            Padding(
              padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 24.0, bottom: 12.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: const Color(0xFF1A1A1A),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        alignment: Alignment.center,
                        child: const Text(
                          'J',
                          style: TextStyle(
                            color: Color(0xFFF5F1EB),
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '$greeting, Jane',
                            style: const TextStyle(
                              color: Color(0xFF64748B),
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Row(
                            children: const [
                              Icon(
                                LucideIcons.building,
                                size: 11,
                                color: Color(0xFF94A3B8),
                              ),
                              SizedBox(width: 4),
                              Text(
                                'Prestige Education',
                                style: TextStyle(
                                  color: Color(0xFF1A1A1A),
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.black.withOpacity(0.08)),
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        const Icon(
                          LucideIcons.bell,
                          size: 16,
                          color: Color(0xFF475569),
                        ),
                        Positioned(
                          top: 8,
                          right: 8,
                          child: Container(
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(
                              color: const Color(0xFFF43F5E),
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Column(
                children: [
                  // Metrics Grid
                  Row(
                    children: [
                      Expanded(
                        child: _buildMetricCard(
                          label: 'New Leads',
                          value: '$newLeadsCount',
                          trend: '+6',
                          sub: 'vs yesterday',
                          color: const Color(0xFF16A34A),
                          icon: LucideIcons.trendingUp,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildMetricCard(
                          label: 'Pending Tasks',
                          value: '$pendingTasksCount',
                          trend: 'due',
                          sub: '3 overdue',
                          color: const Color(0xFFF59E0B),
                          icon: LucideIcons.clock,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Pipeline Overview
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.black.withOpacity(0.06)),
                    ),
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'PIPELINE OVERVIEW',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                            color: Color(0xFF1A1A1A),
                          ),
                        ),
                        const SizedBox(height: 12),
                        // Multi-color progress bar
                        ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: SizedBox(
                            height: 12,
                            child: Row(
                              children: [
                                for (int i = 0; i < stages.length; i++)
                                  if (totalPipeline > 0 && stageCounts[i] > 0)
                                    Expanded(
                                      flex: stageCounts[i],
                                      child: Container(
                                        color: stageColors[i],
                                      ),
                                    )
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        // Legend
                        Wrap(
                          spacing: 12,
                          runSpacing: 6,
                          children: [
                            for (int i = 0; i < stages.length; i++)
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    width: 8,
                                    height: 8,
                                    decoration: BoxDecoration(
                                      color: stageColors[i],
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    stages[i],
                                    style: const TextStyle(
                                      color: Color(0xFF475569),
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${stageCounts[i]}',
                                    style: const TextStyle(
                                      color: Color(0xFF1A1A1A),
                                      fontSize: 10,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                ],
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Today's Follow-ups
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.black.withOpacity(0.06)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                "TODAY'S FOLLOW-UPS",
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.5,
                                  color: Color(0xFF1A1A1A),
                                ),
                              ),
                              GestureDetector(
                                onTap: () {},
                                child: Row(
                                  children: const [
                                    Text(
                                      'See all',
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF94A3B8),
                                      ),
                                    ),
                                    SizedBox(width: 2),
                                    Icon(
                                      LucideIcons.chevronRight,
                                      size: 11,
                                      color: Color(0xFF94A3B8),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        Divider(height: 1, color: Colors.black.withOpacity(0.05)),
                        ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: followUps.length,
                          separatorBuilder: (context, index) => Divider(
                                height: 1,
                                color: Colors.black.withOpacity(0.05),
                              ),
                          itemBuilder: (context, index) {
                            final lead = followUps[index];
                            final tempTagColor = lead.tag == 'HOT'
                                ? const Color(0xFFFFE4E6)
                                : const Color(0xFFFEF3C7);
                            final tempTextColor = lead.tag == 'HOT'
                                ? const Color(0xFFBE123C)
                                : const Color(0xFFB45309);
                            return Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                              child: Row(
                                children: [
                                  SizedBox(
                                    width: 50,
                                    child: Text(
                                      '1${index}:00 AM',
                                      style: const TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF94A3B8),
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          lead.name,
                                          style: const TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xFF1A1A1A),
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        Text(
                                          lead.program,
                                          style: const TextStyle(
                                            fontSize: 10,
                                            color: Color(0xFF94A3B8),
                                            fontWeight: FontWeight.w500,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Container(
                                    decoration: BoxDecoration(
                                      color: tempTagColor,
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    child: Text(
                                      lead.tag,
                                      style: TextStyle(
                                        color: tempTextColor,
                                        fontSize: 8,
                                        fontWeight: FontWeight.w900,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  GestureDetector(
                                    onTap: () {
                                      ref.read(crmProvider.notifier).logActivity(lead.id, 'CALL', 'Spoke to student from dashboard call trigger.');
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(content: Text('Call activity logged for ${lead.name}')),
                                      );
                                    },
                                    child: Container(
                                      width: 32,
                                      height: 32,
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF1A1A1A),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: const Icon(
                                        LucideIcons.phone,
                                        size: 14,
                                        color: Color(0xFFF5F1EB),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Quick Stats Row
                  Row(
                    children: [
                      Expanded(
                        child: _buildQuickStat(
                          value: '18%',
                          label: 'CONVERSION',
                          color: const Color(0xFF16A34A),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildQuickStat(
                          value: '4h',
                          label: 'AVG RESPONSE',
                          color: const Color(0xFF3B82F6),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildQuickStat(
                          value: '7',
                          label: 'HOT LEADS',
                          color: const Color(0xFFF43F5E),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricCard({
    required String label,
    required String value,
    required String trend,
    required String sub,
    required Color color,
    required IconData icon,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.black.withOpacity(0.06)),
      ),
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label.toUpperCase(),
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
              color: Color(0xFF64748B),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                value,
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w900,
                  height: 0.9,
                  color: Color(0xFF1A1A1A),
                ),
              ),
              const SizedBox(width: 6),
              Padding(
                padding: const EdgeInsets.only(bottom: 2.0),
                child: Row(
                  children: [
                    Icon(
                      icon,
                      size: 12,
                      color: color,
                    ),
                    const SizedBox(width: 1),
                    Text(
                      trend,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            sub,
            style: const TextStyle(
              fontSize: 9,
              color: Color(0xFF94A3B8),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStat({
    required String value,
    required String label,
    required Color color,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.black.withOpacity(0.06)),
      ),
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w900,
              color: color,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 8,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
              color: Color(0xFF94A3B8),
            ),
          ),
        ],
      ),
    );
  }
}
