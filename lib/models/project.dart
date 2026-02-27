class Project {
  final String? id;
  final String title;
  final String? abstract;
  final String? domain;
  final String? domainId;       // FK → domains(id)
  final String projectType;
  final String? guideName;
  final String? guideId;        // FK → users(id)
  final String? studentId;      // FK → users(id)
  final List<String> teamMembers;
  final String? contactEmail;
  final String? contactPhone;
  final String? githubLink;
  final int? year;
  final bool extensionPossible;
  final DateTime? createdAt;

  const Project({
    this.id,
    required this.title,
    this.abstract,
    this.domain,
    this.domainId,
    this.projectType = 'mini',
    this.guideName,
    this.guideId,
    this.studentId,
    this.teamMembers = const [],
    this.contactEmail,
    this.contactPhone,
    this.githubLink,
    this.year,
    this.extensionPossible = false,
    this.createdAt,
  }) : assert(
          projectType == 'mini' || projectType == 'major',
          'projectType must be mini or major',
        );

  factory Project.fromMap(Map<String, dynamic> map) {
    return Project(
      id: map['id'] as String?,
      title: map['title'] as String? ?? '',
      abstract: map['abstract'] as String?,
      domain: map['domain'] as String?,
      domainId: map['domain_id'] as String?,
      projectType: map['project_type'] as String? ?? 'mini',
      guideName: map['guide_name'] as String?,
      guideId: map['guide_id'] as String?,
      studentId: map['student_id'] as String?,
      teamMembers: map['team_members'] != null
          ? List<String>.from(map['team_members'] as List)
          : [],
      contactEmail: map['contact_email'] as String?,
      contactPhone: map['contact_phone'] as String?,
      githubLink: map['github_link'] as String?,
      year: map['year'] as int?,
      extensionPossible: map['extension_possible'] as bool? ?? false,
      createdAt: map['created_at'] != null
          ? DateTime.parse(map['created_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'title': title,
      if (abstract != null) 'abstract': abstract,
      if (domain != null) 'domain': domain,
      if (domainId != null) 'domain_id': domainId,
      'project_type': projectType,
      if (guideName != null) 'guide_name': guideName,
      if (guideId != null) 'guide_id': guideId,
      if (studentId != null) 'student_id': studentId,
      'team_members': teamMembers,
      if (contactEmail != null) 'contact_email': contactEmail,
      if (contactPhone != null) 'contact_phone': contactPhone,
      if (githubLink != null) 'github_link': githubLink,
      if (year != null) 'year': year,
      'extension_possible': extensionPossible,
    };
  }

  Project copyWith({
    String? id,
    String? title,
    String? abstract,
    String? domain,
    String? domainId,
    String? projectType,
    String? guideName,
    String? guideId,
    String? studentId,
    List<String>? teamMembers,
    String? contactEmail,
    String? contactPhone,
    String? githubLink,
    int? year,
    bool? extensionPossible,
    DateTime? createdAt,
  }) {
    return Project(
      id: id ?? this.id,
      title: title ?? this.title,
      abstract: abstract ?? this.abstract,
      domain: domain ?? this.domain,
      domainId: domainId ?? this.domainId,
      projectType: projectType ?? this.projectType,
      guideName: guideName ?? this.guideName,
      guideId: guideId ?? this.guideId,
      studentId: studentId ?? this.studentId,
      teamMembers: teamMembers ?? this.teamMembers,
      contactEmail: contactEmail ?? this.contactEmail,
      contactPhone: contactPhone ?? this.contactPhone,
      githubLink: githubLink ?? this.githubLink,
      year: year ?? this.year,
      extensionPossible: extensionPossible ?? this.extensionPossible,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}