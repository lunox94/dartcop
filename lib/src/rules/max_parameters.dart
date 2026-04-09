import 'package:analyzer/analysis_rule/analysis_rule.dart';
import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/error/error.dart';

/// Reports functions/methods/constructors with too many parameters.
class MaxParametersRule extends AnalysisRule {
  static const _defaultMaxParameters = 6;

  static const LintCode code = LintCode(
    'max_parameters',
    'This function has too many parameters. '
        'Consider using a parameter object or refactoring.',
  );

  final int maxParameters;

  MaxParametersRule({this.maxParameters = _defaultMaxParameters})
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
    final visitor = _Visitor(this);
    registry.addFunctionDeclaration(this, visitor);
    registry.addMethodDeclaration(this, visitor);
    registry.addConstructorDeclaration(this, visitor);
  }
}

class _Visitor extends SimpleAstVisitor<void> {
  final MaxParametersRule rule;

  _Visitor(this.rule);

  @override
  void visitFunctionDeclaration(FunctionDeclaration node) {
    final params = node.functionExpression.parameters;
    if (params != null && params.parameters.length > rule.maxParameters) {
      rule.reportAtOffset(node.name.offset, node.name.length);
    }
  }

  @override
  void visitMethodDeclaration(MethodDeclaration node) {
    final params = node.parameters;
    if (params != null && params.parameters.length > rule.maxParameters) {
      rule.reportAtOffset(node.name.offset, node.name.length);
    }
  }

  @override
  void visitConstructorDeclaration(ConstructorDeclaration node) {
    if (node.parameters.parameters.length > rule.maxParameters) {
      rule.reportAtNode(node.returnType);
    }
  }
}
