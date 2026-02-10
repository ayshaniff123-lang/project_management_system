class Project {
  final String? id;
  final String title;
  final String? abstract;
  final String? domain;
  final String? githubLink;
  final int? year;
  final String? fileUrl;

  Project({
    this.id,
    required this.title,
    this.abstract,
    this.domain,
    this.githubLink,
    this.year,
    this.fileUrl,
  });

  factory Project.fromMap(Map<String, dynamic> m) => Project(
        id: m['id']?.toString(),
        title: m['title'] ?? '',
        abstract: m['abstract'],
        domain: m['domain'],
        githubLink: m['github_link'],
        year: m['year'] is int ? m['year'] : (m['year'] != null ? int.tryParse(m['year'].toString()) : null),
        fileUrl: m['file_url'] ?? m['fileUrl'],
      );

  Map<String, dynamic> toMap() => {
        'title': title,
        if (abstract != null) 'abstract': abstract,
        if (domain != null) 'domain': domain,
        if (githubLink != null) 'github_link': githubLink,
        if (year != null) 'year': year,
        if (fileUrl != null) 'file_url': fileUrl,
      };
}
