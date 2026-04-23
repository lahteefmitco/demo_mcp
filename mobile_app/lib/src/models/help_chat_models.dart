class HelpCitation {
  const HelpCitation({
    required this.id,
    required this.title,
    this.section,
  });

  final String id;
  final String title;
  final String? section;

  factory HelpCitation.fromJson(Map<String, dynamic> json) {
    return HelpCitation(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      section: json['section'] as String?,
    );
  }
}

class HelpChatReply {
  const HelpChatReply({required this.reply, required this.citations});

  final String reply;
  final List<HelpCitation> citations;

  factory HelpChatReply.fromJson(Map<String, dynamic> json) {
    final citationsJson = json['citations'] as List<dynamic>? ?? const [];
    return HelpChatReply(
      reply: json['reply'] as String? ?? '',
      citations: citationsJson
          .map((c) => HelpCitation.fromJson(c as Map<String, dynamic>))
          .toList(),
    );
  }
}

