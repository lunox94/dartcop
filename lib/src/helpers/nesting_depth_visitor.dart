import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';

/// Computes the maximum nesting depth of control-flow structures in a function body.
///
/// Tracks depth for: if, for, while, do-while, switch, try.
class NestingDepthVisitor extends RecursiveAstVisitor<void> {
  int _currentDepth = 0;
  int maxDepth = 0;

  void _enter(AstNode node) {
    _currentDepth++;
    if (_currentDepth > maxDepth) {
      maxDepth = _currentDepth;
    }
  }

  void _leave() {
    _currentDepth--;
  }

  @override
  void visitIfStatement(IfStatement node) {
    _enter(node);
    // Visit the expression (condition) without counting depth
    node.expression.accept(this);
    // Visit then-branch
    node.thenStatement.accept(this);
    _leave();

    // The else-branch is visited at the same depth as the if (not nested deeper)
    final elseStatement = node.elseStatement;
    if (elseStatement != null) {
      if (elseStatement is IfStatement) {
        // else-if: don't add extra nesting
        elseStatement.accept(this);
      } else {
        _enter(elseStatement);
        elseStatement.accept(this);
        _leave();
      }
    }
  }

  @override
  void visitForStatement(ForStatement node) {
    _enter(node);
    super.visitForStatement(node);
    _leave();
  }

  @override
  void visitWhileStatement(WhileStatement node) {
    _enter(node);
    super.visitWhileStatement(node);
    _leave();
  }

  @override
  void visitDoStatement(DoStatement node) {
    _enter(node);
    super.visitDoStatement(node);
    _leave();
  }

  @override
  void visitSwitchStatement(SwitchStatement node) {
    _enter(node);
    super.visitSwitchStatement(node);
    _leave();
  }

  @override
  void visitTryStatement(TryStatement node) {
    _enter(node);
    super.visitTryStatement(node);
    _leave();
  }
}
