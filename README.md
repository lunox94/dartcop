# dartcop

`dartcop` is a general-purpose Dart analyzer plugin that adds maintainability-focused lint rules for complexity, function size, nesting depth, parameter count, and class method count.

## Included rules

- `max_cyclomatic_complexity`
- `max_lines_per_function`
- `max_nesting_depth`
- `max_parameters`
- `max_methods_per_class`

## Install from GitHub

Add `dartcop` as a dev dependency:

```yaml
dev_dependencies:
  dartcop:
    git:
      url: https://github.com/lunox94/dartcop.git
      ref: main
```

Then register the analyzer plugin in `analysis_options.yaml`:

```yaml
analyzer:
  plugins:
    - dartcop
```

## Development

Run the package checks locally:

```bash
dart pub get
dart test
dart analyze
```

## Notes

This repository currently ships as a Git dependency. A future pub.dev release can remove `publish_to: none` and publish tagged versions.

