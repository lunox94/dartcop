import 'package:analyzer/dart/analysis/utilities.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:dartcop/src/helpers/nesting_depth_visitor.dart';
import 'package:test/test.dart';

/// Parse source and run the nesting depth visitor on the first function body found.
int computeMaxDepth(String source) {
  final result = parseString(content: source);
  final unit = result.unit;
  final func = unit.declarations.whereType<FunctionDeclaration>().first;
  final visitor = NestingDepthVisitor();
  func.functionExpression.body.accept(visitor);
  return visitor.maxDepth;
}

void main() {
  group('NestingDepthVisitor', () {
    test('simple function has depth 0', () {
      expect(computeMaxDepth('void f() { print("hello"); }'), 0);
    });

    test('single if has depth 1', () {
      expect(
        computeMaxDepth('''
void f(int x) {
  if (x > 0) { print(x); }
}
'''),
        1,
      );
    });

    test('nested if has depth 2', () {
      expect(
        computeMaxDepth('''
void f(int x) {
  if (x > 0) {
    if (x > 10) {
      print(x);
    }
  }
}
'''),
        2,
      );
    });

    test('else-if chain does not increase depth', () {
      expect(
        computeMaxDepth('''
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
        1, // else-if is flat, else adds 1 depth same as if
      );
    });

    test('for loop counts as nesting', () {
      expect(
        computeMaxDepth('''
void f() {
  for (var i = 0; i < 10; i++) {
    if (i > 5) {
      print(i);
    }
  }
}
'''),
        2, // for(1) > if(2)
      );
    });

    test('while inside if counts correctly', () {
      expect(
        computeMaxDepth('''
void f(int x) {
  if (x > 0) {
    while (x > 0) {
      x--;
    }
  }
}
'''),
        2,
      );
    });

    test('try-catch is nesting', () {
      expect(
        computeMaxDepth('''
void f() {
  try {
    print(1);
  } catch (e) {
    print(e);
  }
}
'''),
        1,
      );
    });

    test('deeply nested returns correct depth', () {
      expect(
        computeMaxDepth('''
void f(int x) {
  if (x > 0) {                    // depth 1
    for (var i = 0; i < x; i++) {  // depth 2
      while (i > 0) {             // depth 3
        if (i == 5) {             // depth 4
          switch (i) {            // depth 5
            case 5:
              print('five');
          }
        }
      }
    }
  }
}
'''),
        5,
      );
    });
  });
}
