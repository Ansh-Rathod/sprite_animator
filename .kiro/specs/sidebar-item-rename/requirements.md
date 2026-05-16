# Requirements Document

## Introduction

The editor sidebar lists every animation in the current project as a `SidebarItem`. Today the animation name is rendered as a static `Text` widget, so users have no way to rename animations from the sidebar. This feature adds Figma-style inline rename: double-clicking the animation name swaps the label for a focused text field; pressing Enter or losing focus commits the new name; pressing Escape discards the edit. Single-click selection, hover, and the "more options" button continue to work unchanged.

## Glossary

- **SidebarItem**: The widget in `lib/screens/editor/editor.dart` that renders a single animation entry inside the editor's left sidebar.
- **Sidebar**: The vertical list of `SidebarItem` widgets shown in `EditorScreen`.
- **ProjectProvider**: The `ChangeNotifier` in `lib/providers/project_provider.dart` that owns the `animations` list and exposes mutators that call `notifyListeners`.
- **Animation**: An entry in `ProjectProvider.animations` (`Animations` model) identified by `id` and labelled by `name`.
- **Display_Mode**: The `SidebarItem` state in which the animation name is rendered as a read-only text label.
- **Rename_Mode**: The `SidebarItem` state in which the animation name is rendered as an editable text field with keyboard focus.
- **Pending_Name**: The current contents of the rename text field while the `SidebarItem` is in Rename_Mode.
- **Commit**: The act of persisting the Pending_Name to `ProjectProvider` via a rename mutator that calls `notifyListeners`, then returning to Display_Mode.
- **Cancel**: The act of discarding the Pending_Name and returning to Display_Mode without modifying `ProjectProvider`.
- **Trimmed_Name**: The Pending_Name with leading and trailing whitespace removed via `String.trim()`.

## Requirements

### Requirement 1: Enter Rename Mode via Double-Click

**User Story:** As a user, I want to double-click an animation name in the sidebar, so that I can rename it inline without opening a separate dialog.

#### Acceptance Criteria

1. WHEN the user double-clicks the SidebarItem name area, THE SidebarItem SHALL transition from Display_Mode to Rename_Mode.
2. WHEN the SidebarItem enters Rename_Mode, THE SidebarItem SHALL render an editable text field in place of the name label.
3. WHEN the SidebarItem enters Rename_Mode, THE SidebarItem SHALL initialize the text field value to the current animation name.
4. WHEN the SidebarItem enters Rename_Mode, THE SidebarItem SHALL request keyboard focus for the text field.
5. WHEN the SidebarItem enters Rename_Mode, THE SidebarItem SHALL select all text in the text field so the next keystroke replaces the existing name.
6. WHILE the SidebarItem is in Rename_Mode, THE SidebarItem SHALL NOT render the read-only name label.
7. IF the rename text field cannot be rendered while the SidebarItem is in Rename_Mode, THEN THE SidebarItem SHALL fall back to Display_Mode and render the read-only name label.

### Requirement 2: Preserve Single-Click and Auxiliary Controls

**User Story:** As a user, I want single-click selection and the "more options" button to keep working, so that entering rename mode does not regress existing sidebar behavior.

#### Acceptance Criteria

1. WHEN the user single-clicks the SidebarItem, THE SidebarItem SHALL invoke the existing `onTap` callback to select the animation.
2. WHILE the SidebarItem is in Display_Mode, THE SidebarItem SHALL render the "more options" IconButton in its current position.
3. WHEN the user clicks the "more options" IconButton, THE SidebarItem SHALL NOT enter Rename_Mode.
4. WHILE the SidebarItem is in Rename_Mode, THE SidebarItem SHALL NOT invoke the `onTap` selection callback in response to clicks inside the text field.
5. WHILE the SidebarItem is in Display_Mode, THE SidebarItem SHALL apply the existing hover and selection background styling unchanged.

### Requirement 3: Commit on Enter Key

**User Story:** As a user, I want to press Enter to confirm a rename, so that I can rename without reaching for the mouse.

#### Acceptance Criteria

