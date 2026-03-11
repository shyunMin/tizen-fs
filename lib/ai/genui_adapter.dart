import 'package:google_generative_ai/google_generative_ai.dart' as gai;
import 'package:genui/genui.dart';

/// Converts a genui [AiTool] (like SurfaceUpdateTool) into a
/// Google Generative AI [FunctionDeclaration].
///
/// This allows us to inject genui's built-in tools natively into Gemini.
gai.FunctionDeclaration convertGenuiToolToFunctionDeclaration(AiTool tool) {
  // genui AiTool.parameters is an extension over Map<String, Object?>
  final schemaMap = tool.parameters as Map<String, dynamic>;
  final gaiSchema = _convertSchema(schemaMap);

  return gai.FunctionDeclaration(tool.name, tool.description, gaiSchema);
}

gai.Schema _convertSchema(Map<String, dynamic> schemaMap) {
  final type = schemaMap['type'] as String?;
  final description = schemaMap['description'] as String?;
  if (type == 'string') {
    final enumValues = (schemaMap['enum'] as List<dynamic>?)?.cast<String>();
    if (enumValues != null && enumValues.isNotEmpty) {
      return gai.Schema.enumString(
        description: description,
        enumValues: enumValues,
      );
    }
    return gai.Schema.string(description: description);
  } else if (type == 'integer') {
    return gai.Schema.integer(description: description);
  } else if (type == 'number') {
    return gai.Schema.number(description: description);
  } else if (type == 'boolean') {
    return gai.Schema.boolean(description: description);
  } else if (type == 'array') {
    final items = schemaMap['items'] as Map<String, dynamic>?;
    return gai.Schema.array(
      description: description,
      items: items != null ? _convertSchema(items) : gai.Schema.string(),
    );
  } else if (type == 'object') {
    final properties = schemaMap['properties'] as Map<String, dynamic>? ?? {};
    final requiredProps =
        (schemaMap['required'] as List<dynamic>?)?.cast<String>() ?? [];

    final gaiProps = <String, gai.Schema>{};
    for (final entry in properties.entries) {
      gaiProps[entry.key] = _convertSchema(entry.value as Map<String, dynamic>);
    }
    return gai.Schema.object(
      description: description,
      properties: gaiProps,
      requiredProperties: requiredProps,
    );
  }

  // Fallback for anyOf/allOf or unspecified complex types
  return gai.Schema.string(description: description ?? 'Unknown structure');
}
