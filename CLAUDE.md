# Shattered Islands — Project Memory

## Project overview
Autobattler coop roguelite in Godot 4.x (GDScript).
Gameplay alternates between a tavern (preparation, social, NPC interactions)
and combat on flying islands. Previously designed as a competitive 1v1/3v3
autobattler, pivoted to coop roguelite — but the core tavern/combat loop
remains the foundation.

## Domain vocabulary
- **Hero** — playable unit controlled by a player
- **Summon** — unit spawned by a hero (Chicken, TRex, etc.)
- **Fighting area** — flying island where a combat phase happens
- **Tavern** — central hub for the preparation phase, where players and
  NPCs/monsters interact
- **Family** — faction/archetype system affecting heroes via `FamilyManager`
- **Alteration** — generic term covering both stackable conditions
  (poison, burn...), timed statuses (stun, silence...) and state statuses (taunt...)
- **Action** — any outgoing effect (damage, heal, inflict status, summon...)
  routed through sender/receiver modules

More specific vocabulary lives in folder-level CLAUDE.md files
(created on-demand when a folder develops its own terminology).

## Code conventions (project-specific)
- Organize class contents in `#region` blocks (Signals, Enums, Export,
  Public vars, Private vars, Node base functions, Public functions,
  Private functions, Callbacks)
- Signals declared at top of class (inside a Signals region)
- Verbose logging through `Verbose.debug/warn/error` with `Verbose.Category`
  — do not use raw `print()`
- Prefer composition via child nodes over deep inheritance when behavior
  is optional or situational

### Comments
- No comments stating the obvious. A function named `_jump()` does not
  need a `# Makes the hero jump` comment above it. Clean code is
  self-documenting — method and variable names carry the intent.
- Comments are welcome for genuinely non-trivial logic (complex algorithms,
  unusual math, non-obvious workarounds, performance hacks that need explaining).
- NO transient comments left in code: no `# TODO refactor this later`,
  `# rework in progress`, `# old version, keep for now`, etc. If it's not
  done, it's in a task tracker, not in the source. These always linger and
  rot.

### Class headers
- Every class should have a short header comment at the top explaining
  its macro purpose (what role does this class play, why does it exist).
- When modifying an existing class that lacks a header, propose adding one
  (ask before writing it — I may want to phrase it myself).
- New classes must always start with a header.
- Keep headers short: 1–3 lines. Not a full documentation, just enough
  for someone opening the file to understand "what is this".

### Prefer the editor
- Always prefer doing things in the Godot editor when possible. Scene
  structure, node layout, UI (Controls, containers, anchors), signal
  connections, exported references, resources — these belong in `.tscn` /
  `.tres`, not built imperatively in code.
- Do NOT build UI by code (no `Button.new()` / `add_child()` walls). Lay the
  nodes out in the scene, expose them with `@onready`/`@export` and keep the
  script for behavior only.
- Scripts wire and react; the editor describes structure. If a thing can be
  configured in the inspector, configure it there rather than in `_ready()`.

## Prototyping scenes (mandatory for visible systems)

When adding a new component or system with visible or tactile behavior
(UI widgets, input systems, feedback, animations, drag & drop, floating
labels, health bars...), a dedicated prototyping scene must accompany
the implementation.

### When to propose one
- Any new user-facing component (UI, input handling, visual feedback)
- Any system where "feel" matters and needs isolated validation
- Ask me first before creating it — I'll confirm if it's worth the scene
- For pure backend/data systems, don't propose unless I bring it up

### Purpose
- Exercise the component's public API in isolation from the rest of the game
- Validate the "game feel" without the noise of a full battle/tavern context
- Force the component's API to be usable before integration

### Structure (minimum viable proto scene)
- The component itself, instantiated standalone
- Buttons (or minimal UI) that trigger each public API method
- Example: HealthBar proto → buttons for "take 10 damage", "take 50 damage",
  "heal 30", "crit damage", "reset"
- Example: drag & drop proto → a few draggable entities, a few drop zones,
  nothing else
- Keep scope tight — test ONE system, not a mini-game

### Naming and location
- Scenes live **next to the component they test**, not in a separate root folder
- Suffix convention: `*.proto.tscn` and `*.proto.gd`
- Example: `/UI/HealthBar/health_bar.tscn` + `/UI/HealthBar/health_bar.proto.tscn`
- This suffix must be excluded from release builds via the export preset
  (`filter_exclude: *.proto.tscn, *.proto.gd`)

### Rules inside proto scenes
- Accessing private members (`_foo`, private functions) of tested components
  is explicitly ALLOWED in proto scenes. Prototyping is about challenging
  the component from all angles — public API, but also internal behavior
  candidates that might become public later.
- Standard code hygiene still applies (no dead code left rotting, no
  committed `print()` spam), but no lint-like objections about encapsulation.

## How to work with me

### Default mode: design discussion
- Treat every question as a design discussion first, not a coding task
- Do NOT modify files unless I explicitly say "implement", "apply this",
  "code this", or "refactor now"
- When I share code, assume I want analysis, not refactoring
- If you spot a code smell, MENTION it briefly but do not fix it unprompted

### Answer shape
- Lead with the trade-offs, not the answer
- When presenting options, always include pros/cons
- Keep answers focused; don't re-explain fundamentals unless I ask
- Reference concrete examples from existing games when it helps

### When I ask for code
- I will be explicit: "implement", "write this", "apply"
- Until then, pseudocode or illustrative snippets are welcome,
  full file edits are not
