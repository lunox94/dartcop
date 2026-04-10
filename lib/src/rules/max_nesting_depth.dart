import 'package:analyzer/analysis_rule/analysis_rule.dart';
import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/token.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/error/error.dart';

import '../dartcop_options.dart';
import '../helpers/nesting_depth_visitor.dart';

/// Reports functions/methods whose control-flow nesting depth exceeds a threshold.
class MaxNestingDepthRule extends AnalysisRule {
  static const defaultMaxDepth = 4;

  static const LintCode code = LintCode(
    'max_nesting_depth',
    'The nesting depth of this function is too high. '
        'Consider refactoring to reduce nesting.',
  );

  MaxNestingDepthRule()
    : super(
        name: 'max_nesting_depth',
        description:
            'Enforces a maximum nesting depth of control-flow structures.',
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
        DartcopOptions.of(context).maxNestingDepth ?? defaultMaxDepth;
    final visitor = _Visitor(this, threshold);
    registry.addFunctionDeclaration(this, visitor);
    registry.addMethodDeclaration(this, visitor);
  }
}

class _Visitor extends SimpleAstVisitor<void> {
  final MaxNestingDepthRule rule;
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
    final visitor = NestingDepthVisitor();
    body.accept(visitor);
    if (visitor.maxDepth > threshold) {
      rule.reportAtOffset(name.offset, name.length);
    }
  }
}
