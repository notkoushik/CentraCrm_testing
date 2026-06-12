class TimelineEvent {
  final String type; // CALL, WHATSAPP, EMAIL, NOTE
  final String message;
  final String time;
  final String? status;

  TimelineEvent({
    required this.type,
    required this.message,
    required this.time,
    this.status,
  });
}

class LeadNote {
  final String content;
  final String createdAt;
  final String assignedTo;

  LeadNote({
    required this.content,
    required this.createdAt,
    required this.assignedTo,
  });
}

class Lead {
  final String id;
  final String name;
  final String stage;
  final String program;
  final String source;
  final String tag; // HOT, WARM, COLD
  final String email;
  final String phone;
  final String eduBackground;
  final List<LeadNote> notes;
  final List<TimelineEvent> timeline;
  final String createdAt;
  final ApplicationModel? application;
  final List<WebinarRegistrationModel> webinarRegistrations;

  Lead({
    required this.id,
    required this.name,
    required this.stage,
    required this.program,
    required this.source,
    required this.tag,
    required this.email,
    required this.phone,
    required this.eduBackground,
    required this.notes,
    required this.timeline,
    required this.createdAt,
    this.application,
    this.webinarRegistrations = const [],
  });

  Lead copyWith({
    String? id,
    String? name,
    String? stage,
    String? program,
    String? source,
    String? tag,
    String? email,
    String? phone,
    String? eduBackground,
    List<LeadNote>? notes,
    List<TimelineEvent>? timeline,
    String? createdAt,
    ApplicationModel? application,
    List<WebinarRegistrationModel>? webinarRegistrations,
  }) {
    return Lead(
      id: id ?? this.id,
      name: name ?? this.name,
      stage: stage ?? this.stage,
      program: program ?? this.program,
      source: source ?? this.source,
      tag: tag ?? this.tag,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      eduBackground: eduBackground ?? this.eduBackground,
      notes: notes ?? this.notes,
      timeline: timeline ?? this.timeline,
      createdAt: createdAt ?? this.createdAt,
      application: application ?? this.application,
      webinarRegistrations: webinarRegistrations ?? this.webinarRegistrations,
    );
  }
}

class Task {
  final String id;
  final String time;
  final String title;
  final String lead;
  final String stage;
  final String stageColor;
  final bool done;

  Task({
    required this.id,
    required this.time,
    required this.title,
    required this.lead,
    required this.stage,
    required this.stageColor,
    required this.done,
  });

  Task copyWith({
    String? id,
    String? time,
    String? title,
    String? lead,
    String? stage,
    String? stageColor,
    bool? done,
  }) {
    return Task(
      id: id ?? this.id,
      time: time ?? this.time,
      title: title ?? this.title,
      lead: lead ?? this.lead,
      stage: stage ?? this.stage,
      stageColor: stageColor ?? this.stageColor,
      done: done ?? this.done,
    );
  }
}

class Campaign {
  final String id;
  final String name;
  final int leads;
  final int cpl;
  final double conversion;
  final bool active;

  Campaign({
    required this.id,
    required this.name,
    required this.leads,
    required this.cpl,
    required this.conversion,
    required this.active,
  });

  Campaign copyWith({
    String? id,
    String? name,
    int? leads,
    int? cpl,
    double? conversion,
    bool? active,
  }) {
    return Campaign(
      id: id ?? this.id,
      name: name ?? this.name,
      leads: leads ?? this.leads,
      cpl: cpl ?? this.cpl,
      conversion: conversion ?? this.conversion,
      active: active ?? this.active,
    );
  }
}

class Counselor {
  final String name;
  final int leads;
  final int converted;
  final double rate;
  final String avatar;
  final int rank;

  Counselor({
    required this.name,
    required this.leads,
    required this.converted,
    required this.rate,
    required this.avatar,
    required this.rank,
  });
}

class UserModel {
  final String id;
  final String name;
  final String email;
  final String role;
  final String tenantId;
  final String sector;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.tenantId,
    required this.sector,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      role: json['role'] ?? '',
      tenantId: json['tenantId'] ?? '',
      sector: json['sector'] ?? 'GENERIC',
    );
  }
}

class ProgramModel {
  final String id;
  final String name;
  final double baseFee;

  ProgramModel({
    required this.id,
    required this.name,
    required this.baseFee,
  });

  factory ProgramModel.fromJson(Map<String, dynamic> json) {
    return ProgramModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      baseFee: (json['baseFee'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

class DocumentModel {
  final String id;
  final String applicationId;
  final String type;
  final String url;
  final String name;
  final String status;
  final String? remarks;
  final String createdAt;

  DocumentModel({
    required this.id,
    required this.applicationId,
    required this.type,
    required this.url,
    required this.name,
    required this.status,
    this.remarks,
    required this.createdAt,
  });

  factory DocumentModel.fromJson(Map<String, dynamic> json) {
    return DocumentModel(
      id: json['id'] ?? '',
      applicationId: json['applicationId'] ?? '',
      type: json['type'] ?? '',
      url: json['url'] ?? '',
      name: json['name'] ?? 'Document',
      status: json['status'] ?? 'PENDING',
      remarks: json['remarks'],
      createdAt: json['createdAt'] ?? '',
    );
  }
}

class ApplicationModel {
  final String id;
  final String status;
  final String? submittedAt;
  final String createdAt;
  final List<DocumentModel> documents;
  final String programId;

  ApplicationModel({
    required this.id,
    required this.status,
    this.submittedAt,
    required this.createdAt,
    required this.documents,
    required this.programId,
  });

  factory ApplicationModel.fromJson(Map<String, dynamic> json) {
    final List<dynamic> docsJson = json['documents'] ?? [];
    final docs = docsJson.map((d) => DocumentModel.fromJson(d)).toList();

    return ApplicationModel(
      id: json['id'] ?? '',
      status: json['status'] ?? 'STARTED',
      submittedAt: json['submittedAt'],
      createdAt: json['createdAt'] ?? '',
      documents: docs,
      programId: json['programId'] ?? '',
    );
  }
}

class WebinarModel {
  final String id;
  final String title;
  final String? description;
  final String date;
  final String? meetingUrl;

  WebinarModel({
    required this.id,
    required this.title,
    this.description,
    required this.date,
    this.meetingUrl,
  });

  factory WebinarModel.fromJson(Map<String, dynamic> json) {
    return WebinarModel(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'],
      date: json['date'] ?? '',
      meetingUrl: json['meetingUrl'],
    );
  }
}

class WebinarRegistrationModel {
  final String id;
  final bool attended;
  final String createdAt;
  final WebinarModel webinar;

  WebinarRegistrationModel({
    required this.id,
    required this.attended,
    required this.createdAt,
    required this.webinar,
  });

  factory WebinarRegistrationModel.fromJson(Map<String, dynamic> json) {
    return WebinarRegistrationModel(
      id: json['id'] ?? '',
      attended: json['attended'] ?? false,
      createdAt: json['createdAt'] ?? '',
      webinar: WebinarModel.fromJson(json['webinar'] ?? {}),
    );
  }
}

class MessageTemplateModel {
  final String id;
  final String name;
  final String channel;
  final String? subject;
  final String content;

  MessageTemplateModel({
    required this.id,
    required this.name,
    required this.channel,
    this.subject,
    required this.content,
  });

  factory MessageTemplateModel.fromJson(Map<String, dynamic> json) {
    return MessageTemplateModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      channel: json['channel'] ?? '',
      subject: json['subject'],
      content: json['content'] ?? '',
    );
  }
}
