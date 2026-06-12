import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../state/crm_state.dart';
import '../models/crm_models.dart';
import 'create_task_drawer.dart';

class LeadDetailScreen extends ConsumerStatefulWidget {
  final String leadId;
  const LeadDetailScreen({super.key, required this.leadId});

  @override
  ConsumerState<LeadDetailScreen> createState() => _LeadDetailScreenState();
}

class _LeadDetailScreenState extends ConsumerState<LeadDetailScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(crmProvider);
    final leadIndex = state.leads.indexWhere((l) => l.id == widget.leadId);

    if (leadIndex == -1) {
      return Scaffold(
        appBar: AppBar(title: const Text('Lead Not Found')),
        body: const Center(child: Text('Lead detail could not be retrieved.')),
      );
    }

    final lead = state.leads[leadIndex];

    final allStages = [
      'NEW',
      'CONTACTED',
      'RESPONDED',
      'QUALIFIED',
      'MEETING SCHEDULED',
      'APPLIED',
      'CONVERTED',
      'ON HOLD',
      'LOST'
    ];

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

    return Scaffold(
      backgroundColor: const Color(0xFFF5F1EB),
      body: SafeArea(
        child: Column(
          children: [
            // Top custom action bar
            Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.of(context).pop(),
                        child: Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: const Color(0xFFF5F1EB),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            LucideIcons.arrowLeft,
                            size: 18,
                            color: Color(0xFF1A1A1A),
                          ),
                        ),
                      ),
                      Text(
                        lead.name,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1A1A1A),
                        ),
                      ),
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF5F1EB),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          LucideIcons.moreVertical,
                          size: 18,
                          color: Color(0xFF1A1A1A),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Header Summary Card
                  Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: const Color(0xFF1A1A1A),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          lead.name.isNotEmpty ? lead.name[0] : '?',
                          style: const TextStyle(
                            color: Color(0xFFF5F1EB),
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              lead.name,
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w900,
                                color: Color(0xFF1A1A1A),
                              ),
                            ),
                            Text(
                              lead.email,
                              style: const TextStyle(
                                fontSize: 11,
                                color: Color(0xFF64748B),
                                fontWeight: FontWeight.w500,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              lead.phone,
                              style: const TextStyle(
                                fontSize: 11,
                                color: Color(0xFF64748B),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Dropdown Stage Selector
                      Container(
                        decoration: BoxDecoration(
                          color: scBg,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: DropdownButton<String>(
                          value: lead.stage,
                          icon: const Icon(LucideIcons.chevronDown, size: 12, color: Color(0xFF1A1A1A)),
                          underline: const SizedBox(),
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w900,
                            color: scText,
                          ),
                          onChanged: (String? val) {
                            if (val != null) {
                              ref.read(crmProvider.notifier).updateLeadStage(lead.id, val);
                            }
                          },
                          items: allStages.map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Quick Action Buttons
                  Row(
                    children: [
                      Expanded(
                        child: _buildQuickAction(
                          color: const Color(0xFF1A1A1A),
                          icon: LucideIcons.phone,
                          label: 'Call',
                          onTap: () {
                            ref.read(crmProvider.notifier).logActivity(lead.id, 'CALL', 'Spoke to student.');
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildQuickAction(
                          color: const Color(0xFF25D366),
                          icon: LucideIcons.messageCircle,
                          label: 'WhatsApp',
                          onTap: () {
                            _showTemplateCommunicationSheet(context, lead, 'WHATSAPP');
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildQuickAction(
                          color: const Color(0xFF3B82F6),
                          icon: LucideIcons.mail,
                          label: 'Email',
                          onTap: () {
                            _showTemplateCommunicationSheet(context, lead, 'EMAIL');
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Tab bar Navigation switcher
            Container(
              color: Colors.white,
              child: TabBar(
                controller: _tabController,
                indicatorColor: const Color(0xFF1A1A1A),
                labelColor: const Color(0xFF1A1A1A),
                unselectedLabelColor: const Color(0xFF94A3B8),
                labelStyle: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
                tabs: const [
                  Tab(text: 'INFO'),
                  Tab(text: 'APPLICATION & DOCS'),
                  Tab(text: 'TIMELINE'),
                ],
              ),
            ),

            // Tab content scrollable
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  // INFO TAB
                  ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      _buildAccordionCard(
                        title: 'Educational Background',
                        icon: LucideIcons.bookOpen,
                        children: [
                          _buildDetailRow('Qualification', lead.eduBackground),
                          const SizedBox(height: 12),
                          _buildDetailRow('Interested Program', lead.program),
                        ],
                      ),
                      const SizedBox(height: 12),
                      _buildAccordionCard(
                        title: 'Location',
                        icon: LucideIcons.mapPin,
                        children: [
                          _buildDetailRow('City', 'Mumbai, India'),
                          const SizedBox(height: 12),
                          _buildDetailRow('Preferred Country', 'United Kingdom'),
                        ],
                      ),
                      const SizedBox(height: 12),
                      _buildAccordionCard(
                        title: 'Interested Program',
                        icon: LucideIcons.fileText,
                        children: [
                          _buildDetailRow('Program', lead.program),
                          const SizedBox(height: 12),
                          _buildDetailRow('Lead Source', lead.source),
                        ],
                      ),
                      const SizedBox(height: 80),
                    ],
                  ),

                  // APPLICATION & DOCS TAB
                  _buildApplicationAndDocsTab(context, lead, ref),

                  // TIMELINE TAB
                  ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: lead.timeline.isEmpty ? 1 : lead.timeline.length,
                    itemBuilder: (context, index) {
                      if (lead.timeline.isEmpty) {
                        return const Center(
                          child: Padding(
                            padding: EdgeInsets.symmetric(vertical: 40.0),
                            child: Text(
                              'No activity yet.',
                              style: TextStyle(
                                color: Color(0xFF64748B),
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ),
                        );
                      }
                      final event = lead.timeline[index];
                      return _buildTimelineItem(event, isLast: index == lead.timeline.length - 1);
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: Colors.black.withOpacity(0.08))),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        child: SafeArea(
          child: Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _showLogActivityDrawer(context, lead.id),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1A1A1A),
                    foregroundColor: const Color(0xFFF5F1EB),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  icon: const Icon(LucideIcons.checkCircle, size: 14),
                  label: const Text(
                    'Log Activity',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                      ),
                      builder: (context) => CreateTaskDrawer(leadName: lead.name),
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF1A1A1A),
                    side: BorderSide(color: Colors.black.withOpacity(0.12)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  icon: const Icon(LucideIcons.clipboardList, size: 14),
                  label: const Text(
                    'Create Task',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickAction({
    required Color color,
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: () {
        onTap();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$label action triggered')),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 13,
              color: Colors.white,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAccordionCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.black.withOpacity(0.06)),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          initiallyExpanded: true,
          leading: Icon(icon, size: 14, color: const Color(0xFF64748B)),
          title: Text(
            title.toUpperCase(),
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
              color: Color(0xFF1A1A1A),
            ),
          ),
          childrenPadding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
          expandedAlignment: Alignment.topLeft,
          children: children,
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            color: Color(0xFF94A3B8),
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value.isNotEmpty ? value : 'N/A',
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1A1A1A),
          ),
        ),
      ],
    );
  }

  Widget _buildTimelineItem(TimelineEvent event, {required bool isLast}) {
    IconData icon = LucideIcons.fileText;
    Color color = const Color(0xFF64748B);
    Color dotColor = const Color(0xFF94A3B8);
    String label = 'Activity';

    if (event.type == 'CALL') {
      icon = LucideIcons.phoneCall;
      color = const Color(0xFFEA580C);
      dotColor = const Color(0xFFF97316);
      label = 'Call Logged';
    } else if (event.type == 'WHATSAPP') {
      icon = LucideIcons.messageCircle;
      color = const Color(0xFF16A34A);
      dotColor = const Color(0xFF10B981);
      label = 'WhatsApp';
    } else if (event.type == 'EMAIL') {
      icon = LucideIcons.mail;
      color = const Color(0xFF2563EB);
      dotColor = const Color(0xFF3B82F6);
      label = 'Email Sent';
    } else if (event.type == 'NOTE') {
      icon = LucideIcons.fileText;
      color = const Color(0xFF475569);
      dotColor = const Color(0xFF64748B);
      label = 'Note Added';
    }

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Left timeline graphic line
          Column(
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: dotColor,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 1,
                    color: Colors.black.withOpacity(0.08),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 12),
          // Content Card
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(icon, size: 12, color: color),
                      const SizedBox(width: 6),
                      Text(
                        label.toUpperCase(),
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: color,
                          letterSpacing: 0.5,
                        ),
                      ),
                      if (event.status != null) ...[
                        const SizedBox(width: 8),
                        Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.black.withOpacity(0.08)),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                          child: Text(
                            event.status!,
                            style: const TextStyle(
                              fontSize: 8,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF64748B),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    event.message,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF475569),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    event.time,
                    style: const TextStyle(
                      fontSize: 10,
                      color: Color(0xFF94A3B8),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showLogActivityDrawer(BuildContext context, String leadId) {
    String selectedType = 'CALL';
    final TextEditingController contentController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
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
                    'Log Activity',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF1A1A1A),
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Select activity types chips
                  Row(
                    children: ['CALL', 'WHATSAPP', 'EMAIL', 'NOTE'].map((type) {
                      final isSelected = selectedType == type;
                      return Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4.0),
                          child: OutlinedButton(
                            onPressed: () {
                              setModalState(() {
                                    selectedType = type;
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
                  // Text Area notes input
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFF5F1EB),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.black.withOpacity(0.08)),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    child: TextField(
                      controller: contentController,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        hintText: 'Write interaction notes here...',
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
                  ElevatedButton(
                    onPressed: () {
                      final content = contentController.text.trim();
                      if (content.isNotEmpty) {
                        ref.read(crmProvider.notifier).logActivity(leadId, selectedType, content);
                        Navigator.of(context).pop();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Activity saved successfully!')),
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
                      'Save Activity',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildApplicationAndDocsTab(BuildContext context, Lead lead, WidgetRef ref) {
    final application = lead.application;
    if (application == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                LucideIcons.fileMinus,
                size: 48,
                color: Color(0xFF94A3B8),
              ),
              const SizedBox(height: 12),
              const Text(
                'No Active Application',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A1A1A),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'This lead has not started an application for ${lead.program} yet.',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFF64748B),
                ),
              ),
            ],
          ),
        ),
      );
    }

    final allStatuses = [
      'STARTED',
      'SUBMITTED',
      'VERIFICATION_PENDING',
      'VERIFIED',
      'REJECTED'
    ];

    Color statusColor = const Color(0xFF64748B);
    Color statusBg = const Color(0xFFF1F5F9);
    if (application.status == 'STARTED') {
      statusColor = const Color(0xFF2563EB);
      statusBg = const Color(0xFFDBEAFE);
    } else if (application.status == 'SUBMITTED') {
      statusColor = const Color(0xFFD97706);
      statusBg = const Color(0xFFFEF3C7);
    } else if (application.status == 'VERIFICATION_PENDING') {
      statusColor = const Color(0xFF7C3AED);
      statusBg = const Color(0xFFF3E8FF);
    } else if (application.status == 'VERIFIED') {
      statusColor = const Color(0xFF16A34A);
      statusBg = const Color(0xFFDCFCE7);
    } else if (application.status == 'REJECTED') {
      statusColor = const Color(0xFFDC2626);
      statusBg = const Color(0xFFFEE2E2);
    }

    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        // Status Card
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.black.withOpacity(0.06)),
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'APPLICATION STATUS',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF94A3B8),
                      letterSpacing: 0.5,
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: statusBg,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    child: Text(
                      application.status,
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w900,
                        color: statusColor,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const Text(
                'Change Application Status',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A1A1A),
                ),
              ),
              const SizedBox(height: 6),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F1EB),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.black.withOpacity(0.08)),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: application.status,
                    isExpanded: true,
                    icon: const Icon(LucideIcons.chevronDown, size: 14),
                    items: allStatuses.map((s) {
                      return DropdownMenuItem(
                        value: s,
                        child: Text(s, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                      );
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) {
                        ref.read(crmProvider.notifier).updateApplicationStatus(lead.id, application.id, val);
                      }
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Documents Header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'SUBMITTED DOCUMENTS',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1A1A1A),
                letterSpacing: 0.5,
              ),
            ),
            Text(
              '${application.documents.length} Files',
              style: const TextStyle(
                fontSize: 11,
                color: Color(0xFF94A3B8),
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),

        if (application.documents.isEmpty)
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.black.withOpacity(0.06)),
            ),
            padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 16),
            child: Column(
              children: const [
                Icon(LucideIcons.fileWarning, size: 32, color: Color(0xFFCBD5E1)),
                SizedBox(height: 8),
                Text(
                  'No documents uploaded yet.',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          )
        else
          ...application.documents.map((doc) => _buildDocumentTile(context, lead, doc, ref)),
        const SizedBox(height: 80),
      ],
    );
  }

  Widget _buildDocumentTile(BuildContext context, Lead lead, DocumentModel doc, WidgetRef ref) {
    Color statusColor = const Color(0xFF64748B);
    Color statusBg = const Color(0xFFF1F5F9);
    IconData statusIcon = LucideIcons.helpCircle;

    if (doc.status == 'VERIFIED') {
      statusColor = const Color(0xFF16A34A);
      statusBg = const Color(0xFFDCFCE7);
      statusIcon = LucideIcons.checkCircle2;
    } else if (doc.status == 'REJECTED') {
      statusColor = const Color(0xFFDC2626);
      statusBg = const Color(0xFFFEE2E2);
      statusIcon = LucideIcons.xCircle;
    } else if (doc.status == 'PENDING') {
      statusColor = const Color(0xFFD97706);
      statusBg = const Color(0xFFFEF3C7);
      statusIcon = LucideIcons.clock;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.black.withOpacity(0.06)),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
        leading: Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: const Color(0xFFF5F1EB),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(LucideIcons.fileText, color: Color(0xFF1A1A1A), size: 18),
        ),
        title: Text(
          doc.name,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1A1A1A),
          ),
        ),
        subtitle: Text(
          doc.type.toUpperCase(),
          style: const TextStyle(
            fontSize: 10,
            color: Color(0xFF94A3B8),
            fontWeight: FontWeight.bold,
          ),
        ),
        trailing: Container(
          decoration: BoxDecoration(
            color: statusBg,
            borderRadius: BorderRadius.circular(6),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(statusIcon, size: 10, color: statusColor),
              const SizedBox(width: 4),
              Text(
                doc.status,
                style: TextStyle(
                  fontSize: 8,
                  fontWeight: FontWeight.w900,
                  color: statusColor,
                ),
              ),
            ],
          ),
        ),
        onTap: () => _showDocumentVerificationSheet(context, lead, doc, ref),
      ),
    );
  }

  void _showDocumentVerificationSheet(BuildContext context, Lead lead, DocumentModel doc, WidgetRef ref) {
    final remarksController = TextEditingController(text: doc.remarks);
    String selectedStatus = doc.status;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
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
                  Text(
                    doc.name,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF1A1A1A),
                    ),
                  ),
                  Text(
                    'TYPE: ${doc.type.toUpperCase()}',
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF94A3B8),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Verification decision buttons
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            setModalState(() {
                              selectedStatus = 'VERIFIED';
                            });
                          },
                          icon: const Icon(LucideIcons.checkCircle2, size: 14),
                          label: const Text('APPROVE'),
                          style: OutlinedButton.styleFrom(
                            backgroundColor: selectedStatus == 'VERIFIED'
                                ? const Color(0xFFDCFCE7)
                                : const Color(0xFFF5F1EB),
                            foregroundColor: selectedStatus == 'VERIFIED'
                                ? const Color(0xFF16A34A)
                                : const Color(0xFF475569),
                            side: BorderSide(
                              color: selectedStatus == 'VERIFIED'
                                  ? const Color(0xFF16A34A)
                                  : Colors.black.withOpacity(0.08),
                            ),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            setModalState(() {
                              selectedStatus = 'REJECTED';
                            });
                          },
                          icon: const Icon(LucideIcons.xCircle, size: 14),
                          label: const Text('REJECT'),
                          style: OutlinedButton.styleFrom(
                            backgroundColor: selectedStatus == 'REJECTED'
                                ? const Color(0xFFFEE2E2)
                                : const Color(0xFFF5F1EB),
                            foregroundColor: selectedStatus == 'REJECTED'
                                ? const Color(0xFFDC2626)
                                : const Color(0xFF475569),
                            side: BorderSide(
                              color: selectedStatus == 'REJECTED'
                                  ? const Color(0xFFDC2626)
                                  : Colors.black.withOpacity(0.08),
                            ),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Remarks input
                  const Text(
                    'Verification Remarks / Reasons',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1A1A1A),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFF5F1EB),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.black.withOpacity(0.08)),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    child: TextField(
                      controller: remarksController,
                      maxLines: 2,
                      decoration: const InputDecoration(
                        hintText: 'Enter approval comments or rejection reasons...',
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
                  const SizedBox(height: 20),

                  ElevatedButton(
                    onPressed: () {
                      final remarks = remarksController.text.trim();
                      ref.read(crmProvider.notifier).verifyDocumentStatus(
                            lead.id,
                            doc.id,
                            selectedStatus,
                            remarks.isNotEmpty ? remarks : '',
                          );
                      Navigator.of(context).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Document status updated to $selectedStatus')),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1A1A1A),
                      foregroundColor: const Color(0xFFF5F1EB),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      minimumSize: const Size(double.infinity, 50),
                    ),
                    child: const Text(
                      'Save Verification Decision',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showTemplateCommunicationSheet(BuildContext context, Lead lead, String channel) {
    final state = ref.read(crmProvider);
    final templates = state.templates.where((t) => t.channel.toUpperCase() == channel.toUpperCase()).toList();
    final TextEditingController customMessageController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
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
                  Text(
                    'Select $channel Template',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF1A1A1A),
                    ),
                  ),
                  const SizedBox(height: 12),

                  if (templates.isEmpty) ...[
                    const Text(
                      'No templates found on backend. You can write a custom message to log and send:',
                      style: TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFFF5F1EB),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.black.withOpacity(0.08)),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      child: TextField(
                        controller: customMessageController,
                        maxLines: 3,
                        decoration: const InputDecoration(
                          hintText: 'Enter your custom message...',
                          hintStyle: TextStyle(color: Color(0xFF64748B), fontSize: 13),
                          border: InputBorder.none,
                        ),
                        style: const TextStyle(color: Color(0xFF1A1A1A), fontSize: 13),
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        final text = customMessageController.text.trim();
                        if (text.isNotEmpty) {
                          ref.read(crmProvider.notifier).logActivity(lead.id, channel, text);
                          Navigator.of(context).pop();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Custom $channel logged successfully.')),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1A1A1A),
                        foregroundColor: const Color(0xFFF5F1EB),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        minimumSize: const Size(double.infinity, 50),
                      ),
                      child: const Text('Send & Log Custom Message', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                    ),
                  ] else ...[
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxHeight: 300),
                      child: ListView.separated(
                        shrinkWrap: true,
                        itemCount: templates.length,
                        separatorBuilder: (context, index) => Divider(height: 1, color: Colors.black.withOpacity(0.05)),
                        itemBuilder: (context, index) {
                          final template = templates[index];
                          final personalized = template.content.replaceAll('\${name}', lead.name);

                          return ListTile(
                            contentPadding: const EdgeInsets.symmetric(vertical: 6),
                            title: Text(
                              template.name,
                              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF1A1A1A)),
                            ),
                            subtitle: Text(
                              personalized,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                            ),
                            trailing: const Icon(Icons.send, size: 16, color: Color(0xFF1A1A1A)),
                            onTap: () async {
                              final success = await ref.read(crmProvider.notifier).sendLeadTemplate(lead.id, template.id);
                              Navigator.of(context).pop();
                              if (success) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Template "${template.name}" dispatched successfully!')),
                                );
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Failed to dispatch template.')),
                                );
                              }
                            },
                          );
                        },
                      ),
                    ),
                  ],
                  const SizedBox(height: 24),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
