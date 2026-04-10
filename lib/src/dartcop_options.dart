import 'dart:io' show File;

import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:yaml/yaml.dart';

/// Holds the configured thresholds from the `dartcop:` section of
/// `analysis_options.yaml`. A `null` value means "use the rule's default".
class DartcopOptions {
  final int? maxCyclomaticComplexity;
  final int? maxLinesPerFunction;
  final int? maxNestingDepth;
  final int? maxParameters;
  final int? maxMethodsPerClass;

  const DartcopOptions({
    this.maxCyclomaticComplexity,
    this.maxLinesPerFunction,
    this.maxNestingDepth,
    this.maxParameters,
    this.maxMethodsPerClass,
  });

  static const DartcopOptions empty = DartcopOptions();

  static final Map<String, DartcopOptions> _cache = {};

  /// Reads `analysis_options.yaml` from the package root (via [context]) and
  /// returns parsed options. Results are cached per package root path.
  static DartcopOptions of(RuleContext context) {
    final root = context.package?.root;
    if (root == null) return empty;

    return _cache.putIfAbsent(root.path, () => _read(root.path));
  }

  static DartcopOptions _read(String packageRootPath) {
    try {
      final optionsFile = '$packageRootPath/analysis_options.yaml';
      final content = _readFile(optionsFile);
      if (content == null) return empty;

      final doc = loadYaml(content);
      if (doc is! YamlMap) return empty;

      final dartcopNode = doc['dartcop'];
      if (dartcopNode is! YamlMap) return empty;

      return DartcopOptions(
        maxCyclomaticComplexity: _parseInt(
          dartcopNode, 'max_cyclomatic_complexity', 'max_complexity',
        ),
        maxLinesPerFunction: _parseInt(
          dartcopNode, 'max_lines_per_function', 'max_lines',
        ),
        maxNestingDepth: _parseInt(
          dartcopNode, 'max_nesting_depth', 'max_depth',
        ),
        maxParameters: _parseInt(
          dartcopNode, 'max_parameters', 'max_parameters',
        ),
        maxMethodsPerClass: _parseInt(
          dartcopNode, 'max_methods_per_class', 'max_methods',
        ),
      );
    } on Exception {
      return empty;
    }
  }

  static String? _readFile(String path) {
    try {
      final file = File(path);
      if (!file.existsSync()) return null;
      return file.readAsStringSync();
    } on Exception {
      return null;
    }
  }

  static int? _parseInt(YamlMap section, String ruleName, String key) {
    final ruleNode = section[ruleName];
    if (ruleNode is! YamlMap) return null;
    final value = ruleNode[key];
    if (value is int) return value;
    return null;
  }
}
