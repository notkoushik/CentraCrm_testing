import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import '../models/crm_models.dart';

class CrmState {
  final List<Lead> leads;
  final List<Task> tasks;
  final List<Campaign> campaigns;
  final List<ProgramModel> programs;
  final List<MessageTemplateModel> templates;
  final UserModel? currentUser;
  final String? token;
  final String baseApiUrl;
  final bool isLoading;
  final String? errorMessage;

  CrmState({
    required this.leads,
    required this.tasks,
    required this.campaigns,
    required this.programs,
    this.templates = const [],
    this.currentUser,
    this.token,
    required this.baseApiUrl,
    required this.isLoading,
    this.errorMessage,
  });

  CrmState copyWith({
    List<Lead>? leads,
    List<Task>? tasks,
    List<Campaign>? campaigns,
    List<ProgramModel>? programs,
    List<MessageTemplateModel>? templates,
    UserModel? currentUser,
    bool clearCurrentUser = false,
    String? token,
    bool clearToken = false,
    String? baseApiUrl,
    bool? isLoading,
    String? errorMessage,
    bool clearErrorMessage = false,
  }) {
    return CrmState(
      leads: leads ?? this.leads,
      tasks: tasks ?? this.tasks,
      campaigns: campaigns ?? this.campaigns,
      programs: programs ?? this.programs,
      templates: templates ?? this.templates,
      currentUser: clearCurrentUser ? null : (currentUser ?? this.currentUser),
      token: clearToken ? null : (token ?? this.token),
      baseApiUrl: baseApiUrl ?? this.baseApiUrl,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearErrorMessage ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

class CrmNotifier extends Notifier<CrmState> {
  @override
  CrmState build() {
    return CrmState(
      leads: [
        Lead(
          id: 'mock-1',
          name: 'Ayesha Raza',
          stage: 'NEW',
          program: 'MBA — University of Manchester',
          source: 'Meta Ads',
          tag: 'HOT',
          email: 'ayesha.raza@gmail.com',
          phone: '+91 98765 43210',
          eduBackground: 'B.Com (Hons), Delhi University',
          notes: [
            LeadNote(
              content: 'Highly interested, wants scholarship details',
              createdAt: '2026-06-09T10:00:00Z',
              assignedTo: 'Jane',
            )
          ],
          timeline: [
            TimelineEvent(
              type: 'CALL',
              message: 'Spoke to student. Wants fee details.',
              time: '2026-06-09 10:00 AM',
              status: 'CONNECTED',
            ),
            TimelineEvent(
              type: 'EMAIL',
              message: 'Webinar Invitation sent',
              time: '2026-06-08 02:00 PM',
              status: 'SENT',
            ),
          ],
          createdAt: '2026-06-01T00:00:00Z',
        ),
      ],
      tasks: [
        Task(
          id: 'mock-task-1',
          time: '09:30 AM',
          title: 'Follow-up call with Ayesha',
          lead: 'Ayesha Raza',
          stage: 'NEW',
          stageColor: 'bg-blue-100 text-blue-700',
          done: false,
        ),
      ],
      campaigns: [
        Campaign(
          id: 'mock-camp-1',
          name: 'Meta Ads — MBA/MS 2026',
          leads: 145,
          cpl: 350,
          conversion: 4.8,
          active: true,
        ),
      ],
      programs: [],
      templates: [],
      baseApiUrl: 'http://192.168.1.171:5000/api/v1',
      isLoading: false,
    );
  }

  Future<bool> login(String email, String password, String baseApiUrl) async {
    state = state.copyWith(isLoading: true, clearErrorMessage: true, baseApiUrl: baseApiUrl);
    try {
      final response = await http.post(
        Uri.parse('$baseApiUrl/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      ).timeout(const Duration(seconds: 8));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final token = data['token'];
        final userJson = data['user'];
        final user = UserModel.fromJson(userJson);

        state = state.copyWith(
          isLoading: false,
          token: token,
          currentUser: user,
        );

        // Fetch actual data from backend
        await fetchAllData();
        return true;
      } else {
        final Map<String, dynamic> errorData = jsonDecode(response.body);
        final errorMsg = errorData['message'] ?? 'Failed to authenticate';
        state = state.copyWith(isLoading: false, errorMessage: errorMsg);
        return false;
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: 'Connection failed: ${e.toString()}');
      return false;
    }
  }

  Future<bool> registerUser({
    required String name,
    required String email,
    required String password,
    required String baseApiUrl,
  }) async {
    state = state.copyWith(isLoading: true, clearErrorMessage: true, baseApiUrl: baseApiUrl);
    try {
      final response = await http.post(
        Uri.parse('$baseApiUrl/auth/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'name': name,
          'email': email,
          'password': password,
          'roleType': 'STANDARDUSER',
        }),
      ).timeout(const Duration(seconds: 8));

      if (response.statusCode == 201 || response.statusCode == 200) {
        return await login(email, password, baseApiUrl);
      } else {
        final Map<String, dynamic> errorData = jsonDecode(response.body);
        final errorMsg = errorData['message'] ?? 'Failed to register';
        state = state.copyWith(isLoading: false, errorMessage: errorMsg);
        return false;
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: 'Registration failed: ${e.toString()}');
      return false;
    }
  }

  void logout() {
    state = state.copyWith(
      clearCurrentUser: true,
      clearToken: true,
      leads: [],
      tasks: [],
      campaigns: [],
      programs: [],
      templates: [],
      clearErrorMessage: true,
    );
  }

  Future<void> fetchAllData() async {
    final token = state.token;
    final baseApiUrl = state.baseApiUrl;
    if (token == null) return;

    state = state.copyWith(isLoading: true, clearErrorMessage: true);

    try {
      // 1. Fetch Programs
      final progResponse = await http.get(
        Uri.parse('$baseApiUrl/programs'),
        headers: {'Authorization': 'Bearer $token'},
      );
      List<ProgramModel> fetchedPrograms = [];
      if (progResponse.statusCode == 200) {
        final List<dynamic> progJson = jsonDecode(progResponse.body);
        fetchedPrograms = progJson.map((p) => ProgramModel.fromJson(p)).toList();
      }

      // 2. Fetch Leads
      final leadsResponse = await http.get(
        Uri.parse('$baseApiUrl/leads'),
        headers: {'Authorization': 'Bearer $token'},
      );

      List<Lead> fetchedLeads = [];
      if (leadsResponse.statusCode == 200) {
        final List<dynamic> leadsJson = jsonDecode(leadsResponse.body);
        fetchedLeads = leadsJson.map((l) {
          final List<dynamic> rawNotes = l['notes'] ?? [];
          final notes = rawNotes.map((n) {
            return LeadNote(
              content: n['content'] ?? '',
              createdAt: n['createdAt'] ?? '',
              assignedTo: n['assignedTo']?.toString() ?? 'Agent',
            );
          }).toList();

          // Parse application and documents
          final appJson = l['application'];
          final application = appJson != null ? ApplicationModel.fromJson(appJson) : null;

          // Parse webinar registrations
          final List<dynamic> webinarRegsJson = l['webinarRegistrations'] ?? [];
          final webinarRegs = webinarRegsJson.map((w) => WebinarRegistrationModel.fromJson(w)).toList();

          final List<TimelineEvent> timelineEvents = [
            TimelineEvent(
              type: 'NOTE',
              message: 'Lead record fetched from backend.',
              time: l['createdAt'] != null
                  ? DateTime.parse(l['createdAt']).toLocal().toString().substring(0, 16)
                  : 'Just now',
            )
          ];

          // Add webinar events to timeline
          for (final reg in webinarRegs) {
            timelineEvents.add(
              TimelineEvent(
                type: 'NOTE',
                message: '${reg.attended ? "Attended" : "Registered for"} Webinar: ${reg.webinar.title}',
                time: reg.createdAt.isNotEmpty
                    ? DateTime.parse(reg.createdAt).toLocal().toString().substring(0, 16)
                    : 'Just now',
                status: reg.attended ? 'ATTENDED' : 'REGISTERED',
              ),
            );
          }

          // Add communication logs to timeline
          final List<dynamic> commsJson = l['communicationLogs'] ?? [];
          for (final c in commsJson) {
            timelineEvents.add(
              TimelineEvent(
                type: c['type'] ?? 'CALL',
                message: c['message'] ?? '',
                time: c['timestamp'] != null
                    ? DateTime.parse(c['timestamp']).toLocal().toString().substring(0, 16)
                    : 'Just now',
                status: c['result'],
              ),
            );
          }

          return Lead(
            id: l['id'] ?? '',
            name: l['name'] ?? '',
            stage: l['stage'] ?? 'NEW',
            program: l['program']?['name'] ?? 'General Inquiry',
            source: l['leadSource'] ?? 'Direct',
            tag: l['priority'] == 2 ? 'HOT' : l['priority'] == 1 ? 'WARM' : 'COLD',
            email: l['email'] ?? '',
            phone: l['phone'] ?? '',
            eduBackground: l['eduBackground'] ?? 'Not submitted',
            notes: notes,
            timeline: timelineEvents,
            createdAt: l['createdAt'] ?? '',
            application: application,
            webinarRegistrations: webinarRegs,
          );
        }).toList();
      }

      // 3. Fetch Tasks (Followups)
      final tasksResponse = await http.get(
        Uri.parse('$baseApiUrl/leads/follow-ups/upcoming?includeCompleted=true'),
        headers: {'Authorization': 'Bearer $token'},
      );

      List<Task> fetchedTasks = [];
      if (tasksResponse.statusCode == 200) {
        final List<dynamic> tasksJson = jsonDecode(tasksResponse.body);
        fetchedTasks = tasksJson.map((t) {
          final isCompleted = t['completedAt'] != null;
          return Task(
            id: t['id'] ?? '',
            time: t['scheduledAt'] != null
                ? DateTime.parse(t['scheduledAt']).toLocal().toString().substring(11, 16)
                : '12:00 PM',
            title: t['notes'] ?? 'Follow up',
            lead: t['lead']?['name'] ?? 'Student',
            stage: t['lead']?['stage'] ?? 'NEW',
            stageColor: 'bg-blue-100 text-blue-700',
            done: isCompleted,
          );
        }).toList();
      }

      // 4. Fetch Campaigns (restricted to ADMIN/SUPERADMIN roles)
      List<Campaign> fetchedCampaigns = [];
      if (state.currentUser?.role == 'ADMIN' || state.currentUser?.role == 'SUPERADMIN') {
        final campaignResponse = await http.get(
          Uri.parse('$baseApiUrl/marketing'),
          headers: {'Authorization': 'Bearer $token'},
        );
        if (campaignResponse.statusCode == 200) {
          final List<dynamic> campaignJson = jsonDecode(campaignResponse.body);
          fetchedCampaigns = campaignJson.map((c) {
            return Campaign(
              id: c['id'] ?? '',
              name: c['name'] ?? '',
              leads: c['leads']?.length ?? 0,
              cpl: 250,
              conversion: 5.0,
              active: c['status'] == 'ACTIVE' || c['status'] == 'SENT',
            );
          }).toList();
        }
      }

      // 5. Fetch Templates
      final templatesResponse = await http.get(
        Uri.parse('$baseApiUrl/templates'),
        headers: {'Authorization': 'Bearer $token'},
      );
      List<MessageTemplateModel> fetchedTemplates = [];
      if (templatesResponse.statusCode == 200) {
        final List<dynamic> templatesJson = jsonDecode(templatesResponse.body);
        fetchedTemplates = templatesJson.map((t) => MessageTemplateModel.fromJson(t)).toList();
      }

      state = state.copyWith(
        isLoading: false,
        leads: fetchedLeads,
        tasks: fetchedTasks,
        campaigns: fetchedCampaigns.isNotEmpty ? fetchedCampaigns : state.campaigns,
        programs: fetchedPrograms,
        templates: fetchedTemplates,
      );

    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Fetch failed: ${e.toString()}',
      );
    }
  }

  Future<void> toggleTask(String id) async {
    final token = state.token;
    final baseApiUrl = state.baseApiUrl;

    // Local toggle
    state = state.copyWith(
      tasks: state.tasks.map((t) {
        if (t.id == id) {
          return t.copyWith(done: !t.done);
        }
        return t;
      }).toList(),
    );

    if (token == null) return;

    try {
      await http.patch(
        Uri.parse('$baseApiUrl/leads/follow-ups/$id/complete'),
        headers: {'Authorization': 'Bearer $token'},
      );
      // Refresh list
      await fetchAllData();
    } catch (e) {
      // Ignored for offline experience resilience
    }
  }

  Future<void> addLead(Lead lead) async {
    final token = state.token;
    final baseApiUrl = state.baseApiUrl;

    // Add locally first
    state = state.copyWith(
      leads: [lead, ...state.leads],
    );

    if (token == null) return;

    try {
      // Match program name to a real program ID from database
      String? interestedProgramId;
      if (state.programs.isNotEmpty) {
        final matchingProg = state.programs.firstWhere(
          (p) => p.name.toLowerCase() == lead.program.toLowerCase() || p.id == lead.program,
          orElse: () => state.programs.first,
        );
        interestedProgramId = matchingProg.id;
      }

      await http.post(
        Uri.parse('$baseApiUrl/leads'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'name': lead.name,
          'phone': lead.phone,
          'email': lead.email,
          'leadSource': lead.source,
          'interestedProgramId': interestedProgramId,
          'eduBackground': lead.eduBackground,
        }),
      );

      // Refresh list
      await fetchAllData();
    } catch (e) {
      // Offline fallback
    }
  }

  Future<void> updateLeadStage(String id, String newStage) async {
    final token = state.token;
    final baseApiUrl = state.baseApiUrl;

    // Local update
    state = state.copyWith(
      leads: state.leads.map((l) {
        if (l.id == id) {
          return l.copyWith(
            stage: newStage,
            timeline: [
              TimelineEvent(
                type: 'NOTE',
                message: 'Stage updated to $newStage',
                time: 'Just now',
              ),
              ...l.timeline,
            ],
          );
        }
        return l;
      }).toList(),
    );

    if (token == null) return;

    try {
      await http.patch(
        Uri.parse('$baseApiUrl/leads/$id/stage'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'stage': newStage}),
      );
      await fetchAllData();
    } catch (e) {
      // Offline fallback
    }
  }

