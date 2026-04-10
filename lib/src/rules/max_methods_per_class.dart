import 'package:analyzer/analysis_rule/analysis_rule.dart';
import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/error/error.dart';

import '../dartcop_options.dart';

/// Reports classes that contain too many methods.
class MaxMethodsPerClassRule extends AnalysisRule {
  static const defaultMaxMethods = 15;

  static const LintCode code = LintCode(
    'max_methods_per_class',
    'This class has too many methods. '
        'Consider splitting it into smaller classes.',
  );

  MaxMethodsPerClassRule()
      : super(
          name: 'max_methods_per_class',
          description: 'Enforces a maximum number of methods per class.',
        );

  @override
  bool get canUseParsedResult => true;

  @override
  LintCode get diagnosticCode => code;

  @override
  void registerNodeProcessors(
    RuleVisitorRegistry registry,
    RuleContext context,
  ) {
    final threshold =
        DartcopOptions.of(context).maxMethodsPerClass ?? defaultMaxMethods;
    final visitor = _Visitor(this, threshold);
    registry.addClassDeclaration(this, visitor);
  }
}

class _Visitor extends SimpleAstVisitor<void> {
  final MaxMethodsPerClassRule rule;
  final int threshold;

  _Visitor(this.rule, this.threshold);

  @override
  void visitClassDeclaration(ClassDeclaration node) {
    final methodCount = node.members.whereType<MethodDeclaration>().length;
    if (methodCount > threshold) {
      rule.reportAtOffset(node.name.offset, node.name.length);
    }
  }
}
