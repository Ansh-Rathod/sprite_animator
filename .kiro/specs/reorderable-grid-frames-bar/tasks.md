# Tasks

## Task 1: Add reorderable_grid dependency

- [x] Add `reorderable_grid` package to pubspec.yaml dependencies
- [x] Run `flutter pub get` to resolve the dependency

## Task 2: Convert FramesBar to StatefulWidget with resize handle

- [x] Convert `FramesBar` from `StatelessWidget` to `StatefulWidget`
- [x] Add `_currentHeight` state variable (default 200.0, min 120.0, max 400.0)
- [x] Add `_handleHeight` constant (16.0)
- [x] Implement `_onDragUpdate` method that updates height with clamping (negate delta.dy since bar is at bottom)
- [x] Build resize handle widget with MouseRegion (resizeRow cursor) and GestureDetector (onVerticalDragUpdate)
- [x] Add visual grip indicator (centered 40x4 pill shape) in the resize handle
- [x] Replace the fixed `height: 200` Container with `height: _currentHeight`
- [x] Restructure Column to have resize handle at top, then Expanded for the grid area

## Task 3: Replace ReorderableListView with ReorderableGridView

- [x] Import `package:reorderable_grid/reorderable_grid.dart`
- [x] Remove the `ReorderableListView.builder` and its horizontal scroll configuration
- [x] Add a `LayoutBuilder` to calculate available width for the grid
- [x] Implement `_calculateCrossAxisCount` method (availableWidth / 110, clamped 1..20)
- [x] Replace with `ReorderableGridView.builder` using `SliverGridDelegateWithFixedCrossAxisCount`
- [x] Set gridDelegate with calculated crossAxisCount, mainAxisSpacing: 10, crossAxisSpacing: 10, childAspectRatio: 100/130
- [x] Preserve the `onReorder: state.reorderFrames` callback
- [x] Preserve the proxyDecorator with scale and opacity animation
- [x] Update itemBuilder to work with grid cells (remove horizontal padding, keep frame thumbnail structure)
- [x] Preserve frame selection (goToPreviewFrame on tap), deletion (removeFrame), and visual highlighting
- [x] Keep the empty state check (SizedBox.shrink when frames.isEmpty)
