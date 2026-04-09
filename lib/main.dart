import 'package:analysis_server_plugin/plugin.dart';
import 'package:analysis_server_plugin/registry.dart';

import 'src/rules/max_cyclomatic_complexity.dart';
import 'src/rules/max_lines_per_function.dart';
import 'src/rules/max_methods_per_class.dart';
import 'src/rules/max_nesting_depth.dart';
import 'src/rules/max_parameters.dart';

final plugin = _DartcopPlugin();

class _DartcopPlugin extends Plugin {
  @override
  String get name => 'dartcop';

  @override
  void register(PluginRegistry registry) {
    registry.registerWarningRule(MaxCyclomaticComplexityRule());
    registry.registerWarningRule(MaxLinesPerFunctionRule());
    registry.registerWarningRule(MaxNestingDepthRule());
    registry.registerWarningRule(MaxParametersRule());
    registry.registerWarningRule(MaxMethodsPerClassRule());
  }
}
