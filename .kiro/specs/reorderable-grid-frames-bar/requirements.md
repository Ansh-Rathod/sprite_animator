# Requirements Document

## Introduction

This feature replaces the current `ReorderableListView` in the FramesBar widget with a `ReorderableGridView` from the `reorderable_grid` package, and adds user-adjustable height via a drag handle. The goal is to provide a more flexible frame browsing experience where users can see multiple rows of frame thumbnails and resize the panel to their preference.

## Glossary

- **FramesBar**: The bottom panel widget in the editor that displays animation frame thumbnails
- **Resize_Handle**: A draggable UI element at the top edge of the FramesBar that allows the user to adjust the panel height
- **Grid_View**: The `ReorderableGridView` widget from the `reorderable_grid` package that displays frame thumbnails in a grid layout
- **Frame_Thumbnail**: A 100x100 pixel visual representation of a single animation frame
- **ProjectProvider**: The ChangeNotifier-based state management class that holds animation and frame data

## Requirements

### Requirement 1: Grid-Based Frame Display

**User Story:** As an animator, I want to see my frame thumbnails in a grid layout, so that I can view more frames at once without excessive horizontal scrolling.

#### Acceptance Criteria

1. WHEN the FramesBar is rendered with frames, THE Grid_View SHALL display Frame_Thumbnails in a grid layout using the `reorderable_grid` package
2. WHEN the available height changes, THE Grid_View SHALL adapt the number of visible rows to fill the available space
3. THE Grid_View SHALL maintain a consistent cell size of 100x100 pixels for each Frame_Thumbnail
4. WHEN frames overflow the visible grid area, THE Grid_View SHALL allow vertical scrolling to access all frames

### Requirement 2: Frame Reordering via Grid

**User Story:** As an animator, I want to reorder frames by dragging them within the grid, so that I can rearrange my animation sequence intuitively.

#### Acceptance Criteria

1. WHEN a user long-presses and drags a Frame_Thumbnail, THE Grid_View SHALL allow the user to reorder the frame within the grid
2. WHEN a frame is dropped at a new position, THE Grid_View SHALL call the existing `reorderFrames` method on ProjectProvider with the correct old and new indices
3. WHILE a frame is being dragged, THE Grid_View SHALL display a visual proxy of the dragged frame with a slight scale-up and reduced opacity

### Requirement 3: Frame Selection and Deletion

**User Story:** As an animator, I want to select and delete frames from the grid, so that I can manage my animation sequence without losing existing functionality.

#### Acceptance Criteria

1. WHEN a user taps a Frame_Thumbnail, THE FramesBar SHALL select that frame by calling `goToPreviewFrame` on ProjectProvider
2. WHEN a frame is selected, THE FramesBar SHALL visually highlight the selected Frame_Thumbnail with an accent-colored border
3. WHEN a user taps the delete button on a Frame_Thumbnail, THE FramesBar SHALL remove that frame by calling `removeFrame` on ProjectProvider

### Requirement 4: Resizable Panel Height

**User Story:** As an animator, I want to resize the FramesBar panel by dragging its top edge, so that I can allocate more or less screen space to the frame thumbnails based on my workflow.

#### Acceptance Criteria

1. THE FramesBar SHALL display a Resize_Handle at its top edge
2. WHEN a user drags the Resize_Handle vertically, THE FramesBar SHALL adjust its height in real-time following the drag gesture
3. THE FramesBar SHALL enforce a minimum height of 120 pixels
4. THE FramesBar SHALL enforce a maximum height of 400 pixels
5. WHEN the drag gesture would move the height below the minimum, THE FramesBar SHALL clamp the height to 120 pixels
6. WHEN the drag gesture would move the height above the maximum, THE FramesBar SHALL clamp the height to 400 pixels
7. THE Resize_Handle SHALL display a visual affordance indicating that it is draggable (a horizontal line or grip indicator)
8. WHILE the user hovers over the Resize_Handle, THE FramesBar SHALL change the cursor to a vertical resize cursor

### Requirement 5: Dependency Addition

**User Story:** As a developer, I want the `reorderable_grid` package added to the project dependencies, so that the ReorderableGridView widget is available for use.

#### Acceptance Criteria

1. THE pubspec.yaml SHALL include `reorderable_grid` as a dependency
2. WHEN the project is built, THE dependency resolver SHALL resolve `reorderable_grid` without conflicts with existing dependencies
