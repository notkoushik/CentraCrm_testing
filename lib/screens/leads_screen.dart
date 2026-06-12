import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../state/crm_state.dart';
import '../models/crm_models.dart';
import 'lead_detail_screen.dart';
import 'add_lead_screen.dart';

class LeadsScreen extends ConsumerStatefulWidget {
  const LeadsScreen({super.key});

  @override
  ConsumerState<LeadsScreen> createState() => _LeadsScreenState();
}

class _LeadsScreenState extends ConsumerState<LeadsScreen> {
  String _activeFilter = 'All';
  String _searchQuery = '';
  String? _swipedId;

  final List<String> _filters = ['All', 'Hot', 'New', 'Follow-up', 'Unassigned'];

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(crmProvider);

    // Apply search and chip filters
    final filteredLeads = state.leads.where((lead) {
      final matchesSearch = lead.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          lead.program.toLowerCase().contains(_searchQuery.toLowerCase());
      if (!matchesSearch) return false;

      if (_activeFilter == 'Hot') return lead.tag == 'HOT';
      if (_activeFilter == 'New') return lead.stage == 'NEW';
      if (_activeFilter == 'Follow-up') {
        return ['CONTACTED', 'RESPONDED', 'QUALIFIED'].contains(lead.stage);
      }
      if (_activeFilter == 'Unassigned') return false; // mockup behavior
      return true;
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F1EB),
      body: Stack(
        children: [
          Column(
            children: [
              // Sticky search & chips top header
              Container(
                color: const Color(0xFFF5F1EB),
                padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 24.0, bottom: 8.0),
                child: Column(
                  children: [
                    // Search bar
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.black.withOpacity(0.08)),
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            child: Row(
                              children: [
                                const Icon(
                                  LucideIcons.search,
                                  size: 14,
                                  color: Color(0xFF94A3B8),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: TextField(
                                    onChanged: (val) {
                                      setState(() {
                                        _searchQuery = val;
                                      });
                                    },
                                    decoration: const InputDecoration(
                                      hintText: 'Search leads...',
                                      hintStyle: TextStyle(
                                        color: Color(0xFF94A3B8),
                                        fontSize: 13,
                                        fontWeight: FontWeight.w500,
                                      ),
                                      border: InputBorder.none,
                                      isDense: true,
                                      contentPadding: EdgeInsets.symmetric(vertical: 10),
                                    ),
                                    style: const TextStyle(
                                      color: Color(0xFF1A1A1A),
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.black.withOpacity(0.08)),
                          ),
                          child: const Icon(
                            LucideIcons.sliders,
                            size: 16,
                            color: Color(0xFF475569),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Filter chips
                    SizedBox(
                      height: 32,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: _filters.length,
                        itemBuilder: (context, index) {
                          final filterName = _filters[index];
                          final isSelected = _activeFilter == filterName;
                          return Padding(
                            padding: const EdgeInsets.only(right: 8.0),
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  _activeFilter = filterName;
                                });
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  color: isSelected ? const Color(0xFF1A1A1A) : Colors.white,
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(color: Colors.black.withOpacity(0.08)),
                                ),
                                padding: const EdgeInsets.symmetric(horizontal: 14),
                                alignment: Alignment.center,
                                child: Text(
                                  filterName,
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: isSelected ? const Color(0xFFF5F1EB) : const Color(0xFF475569),
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),

              // Leads List scroll view
              Expanded(
                child: filteredLeads.isEmpty
                    ? const Center(
                        child: Text(
                          'No leads found',
                          style: TextStyle(
                            color: Color(0xFF94A3B8),
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        itemCount: filteredLeads.length,
                        itemBuilder: (context, index) {
                          final lead = filteredLeads[index];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 10.0),
                            child: _buildLeadCard(lead),
                          );
                        },
                      ),
              ),
            ],
          ),

          // Bottom right FAB
          Positioned(
            bottom: 76,
            right: 16,
            child: FloatingActionButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => const AddLeadScreen()),
                );
              },
              backgroundColor: const Color(0xFF1A1A1A),
              elevation: 4,
              shape: const CircleBorder(),
              child: const Icon(
                LucideIcons.plus,
                color: Color(0xFFF5F1EB),
                size: 22,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLeadCard(Lead lead) {
    final isSwiped = _swipedId == lead.id;

    // Stage Config mapping
    Color scBg = const Color(0xFFF1F5F9);
    Color scText = const Color(0xFF475569);
    if (lead.stage == 'NEW') {
      scBg = const Color(0xFFDBEAFE);
      scText = const Color(0xFF1D4ED8);
    } else if (lead.stage == 'CONTACTED') {
      scBg = const Color(0xFFE0E7FF);
      scText = const Color(0xFF4338CA);
    } else if (lead.stage == 'QUALIFIED') {
      scBg = const Color(0xFFCCFBF1);
      scText = const Color(0xFF0F766E);
    } else if (lead.stage == 'APPLIED') {
      scBg = const Color(0xFFF3E8FF);
      scText = const Color(0xFF7E22CE);
    } else if (lead.stage == 'CONVERTED') {
      scBg = const Color(0xFFFEF9C3);
      scText = const Color(0xFF854D0E);
    }

    final tempTagColor = lead.tag == 'HOT'
        ? const Color(0xFFFFF1F2)
        : lead.tag == 'WARM'
            ? const Color(0xFFFEF3C7)
            : const Color(0xFFEFF6FF);

    final tempTextColor = lead.tag == 'HOT'
        ? const Color(0xFFE11D48)
        : lead.tag == 'WARM'
            ? const Color(0xFFD97706)
            : const Color(0xFF2563EB);

    final tempBorderColor = lead.tag == 'HOT'
        ? const Color(0xFFFECDD3)
        : lead.tag == 'WARM'
            ? const Color(0xFFFDE68A)
            : const Color(0xFFBFDBFE);

    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Stack(
        children: [
          // Underlying action drawer buttons
          Positioned.fill(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                _buildDrawerActionButton(
                  color: const Color(0xFF10B981),
                  icon: LucideIcons.phone,
                  label: 'Call',
                  onTap: () {
                    ref.read(crmProvider.notifier).logActivity(lead.id, 'CALL', 'Called student.');
                    _resetSwipe();
                  },
                ),
                _buildDrawerActionButton(
                  color: const Color(0xFF25D366),
                  icon: LucideIcons.messageCircle,
                  label: 'WA',
                  onTap: () {
                    ref.read(crmProvider.notifier).logActivity(lead.id, 'WHATSAPP', 'Sent WhatsApp brochure.');
                    _resetSwipe();
                  },
                ),
                _buildDrawerActionButton(
                  color: const Color(0xFF3B82F6),
                  icon: LucideIcons.mail,
                  label: 'Email',
                  onTap: () {
                    ref.read(crmProvider.notifier).logActivity(lead.id, 'EMAIL', 'Emailed fee invoice detail.');
                    _resetSwipe();
                  },
                ),
              ],
            ),
          ),

          // Main Card overlay
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            transform: Matrix4.translationValues(isSwiped ? -144 : 0, 0, 0),
            child: GestureDetector(
              onTap: () {
                if (isSwiped) {
                  _resetSwipe();
                } else {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => LeadDetailScreen(leadId: lead.id),
                    ),
                  );
                }
              },
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: Colors.black.withOpacity(0.06)),
                  borderRadius: BorderRadius.circular(16),
                ),
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: const Color(0xFF1A1A1A),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        lead.name.isNotEmpty ? lead.name[0] : '?',
                        style: const TextStyle(
                          color: Color(0xFFF5F1EB),
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  lead.name,
                                  style: const TextStyle(
                                    color: Color(0xFF1A1A1A),
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Container(
                                decoration: BoxDecoration(
                                  color: tempTagColor,
                                  border: Border.all(color: tempBorderColor),
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
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            lead.program,
                            style: const TextStyle(
                              color: Color(0xFF64748B),
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  color: scBg,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                child: Text(
                                  lead.stage,
                                  style: TextStyle(
                                    color: scText,
                                    fontSize: 9,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                lead.source,
                                style: const TextStyle(
                                  color: Color(0xFF94A3B8),
                                  fontSize: 9,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Row(
                      children: [
                        GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: () {
                            setState(() {
                              _swipedId = isSwiped ? null : lead.id;
                            });
                          },
                          child: const Padding(
                            padding: EdgeInsets.all(4.0),
                            child: Text(
                              '←',
                              style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFFCBD5E1),
                              ),
                            ),
                          ),
                        ),
                        const Icon(
                          LucideIcons.chevronRight,
                          color: Color(0xFFCBD5E1),
                          size: 14,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerActionButton({
    required Color color,
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        color: color,
        width: 48,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 16,
              color: Colors.white,
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 9,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _resetSwipe() {
    setState(() {
      _swipedId = null;
    });
  }
}