1. WHEN the user presses the Enter key while the SidebarItem is in Rename_Mode AND the Trimmed_Name is non-empty, THE SidebarItem SHALL Commit the Trimmed_Name and return to Display_Mode.
2. WHEN the SidebarItem Commits a name, THE SidebarItem SHALL invoke a `ProjectProvider` rename mutator that updates `animations[index].name` and calls `notifyListeners`.
3. WHEN the Commit completes, THE SidebarItem SHALL render the read-only name label showing the committed Trimmed_Name.
4. IF the user presses Enter while the SidebarItem is in Rename_Mode AND the Trimmed_Name is empty, THEN THE SidebarItem SHALL discard the Pending_Name, retain the original animation name, and return to Display_Mode.

### Requirement 4: Commit on Focus Loss

**User Story:** As a user, I want clicking elsewhere to confirm my rename, so that the text field does not stay open when I move on to another action.

#### Acceptance Criteria

1. WHEN the rename text field loses keyboard focus AND the Trimmed_Name is non-empty AND the Trimmed_Name differs from the original animation name, THE SidebarItem SHALL Commit the Trimmed_Name and return to Display_Mode.
2. WHEN the rename text field loses keyboard focus AND the Trimmed_Name equals the original animation name, THE SidebarItem SHALL return to Display_Mode without invoking the `ProjectProvider` rename mutator.
3. IF the rename text field loses keyboard focus AND the Trimmed_Name is empty, THEN THE SidebarItem SHALL discard the Pending_Name, retain the original animation name, and return to Display_Mode.

### Requirement 5: Cancel on Escape Key

**User Story:** As a user, I want to press Escape to abandon a rename in progress, so that I can recover from accidental edits.

#### Acceptance Criteria

1. WHEN the user presses the Escape key while the SidebarItem is in Rename_Mode, THE SidebarItem SHALL Cancel the edit and return to Display_Mode.
2. WHEN the SidebarItem Cancels an edit, THE SidebarItem SHALL NOT invoke the `ProjectProvider` rename mutator.
3. WHEN the SidebarItem Cancels an edit, THE SidebarItem SHALL render the read-only name label showing the original animation name.

### Requirement 6: ProjectProvider Rename Mutator

**User Story:** As a developer, I want a single rename mutator on `ProjectProvider`, so that the sidebar can persist name changes through the existing state-management flow.

#### Acceptance Criteria

1. THE ProjectProvider SHALL expose a `renameAnimation(int index, String newName)` method.
2. WHEN `renameAnimation` is invoked with a valid index AND a non-empty Trimmed_Name, THE ProjectProvider SHALL set `animations[index].name` to the Trimmed_Name.
3. WHEN `renameAnimation` modifies an animation name, THE ProjectProvider SHALL notify the `editorSidebar` listeners by calling `notify([W.editorSidebar])`.
4. IF `renameAnimation` is invoked with an index outside the range `[0, animations.length)`, THEN THE ProjectProvider SHALL leave `animations` unchanged and SHALL NOT call `notifyListeners`.
5. IF `renameAnimation` is invoked with a Trimmed_Name that is empty, THEN THE ProjectProvider SHALL leave `animations` unchanged and SHALL NOT call `notifyListeners`.
6. WHEN `renameAnimation` sets `animations[index].name` to a value equal to the existing name, THE ProjectProvider SHALL leave `animations[index].id` and `animations[index].frames` unchanged.

### Requirement 7: Sidebar Reflects Committed Name

**User Story:** As a user, I want the sidebar list to immediately show my new name after rename, so that I can see the change without refreshing.

#### Acceptance Criteria

1. WHEN `ProjectProvider.renameAnimation` completes successfully for the animation at index N, THE Sidebar SHALL render `SidebarItem` at index N with the new Trimmed_Name as its label on the next build.
2. WHEN a rename Commits, THE Sidebar SHALL preserve the order of animations in `ProjectProvider.animations`.
3. WHEN a rename Commits for the currently selected animation, THE Sidebar SHALL keep `selectedAnimationIndex` unchanged.
