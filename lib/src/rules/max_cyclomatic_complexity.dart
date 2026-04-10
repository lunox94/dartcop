import 'package:analyzer/analysis_rule/analysis_rule.dart';
import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/token.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/error/error.dart';

import '../dartcop_options.dart';
import '../helpers/cyclomatic_complexity_visitor.dart';

/// Reports functions/methods whose cyclomatic complexity exceeds a threshold.
class MaxCyclomaticComplexityRule extends AnalysisRule {
  static const defaultMaxComplexity = 10;

  static const LintCode code = LintCode(
    'max_cyclomatic_complexity',
    'The cyclomatic complexity of this function is too high. '
        'Consider refactoring to reduce complexity.',
  );

  MaxCyclomaticComplexityRule()
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
    final threshold =
        DartcopOptions.of(context).maxCyclomaticComplexity ??
        defaultMaxComplexity;
    final visitor = _Visitor(this, threshold);
    registry.addFunctionDeclaration(this, visitor);
    registry.addMethodDeclaration(this, visitor);
  }
}

class _Visitor extends SimpleAstVisitor<void> {
  final MaxCyclomaticComplexityRule rule;
  final int threshold;

  _Visitor(this.rule, this.threshold);

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
    if (visitor.complexity > threshold) {
      rule.reportAtOffset(name.offset, name.length);
    }
  }
}
