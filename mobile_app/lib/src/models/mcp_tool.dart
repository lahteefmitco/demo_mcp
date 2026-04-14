class McpTool {
  const McpTool({required this.name, required this.description});

  final String name;
  final String description;

  factory McpTool.fromJson(Map<String, dynamic> json) {
    return McpTool(
      name: json['name'] as String? ?? '',
      description: json['description'] as String? ?? '',
    );
  }
}
