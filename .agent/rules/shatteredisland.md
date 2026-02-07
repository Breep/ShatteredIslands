---
trigger: always_on
glob: "**/*"
description: Rules for Shattered Islands development
---

# Project: Shattered Islands

## Architecture & Patterns
- **Card Implementation**:
  - **Script (`.gd`)**: Handles data definition (`@export`) and setting flags/values in `FamilyStats`. **NO GAMEPLAY LOGIC HERE**.
  - **Resource (`.tres`)**: Stores the data. Always pair with its script.
  - **Family Stats (`family_XY_stats.gd`)**: Stores variables/flags.
  - **Family Manager (`XY_manager.gd`)**: Implements logic (timers, modifiers, spell casts).
- **Managers**:
  - Use `_optional_timers` for card effects that trigger periodically.
  - Use `ActionModifier` for procs/on-hit effects (`_owner.action_modifiers_manager.register_modifier(...)`).
  - Use `StatModifier` for passive stat changes (`_owner.stats_manager.register_modifier(...)`).

## Coding Standards (GDScript)
- **Typing**: Strong typing is required (e.g., `Array[int]`, `float`, `FamilyStats`). Avoid `var` without type inference.
- **Naming**: `class_name` must be PascalCase and match the snake_case filename (e.g. `poison_flask.gd` -> `class_name PoisonFlask`).
- **Debug**: 
  - Use `printerr()` for errors (e.g. invalid levels). 
  - Use `print("DEBUG: ...")` for temporary debugging.
- **Formatting**: Use `.pad_decimals(0)` for displaying integer-like floats in strings.
- **Rich Text**: Use tags for descriptions (e.g. `[[POISON_STACK]]`).
- **Encapsulation**:
  - **NEVER** call a private function/variable (starting with `_`) from another class
  - Exception: `super._function()` is allowed
  - Exception: In `Prototyping/` directory, private access is allowed for rapid testing
- **Scene Tree Communication**:
  - Parent nodes **CAN** call child node functions
  - Child nodes **CANNOT** call parent node functions directly
  - Children communicate with parents via **signals only**
  - Example: `ActionModule` emits signals, `Entity` listens and handles them

## Godot Specifics
- **IDs**: **NEVER** manually assign `uid` or `id`. Let the engine handle it.
- **Scene Tree**: Prefer `@export` references or unique names `%NodeName` over `get_node()`.

## Workflows
- **New Cards**: **ALWAYS** follow the workflow at `.agent/workflows/add_new_card.md` to ensure all steps (Files, Stats, Manager) are covered.
- **New Spells**: **ALWAYS** follow the workflow at `.agent/workflows/add_new_spell.md`, strictly adhering to the Meteor pattern (Visuals separated).

## Safety Rules
- **Git Commands**: 
  - **NEVER** execute destructive git commands like `git checkout -- .`, `git reset --hard`, `git clean -fd` without **explicit, clear approval** from the user.
  - **NEVER** assume it's safe to discard uncommitted changes.
  - If you need to undo changes, **ALWAYS** suggest the command and ask for confirmation first.
  - Prefer targeted operations (single file) over blanket operations (entire repository).

