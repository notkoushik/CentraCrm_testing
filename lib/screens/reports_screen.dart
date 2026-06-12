import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';

class ReportsScreen extends ConsumerStatefulWidget {
  const ReportsScreen({super.key});

  @override
  ConsumerState<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends ConsumerState<ReportsScreen> {
  String _selectedRange = '6M';

  final List<String> _months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun'];
  final List<int> _revenueData = [210000, 185000, 260000, 310000, 295000, 380000];
  final List<int> _leadsData = [34, 29, 41, 55, 48, 67];

  final List<Map<String, dynamic>> _counselors = [
    {'name': 'Jane Cooper', 'leads': 67, 'converted': 18, 'rate': 27, 'avatar': 'J', 'rank': 1},
    {'name': 'Arun Sharma', 'leads': 54, 'converted': 13, 'rate': 24, 'avatar': 'A', 'rank': 2},
    {'name': 'Meera Pillai', 'leads': 48, 'converted': 11, 'rate': 23, 'avatar': 'M', 'rank': 3},
    {'name': 'Vikram Tiwari', 'leads': 41, 'converted': 7, 'rate': 17, 'avatar': 'V', 'rank': 4},
  ];

  final List<Map<String, dynamic>> _funnelStages = [
    {'stage': 'New Leads', 'count': 246, 'pct': 100, 'color': const Color(0xFF3B82F6)},
    {'stage': 'Contacted', 'count': 189, 'pct': 77, 'color': const Color(0xFF6366F1)},
    {'stage': 'Qualified', 'count': 122, 'pct': 50, 'color': const Color(0xFF14B8A6)},
    {'stage': 'Meeting Booked', 'count': 78, 'pct': 32, 'color': const Color(0xFFF59E0B)},
    {'stage': 'Applied', 'count': 45, 'pct': 18, 'color': const Color(0xFFA855F7)},
    {'stage': 'Converted', 'count': 28, 'pct': 11, 'color': const Color(0xFF10B981)},
  ];

  String _fmt(int n) {
    if (n >= 100000) {
      return '₹${(n / 100000).toStringAsFixed(1)}L';
    } else if (n >= 1000) {
      return '₹${(n / 1000).toStringAsFixed(0)}k';
    }
    return '₹$n';
  }

  @override
  Widget build(BuildContext context) {
    final int totalRevenue = _revenueData.reduce((a, b) => a + b);
    final int totalLeads = _leadsData.reduce((a, b) => a + b);
    final int maxRevenue = _revenueData.reduce((a, b) => a > b ? a : b);
    final int maxLeads = _leadsData.reduce((a, b) => a > b ? a : b);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F1EB),
      body: SafeArea(
        child: Column(
          children: [
            // Top custom action bar
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.black.withOpacity(0.08)),
                      ),
                      child: const Icon(
                        LucideIcons.arrowLeft,
                        size: 18,
                        color: Color(0xFF1A1A1A),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Reports',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFF1A1A1A),
                          ),
                        ),
                        Text(
                          'ANALYTICS & INSIGHTS',
                          style: TextStyle(
                            fontSize: 10,
                            color: Color(0xFF64748B),
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Scrollable charts and data list
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                children: [
                  // Range switcher tabs
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.black.withOpacity(0.06)),
                    ),
                    padding: const EdgeInsets.all(4.0),
                    child: Row(
                      children: ['30D', '90D', '6M'].map((range) {
                        final isSelected = _selectedRange == range;
                        return Expanded(
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                _selectedRange = range;
                              });
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                color: isSelected ? const Color(0xFF1A1A1A) : Colors.transparent,
                                borderRadius: BorderRadius.circular(9),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              alignment: Alignment.center,
                              child: Text(
                                range,
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w900,
                                  color: isSelected ? const Color(0xFFF5F1EB) : const Color(0xFF94A3B8),
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Top KPI Summary row
                  Row(
                    children: [
                      Expanded(
                        child: _buildKPICard(
                          title: 'Total Revenue',
                          value: _fmt(totalRevenue),
                          sub: '+23% vs last period',
                          icon: LucideIcons.dollarSign,
                          color: Colors.green,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildKPICard(
                          title: 'Total Leads',
                          value: '$totalLeads',
                          sub: '+18% vs last period',
                          icon: LucideIcons.users,
                          color: Colors.blue,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Revenue Bar Chart
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.black.withOpacity(0.06)),
                    ),
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'MONTHLY REVENUE',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1A1A1A),
                              ),
                            ),
                            Text(
                              'Jan–Jun 2026',
                              style: TextStyle(
                                fontSize: 10,
                                color: Color(0xFF64748B),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        // Visual Bars row
                        SizedBox(
                          height: 140,
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              for (int i = 0; i < _revenueData.length; i++) ...[
                                Expanded(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      if (_revenueData[i] == maxRevenue)
                                        Container(
                                          margin: const EdgeInsets.only(bottom: 4),
                                          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFF5F1EB),
                                            borderRadius: BorderRadius.circular(4),
                                          ),
                                          child: Text(
                                            _fmt(_revenueData[i]),
                                            style: const TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: Color(0xFF1A1A1A)),
                                          ),
                                        ),
                                      Expanded(
                                        child: Align(
                                          alignment: Alignment.bottomCenter,
                                          child: FractionallySizedBox(
                                            heightFactor: _revenueData[i] / maxRevenue,
                                            child: Container(
                                              width: double.infinity,
                                              margin: const EdgeInsets.symmetric(horizontal: 4),
                                              decoration: BoxDecoration(
                                                color: _revenueData[i] == maxRevenue ? const Color(0xFF1A1A1A) : const Color(0xFFE2E8F0),
                                                borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        _months[i],
                                        style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Color(0xFF94A3B8)),
                                      ),
                                    ],
                                  ),
                                ),
                              ]
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Lead Volume Sparkline progress indicators
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.black.withOpacity(0.06)),
                    ),
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'LEAD VOLUME',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1A1A1A),
                              ),
                            ),
                            Text(
                              'per month',
                              style: TextStyle(
                                fontSize: 10,
                                color: Color(0xFF64748B),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          height: 64,
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              for (int i = 0; i < _leadsData.length; i++)
                                Expanded(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      Expanded(
                                        child: Align(
                                          alignment: Alignment.bottomCenter,
                                          child: FractionallySizedBox(
                                            heightFactor: _leadsData[i] / maxLeads,
                                            child: Container(
                                              width: double.infinity,
                                              margin: const EdgeInsets.symmetric(horizontal: 4),
                                              decoration: BoxDecoration(
                                                color: const Color(0xFF1A1A1A).withOpacity(0.15),
                                                borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                                              ),
                                              child: Align(
                                                alignment: Alignment.topCenter,
                                                child: Container(
                                                  height: 4,
                                                  decoration: const BoxDecoration(
                                                    color: Color(0xFF1A1A1A),
                                                    borderRadius: BorderRadius.vertical(top: Radius.circular(4)),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        _months[i],
                                        style: const TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: Color(0xFF94A3B8)),
                                      ),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Conversion Funnel list
                  Container(
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
                          'CONVERSION FUNNEL',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1A1A1A),
                          ),
                        ),
                        const SizedBox(height: 16),
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: _funnelStages.length,
                          itemBuilder: (context, index) {
                            final stage = _funnelStages[index];
                            final pct = stage['pct'] as int;
                            final color = stage['color'] as Color;

                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12.0),
                              child: Column(
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        stage['stage'] as String,
                                        style: const TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF475569),
                                        ),
                                      ),
                                      Row(
                                        children: [
                                          Text(
                                            '${stage['count']}',
                                            style: const TextStyle(
                                              fontSize: 11,
                                              fontWeight: FontWeight.w900,
                                              color: Color(0xFF1A1A1A),
                                            ),
                                          ),
                                          const SizedBox(width: 6),
                                          Text(
                                            '$pct%',
                                            style: const TextStyle(
                                              fontSize: 9,
                                              fontWeight: FontWeight.bold,
                                              color: Color(0xFF94A3B8),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(3),
                                    child: LinearProgressIndicator(
                                      value: pct / 100,
                                      minHeight: 6,
                                      backgroundColor: const Color(0xFFF5F1EB),
                                      valueColor: AlwaysStoppedAnimation<Color>(color),
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

                  // Counselor Leaderboard
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
                            children: const [
                              Icon(LucideIcons.award, size: 15, color: Colors.amber),
                              SizedBox(width: 8),
                              Text(
                                'COUNSELOR LEADERBOARD',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF1A1A1A),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Divider(height: 1, color: Colors.black.withOpacity(0.05)),
                        ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: _counselors.length,
                          separatorBuilder: (context, index) => Divider(
                            height: 1,
                            color: Colors.black.withOpacity(0.05),
                          ),
                          itemBuilder: (context, index) {
                            final counselor = _counselors[index];
                            final rank = counselor['rank'] as int;

                            Color rankBg = const Color(0xFFF8FAFC);
                            Color rankText = const Color(0xFFCBD5E1);
                            if (rank == 1) {
                              rankBg = const Color(0xFFFEF3C7);
                              rankText = const Color(0xFFD97706);
                            } else if (rank == 2) {
                              rankBg = const Color(0xFFF1F5F9);
                              rankText = const Color(0xFF475569);
                            } else if (rank == 3) {
                              rankBg = const Color(0xFFFFF7ED);
                              rankText = const Color(0xFFEA580C);
                            }

                            return Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                              child: Row(
                                children: [
                                  // Rank badge
                                  Container(
                                    width: 24,
                                    height: 24,
                                    decoration: BoxDecoration(
                                      color: rankBg,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    alignment: Alignment.center,
                                    child: Text(
                                      '$rank',
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w900,
                                        color: rankText,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  // Avatar
                                  Container(
                                    width: 36,
                                    height: 36,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF1A1A1A),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    alignment: Alignment.center,
                                    child: Text(
                                      counselor['avatar'] as String,
                                      style: const TextStyle(
                                        color: Color(0xFFF5F1EB),
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  // Details
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          counselor['name'] as String,
                                          style: const TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xFF1A1A1A),
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        Text(
                                          '${counselor['leads']} leads · ${counselor['converted']} converted',
                                          style: const TextStyle(
                                            fontSize: 10,
                                            color: Color(0xFF94A3B8),
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  // Rate
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text(
                                        '${counselor['rate']}%',
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w900,
                                          color: rank == 1 ? const Color(0xFF10B981) : const Color(0xFF1A1A1A),
                                        ),
                                      ),
                                      const Text(
                                        'CONV.',
                                        style: TextStyle(
                                          fontSize: 8,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF94A3B8),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildKPICard({
    required String title,
    required String value,
    required String sub,
    required IconData icon,
    required Color color,
  }) {
    Color itemColor = const Color(0xFF64748B);
    Color bgLightColor = const Color(0xFFF8FAFC);
    if (color == Colors.green) {
      itemColor = const Color(0xFF10B981);
      bgLightColor = const Color(0xFFECFDF5);
    } else if (color == Colors.blue) {
      itemColor = const Color(0xFF3B82F6);
      bgLightColor = const Color(0xFFEFF6FF);
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.black.withOpacity(0.06)),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: bgLightColor,
              borderRadius: BorderRadius.circular(10),
            ),
            alignment: Alignment.center,
            child: Icon(
              icon,
              size: 15,
              color: itemColor,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              color: Color(0xFF1A1A1A),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title.toUpperCase(),
            style: const TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.bold,
              color: Color(0xFF94A3B8),
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              const Icon(LucideIcons.trendingUp, size: 10, color: Color(0xFF10B981)),
              const SizedBox(width: 4),
              Text(
                sub,
                style: const TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF10B981),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
