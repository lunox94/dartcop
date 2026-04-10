import 'package:analyzer/analysis_rule/analysis_rule.dart';
import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/error/error.dart';

import '../dartcop_options.dart';

/// Reports functions/methods/constructors with too many parameters.
class MaxParametersRule extends AnalysisRule {
  static const defaultMaxParameters = 8;

  static const LintCode code = LintCode(
    'max_parameters',
    'This function has too many parameters. '
        'Consider using a parameter object or refactoring.',
  );

  MaxParametersRule()
      : super(
          name: 'max_parameters',
          description: 'Enforces a maximum number of parameters per function.',
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
        DartcopOptions.of(context).maxParameters ?? defaultMaxParameters;
    final visitor = _Visitor(this, threshold);
    registry.addFunctionDeclaration(this, visitor);
    registry.addMethodDeclaration(this, visitor);
    registry.addConstructorDeclaration(this, visitor);
  }
}

class _Visitor extends SimpleAstVisitor<void> {
  final MaxParametersRule rule;
  final int threshold;

  _Visitor(this.rule, this.threshold);

  @override
  void visitFunctionDeclaration(FunctionDeclaration node) {
    final params = node.functionExpression.parameters;
    if (params != null && params.parameters.length > threshold) {
      rule.reportAtOffset(node.name.offset, node.name.length);
    }
  }

  @override
  void visitMethodDeclaration(MethodDeclaration node) {
    final params = node.parameters;
    if (params != null && params.parameters.length > threshold) {
      rule.reportAtOffset(node.name.offset, node.name.length);
    }
  }

  @override
  void visitConstructorDeclaration(ConstructorDeclaration node) {
    if (node.parameters.parameters.length > threshold) {
      rule.reportAtNode(node.returnType);
    }
  }
}