  Future<void> logActivity(String leadId, String type, String content) async {
    final token = state.token;
    final baseApiUrl = state.baseApiUrl;

    // Local update
    state = state.copyWith(
      leads: state.leads.map((l) {
        if (l.id == leadId) {
          final newEvent = TimelineEvent(
            type: type,
            message: content,
            time: 'Just now',
            status: type != 'NOTE' ? 'LOGGED' : null,
          );
          final newNote = type == 'NOTE'
              ? [LeadNote(content: content, createdAt: DateTime.now().toIso8601String(), assignedTo: state.currentUser?.name ?? 'Jane'), ...l.notes]
              : l.notes;
          return l.copyWith(
            timeline: [newEvent, ...l.timeline],
            notes: newNote,
          );
        }
        return l;
      }).toList(),
    );

    if (token == null) return;

    try {
      if (type == 'NOTE') {
        await http.post(
          Uri.parse('$baseApiUrl/leads/$leadId/notes'),
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
          body: jsonEncode({'content': content}),
        );
      } else {
        await http.post(
          Uri.parse('$baseApiUrl/leads/$leadId/log-interaction'),
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
          body: jsonEncode({
            'type': type,
            'message': content,
            'result': 'CONNECTED',
          }),
        );
      }
      await fetchAllData();
    } catch (e) {
      // Offline fallback
    }
  }

