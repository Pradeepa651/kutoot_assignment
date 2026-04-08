# Flutter Developer Assignment Task

## Overview

This repository implements a Flutter application with local persistence, state management, and navigation. The project uses:

- Flutter for UI and app lifecycle
- Hive for local storage
- BLoC for state management
- GoRouter for navigation
- code generation for Hive adapters

## Architecture

The app is organized into logical layers:

- `lib/main.dart` — application bootstrap, Hive initialization, and dependency registration
- `lib/model/` — domain models, including `Task` and `TaskList`
- `lib/hive/` — Hive adapter configuration and generated registration code
- `lib/bloc/` — BLoC classes for task management and network state
- `lib/page/` — presentation layer and screen widgets
- `lib/repo/` — data repository abstractions

## Directory Structure

- `lib/main.dart`
  - initializes `Hive` with `Hive.initFlutter()`
  - registers generated adapters via `registerAdapters()`
  - configures the app router

- `lib/model/task.dart`
  - defines the `Task` and `TaskList` entities
  - includes serialization helpers and Hive annotations

- `lib/hive/hive_adapters.dart`
  - declares adapter generation for `Task` and `TaskList`

- `lib/hive/hive_adapters.g.dart`
  - generated adapter implementations (do not modify manually)

- `lib/hive/hive_registrar.g.dart`
  - generated registration helpers for Hive adapters

- `lib/bloc/task_bloc/`
  - manages task CRUD operations and persistence

- `lib/page/task_page.dart`
  - task list UI and input handling

- `lib/page/product_page.dart`
  - product-related UI and navigation

## Setup

1. Ensure dev dependencies are present in `pubspec.yaml`:

```yaml
dev_dependencies:
  build_runner: ^2.4.0
  hive_ce_generator: ^1.11.1
```

2. Install dependencies:

```bash
flutter pub get
```

3. Generate Hive adapters:

```bash
dart run build_runner build --delete-conflicting-outputs
```

4. Restart the application when model classes change.

## Best Practices

- Always annotate Hive model classes with `@HiveType` and `@HiveField`.
- Register all generated adapters before opening boxes.
- Keep generated files under version control if they are required for build.

## Troubleshooting

- `HiveError: Cannot write, unknown type: Task`
  - Verify `Task` is annotated
  - Confirm `TaskAdapter` is generated and registered
  - Re-run build runner if model definitions change
