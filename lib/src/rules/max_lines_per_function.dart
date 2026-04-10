import 'package:analyzer/analysis_rule/analysis_rule.dart';
import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/token.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/error/error.dart';

import '../dartcop_options.dart';

/// Reports functions/methods whose body exceeds a maximum line count.
class MaxLinesPerFunctionRule extends AnalysisRule {
  static const defaultMaxLines = 40;

  static const LintCode code = LintCode(
    'max_lines_per_function',
    'This function body is too long. '
        'Consider breaking it into smaller functions.',
  );

  MaxLinesPerFunctionRule()
    : super(
        name: 'max_lines_per_function',
        description: 'Enforces a maximum line count per function body.',
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
        DartcopOptions.of(context).maxLinesPerFunction ?? defaultMaxLines;
    final visitor = _Visitor(this, context, threshold);
    registry.addFunctionDeclaration(this, visitor);
    registry.addMethodDeclaration(this, visitor);
  }
}

class _Visitor extends SimpleAstVisitor<void> {
  final MaxLinesPerFunctionRule rule;
  final RuleContext context;
  final int threshold;

  _Visitor(this.rule, this.context, this.threshold);

  @override
  void visitFunctionDeclaration(FunctionDeclaration node) {
    _check(node.functionExpression.body, node.name);
  }

  @override
  void visitMethodDeclaration(MethodDeclaration node) {
    _check(node.body, node.name);
  }

  void _check(FunctionBody body, Token name) {
    final lineInfo = context.currentUnit?.unit.lineInfo;
    if (lineInfo == null) return;

    final startLine = lineInfo.getLocation(body.offset).lineNumber;
    final endLine = lineInfo.getLocation(body.end - 1).lineNumber;
    final lineCount = endLine - startLine + 1;

    if (lineCount > threshold) {
      rule.reportAtOffset(name.offset, name.length);
    }
  }
}