  Future<void> addTask(Task task) async {
    final token = state.token;
    final baseApiUrl = state.baseApiUrl;

    state = state.copyWith(
      tasks: [task, ...state.tasks],
    );

    if (token == null) return;

    try {
      // Find matching lead ID
      final matchingLead = state.leads.firstWhere(
        (l) => l.name.toLowerCase() == task.lead.toLowerCase(),
        orElse: () => state.leads.first,
      );

      final scheduledAt = DateTime.now().add(const Duration(days: 1)).toUtc().toIso8601String();

      await http.post(
        Uri.parse('$baseApiUrl/leads/${matchingLead.id}/follow-up'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'notes': task.title,
          'scheduledAt': scheduledAt,
        }),
      );
      await fetchAllData();
    } catch (e) {
      // Offline fallback
    }
  }

  void toggleCampaign(String id) {
    state = state.copyWith(
      campaigns: state.campaigns.map((c) {
        if (c.id == id) {
          return c.copyWith(active: !c.active);
        }
        return c;
      }).toList(),
    );
  }

  Future<void> updateApplicationStatus(String leadId, String appId, String newStatus) async {
    final token = state.token;
    final baseApiUrl = state.baseApiUrl;

    state = state.copyWith(
      leads: state.leads.map((l) {
        if (l.id == leadId && l.application != null) {
          return l.copyWith(
            application: ApplicationModel(
              id: l.application!.id,
              status: newStatus,
              submittedAt: l.application!.submittedAt,
              createdAt: l.application!.createdAt,
              documents: l.application!.documents,
              programId: l.application!.programId,
            ),
          );
        }
        return l;
      }).toList(),
    );

    if (token == null) return;

    try {
      await http.patch(
        Uri.parse('$baseApiUrl/applications/$appId/status'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'status': newStatus}),
      );
      await fetchAllData();
    } catch (e) {
      // ignore
    }
  }

  Future<void> verifyDocumentStatus(String leadId, String docId, String status, String remarks) async {
    final token = state.token;
    final baseApiUrl = state.baseApiUrl;

    state = state.copyWith(
      leads: state.leads.map((l) {
        if (l.id == leadId && l.application != null) {
          final updatedDocs = l.application!.documents.map((d) {
            if (d.id == docId) {
              return DocumentModel(
                id: d.id,
                applicationId: d.applicationId,
                type: d.type,
                url: d.url,
                name: d.name,
                status: status,
                remarks: remarks,
                createdAt: d.createdAt,
              );
            }
            return d;
          }).toList();

          return l.copyWith(
            application: ApplicationModel(
              id: l.application!.id,
              status: l.application!.status,
              submittedAt: l.application!.submittedAt,
              createdAt: l.application!.createdAt,
              documents: updatedDocs,
              programId: l.application!.programId,
            ),
          );
        }
        return l;
      }).toList(),
    );

    if (token == null) return;

    try {
      await http.patch(
        Uri.parse('$baseApiUrl/documents/$docId/verify'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'status': status, 'remarks': remarks}),
      );
      await fetchAllData();
    } catch (e) {
      // ignore
    }
  }

  Future<bool> sendLeadTemplate(String leadId, String templateId) async {
    final token = state.token;
    final baseApiUrl = state.baseApiUrl;
    if (token == null) return false;

    try {
      final response = await http.post(
        Uri.parse('$baseApiUrl/leads/$leadId/send-template'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'templateId': templateId}),
      );
      await fetchAllData();
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}

final crmProvider = NotifierProvider<CrmNotifier, CrmState>(() {
  return CrmNotifier();
});
