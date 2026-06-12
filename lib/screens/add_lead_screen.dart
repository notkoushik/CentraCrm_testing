import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../state/crm_state.dart';
import '../models/crm_models.dart';

class AddLeadScreen extends ConsumerStatefulWidget {
  const AddLeadScreen({super.key});

  @override
  ConsumerState<AddLeadScreen> createState() => _AddLeadScreenState();
}

class _AddLeadScreenState extends ConsumerState<AddLeadScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  String? _selectedProgram;
  String? _selectedSource;
  String _selectedTag = 'WARM';
  bool _isSaved = false;

  final List<String> _sources = ['Meta Ads', 'Google Ads', 'Website', 'Referral', 'Walk-in', 'LinkedIn', 'YouTube', 'Other'];
  final List<String> _programs = [
    'MBA — University of Manchester',
    'MS Data Science — TU Berlin',
    'BBA — University of Toronto',
    'LLM — NUS Singapore',
    'MPH — UCL London',
    'MS Computer Science — Georgia Tech',
    'BEng — University of Melbourne',
  ];

  @override
  Widget build(BuildContext context) {
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
                          'Add New Lead',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFF1A1A1A),
                          ),
                        ),
                        Text(
                          'STUDENT ADMISSION PIPELINE',
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

            // Scrollable Form
            Expanded(
              child: Form(
                key: _formKey,
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  children: [
                    // Personal info section
                    _buildSectionHeader('Personal Info'),
                    _buildFloatInput(
                      controller: _nameController,
                      label: 'Full Name',
                      validator: (val) => val == null || val.trim().isEmpty ? 'Name is required' : null,
                    ),
                    const SizedBox(height: 12),
                    _buildFloatInput(
                      controller: _emailController,
                      label: 'Email Address',
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 12),
                    _buildFloatInput(
                      controller: _phoneController,
                      label: 'Phone Number',
                      keyboardType: TextInputType.phone,
                      validator: (val) => val == null || val.trim().isEmpty ? 'Phone number is required' : null,
                    ),
                    const SizedBox(height: 20),

                    // Program & Source
                    _buildSectionHeader('Program & Source'),
                    _buildSelectDropdown(
                      label: 'Interested Program',
                      value: _selectedProgram,
                      options: _programs,
                      onChanged: (val) {
                        setState(() {
                          _selectedProgram = val;
                        });
                      },
                    ),
                    const SizedBox(height: 12),
                    _buildSelectDropdown(
                      label: 'Lead Source',
                      value: _selectedSource,
                      options: _sources,
                      onChanged: (val) {
                        setState(() {
                          _selectedSource = val;
                        });
                      },
                    ),
                    const SizedBox(height: 20),

                    // Lead Temperature
                    _buildSectionHeader('Lead Temperature'),
                    Row(
                      children: [
                        _buildTemperatureButton(
                          value: 'HOT',
                          label: 'Hot',
                          bg: const Color(0xFFFFF1F2),
                          border: const Color(0xFFFECDD3),
                          text: const Color(0xFFE11D48),
                          dot: const Color(0xFFE11D48),
                        ),
                        const SizedBox(width: 8),
                        _buildTemperatureButton(
                          value: 'WARM',
                          label: 'Warm',
                          bg: const Color(0xFFFEF3C7),
                          border: const Color(0xFFFDE68A),
                          text: const Color(0xFFD97706),
                          dot: const Color(0xFFD97706),
                        ),
                        const SizedBox(width: 8),
                        _buildTemperatureButton(
                          value: 'COLD',
                          label: 'Cold',
                          bg: const Color(0xFFEFF6FF),
                          border: const Color(0xFFBFDBFE),
                          text: const Color(0xFF2563EB),
                          dot: const Color(0xFF2563EB),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Initial Notes
                    _buildSectionHeader('Initial Notes'),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: Colors.black.withOpacity(0.12)),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      child: TextField(
                        controller: _notesController,
                        maxLines: 3,
                        decoration: const InputDecoration(
                          hintText: 'E.g. Student wants scholarship info, referred by alumni…',
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
                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        color: const Color(0xFFF5F1EB),
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        child: SafeArea(
          child: ElevatedButton(
            onPressed: _handleSubmit,
            style: ElevatedButton.styleFrom(
              backgroundColor: _isSaved ? const Color(0xFF10B981) : const Color(0xFF1A1A1A),
              foregroundColor: const Color(0xFFF5F1EB),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (_isSaved) ...[
                  const Icon(LucideIcons.check, size: 16),
                  const SizedBox(width: 8),
                  const Text(
                    'LEAD CREATED!',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900, letterSpacing: 0.5),
                  ),
                ] else
                  const Text(
                    'CREATE LEAD',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900, letterSpacing: 0.5),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4.0, bottom: 8.0, top: 12.0),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          fontSize: 9,
          fontWeight: FontWeight.w900,
          color: const Color(0xFF94A3B8),
          letterSpacing: 1.0,
        ),
      ),
    );
  }

  Widget _buildFloatInput({
    required TextEditingController controller,
    required String label,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.black.withOpacity(0.12)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        validator: validator,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(
            color: Color(0xFF94A3B8),
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
          floatingLabelBehavior: FloatingLabelBehavior.auto,
          border: InputBorder.none,
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(vertical: 8),
        ),
        style: const TextStyle(
          color: Color(0xFF1A1A1A),
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildSelectDropdown({
    required String label,
    required String? value,
    required List<String> options,
    required ValueChanged<String?> onChanged,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.black.withOpacity(0.12)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: DropdownButtonFormField<String>(
        value: value,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(
            color: Color(0xFF94A3B8),
            fontSize: 9,
            fontWeight: FontWeight.bold,
          ),
          border: InputBorder.none,
          isDense: true,
          contentPadding: EdgeInsets.zero,
        ),
        icon: const Icon(LucideIcons.chevronDown, size: 16, color: Color(0xFF94A3B8)),
        style: const TextStyle(
          color: Color(0xFF1A1A1A),
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
        onChanged: onChanged,
        items: options.map<DropdownMenuItem<String>>((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text(
              value,
              style: const TextStyle(fontSize: 13),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildTemperatureButton({
    required String value,
    required String label,
    required Color bg,
    required Color border,
    required Color text,
    required Color dot,
  }) {
    final isSelected = _selectedTag == value;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedTag = value;
          });
        },
        child: Container(
          decoration: BoxDecoration(
            color: isSelected ? bg : Colors.white,
            border: Border.all(color: isSelected ? border : Colors.black.withOpacity(0.08), width: 2),
            borderRadius: BorderRadius.circular(14),
          ),
          padding: const EdgeInsets.symmetric(vertical: 14),
          child: Column(
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: isSelected ? dot : const Color(0xFFE2E8F0),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                label.toUpperCase(),
                style: TextStyle(
                  color: isSelected ? text : const Color(0xFF94A3B8),
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _handleSubmit() {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isSaved = true;
      });

      final newLead = Lead(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        phone: _phoneController.text.trim(),
        program: _selectedProgram ?? 'N/A',
        source: _selectedSource ?? 'Direct Inquiry',
        tag: _selectedTag,
        stage: 'NEW',
        eduBackground: 'Not submitted',
        notes: _notesController.text.isNotEmpty
            ? [LeadNote(content: _notesController.text, createdAt: DateTime.now().toIso8601String(), assignedTo: 'Jane')]
            : [],
        timeline: [
          TimelineEvent(
            type: 'NOTE',
            message: 'Lead created in pipeline.',
            time: 'Just now',
          )
        ],
        createdAt: DateTime.now().toIso8601String(),
      );

      ref.read(crmProvider.notifier).addLead(newLead);

      Future.delayed(const Duration(milliseconds: 900), () {
        if (mounted) {
          Navigator.of(context).pop();
        }
      });
    }
  }
}
