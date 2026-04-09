import 'package:analyzer/analysis_rule/analysis_rule.dart';
import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/token.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/error/error.dart';

import '../helpers/cyclomatic_complexity_visitor.dart';

/// Reports functions/methods whose cyclomatic complexity exceeds a threshold.
class MaxCyclomaticComplexityRule extends AnalysisRule {
  static const _defaultMaxComplexity = 15;

  static const LintCode code = LintCode(
    'max_cyclomatic_complexity',
    'The cyclomatic complexity of this function is too high. '
        'Consider refactoring to reduce complexity.',
  );

  final int maxComplexity;

  MaxCyclomaticComplexityRule({this.maxComplexity = _defaultMaxComplexity})
    : super(
        name: 'max_cyclomatic_complexity',
        description: 'Enforces a maximum cyclomatic complexity per function.',
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
    registry.addFunctionDeclaration(this, visitor);
    registry.addMethodDeclaration(this, visitor);
  }
}

class _Visitor extends SimpleAstVisitor<void> {
  final MaxCyclomaticComplexityRule rule;

  _Visitor(this.rule);

  @override
  void visitFunctionDeclaration(FunctionDeclaration node) {
    _check(node.functionExpression.body, node.name);
  }

  @override
  void visitMethodDeclaration(MethodDeclaration node) {
    _check(node.body, node.name);
  }

  void _check(FunctionBody body, Token name) {
    final visitor = CyclomaticComplexityVisitor();
    body.accept(visitor);
    if (visitor.complexity > rule.maxComplexity) {
      rule.reportAtOffset(name.offset, name.length);
    }
  }
}
