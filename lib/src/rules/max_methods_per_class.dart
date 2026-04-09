import 'package:analyzer/analysis_rule/analysis_rule.dart';
import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/error/error.dart';

/// Reports classes that contain too many methods.
class MaxMethodsPerClassRule extends AnalysisRule {
  static const _defaultMaxMethods = 15;

  static const LintCode code = LintCode(
    'max_methods_per_class',
    'This class has too many methods. '
        'Consider splitting it into smaller classes.',
  );

  final int maxMethods;

  MaxMethodsPerClassRule({this.maxMethods = _defaultMaxMethods})
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
    final visitor = _Visitor(this);
    registry.addClassDeclaration(this, visitor);
  }
}

class _Visitor extends SimpleAstVisitor<void> {
  final MaxMethodsPerClassRule rule;

  _Visitor(this.rule);

  @override
  void visitClassDeclaration(ClassDeclaration node) {
    final methodCount = node.members.whereType<MethodDeclaration>().length;
    if (methodCount > rule.maxMethods) {
      rule.reportAtOffset(node.name.offset, node.name.length);
    }
  }
}
