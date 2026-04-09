import 'package:analyzer/dart/analysis/utilities.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:dartcop/src/helpers/cyclomatic_complexity_visitor.dart';
import 'package:test/test.dart';

/// Parse source and run the complexity visitor on the first function body found.
int computeComplexity(String source) {
  final result = parseString(content: source);
  final unit = result.unit;
  final func = unit.declarations.whereType<FunctionDeclaration>().first;
  final visitor = CyclomaticComplexityVisitor();
  func.functionExpression.body.accept(visitor);
  return visitor.complexity;
}

void main() {
  group('CyclomaticComplexityVisitor', () {
    test('simple function has complexity 1', () {
      expect(computeComplexity('void f() { print("hello"); }'), 1);
    });

    test('single if adds 1', () {
      expect(
        computeComplexity('''
void f(int x) {
  if (x > 0) { print(x); }
}
'''),
        2,
      );
    });

    test('if-else if-else is 3', () {
      expect(
        computeComplexity('''
void f(int x) {
  if (x > 0) {
    print('pos');
  } else if (x < 0) {
    print('neg');
  } else {
    print('zero');
  }
}
'''),
        3, // base 1 + if + else-if
      );
    });

    test('for loop adds 1', () {
      expect(
        computeComplexity('''
void f() {
  for (var i = 0; i < 10; i++) { print(i); }
}
'''),
        2,
      );
    });

    test('while adds 1', () {
      expect(
        computeComplexity('''
void f() {
  var i = 0;
  while (i < 10) { i++; }
}
'''),
        2,
      );
    });

    test('do-while adds 1', () {
      expect(
        computeComplexity('''
void f() {
  var i = 0;
  do { i++; } while (i < 10);
}
'''),
        2,
      );
    });

    test('catch adds 1', () {
      expect(
        computeComplexity('''
void f() {
  try { print(1); } catch (e) { print(e); }
}
'''),
        2,
      );
    });

    test('conditional expression adds 1', () {
      expect(
        computeComplexity('''
void f(bool b) {
  var x = b ? 1 : 2;
}
'''),
        2,
      );
    });

    test('&& adds 1', () {
      expect(
        computeComplexity('''
void f(bool a, bool b) {
  if (a && b) { print('both'); }
}
'''),
        3, // base 1 + if + &&
      );
    });

    test('|| adds 1', () {
      expect(
        computeComplexity('''
void f(bool a, bool b) {
  if (a || b) { print('either'); }
}
'''),
        3, // base 1 + if + ||
      );
    });

    test('complex function accumulates correctly', () {
      expect(
        computeComplexity('''
void f(int x) {
  if (x > 0) {           // +1 = 2
    for (var i = 0; i < x; i++) { // +1 = 3
      if (i > 5 && i < 10) { // +1(if) +1(&&) = 5
        print(i);
      }
    }
  } else {
    while (x < 0) { // +1 = 6
      try {
        x++;
      } catch (e) { // +1 = 7
        print(e);
      }
    }
  }
  var y = x > 0 ? 1 : 2; // +1 = 8
}
'''),
        8,
      );
    });
  });
}
