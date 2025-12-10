---
description: Workflow to add a new spell to the game, strictly following the Meteor implementation pattern.
---

# Add New Spell Workflow

This workflow guides you through adding a new spell (like Meteor) to the game.

## 1. Define Spell & Modifiers
- Open `SpellsAndProjectiles/Spells/spell.gd`.
- **Add Enum Type**: Add your new spell to the `Type` enum.
- **Add Modifiers**: Create a new enum `<SpellName>Modifier` with keys for parameters (e.g., DAMAGE, RADIUS, DURATION).
    ```gdscript
    enum Type {
        # ...
        MY_NEW_SPELL
    }
    
    enum MyNewSpellModifier { DAMAGE, RADIUS, DURATION }
    ```

## 2. Create File Structure
- Create folder: `SpellsAndProjectiles/Spells/<SpellName>/`.
- **Visuals Folder**: `SpellsAndProjectiles/Spells/<SpellName>/Visual/`.
- Create Script: `<spell_name>.gd`.
- Create Scene: `<spell_name>.tscn`.

## 3. Create Visual Scene (First)
- Go to `Visual/` folder.
- Create Scene: `<spell_name>_visual.tscn` (Node3D root).
- Create Script: `<spell_name>_visual.gd`.
- **Logic**: This script handles **only** visual effects (Tweens, Particles, AnimationPlayers).
    - It should **NOT** have game logic (damage, detection).
    - Example: `func play_impact_anim(): ...`

## 4. Implement Spell Script (Logic)
- Extends `Node3D` (usually).
- **Class Name**: `class_name <SpellName>`.
- **Variables**: Define `_owner`, `_target`, and modifier variables.
- **Init Function**: **REQUIRED**. Must match the signature `func init(target: Entity, ...modifiers...)`.
    - Although the signature can vary, standard pattern is `func init(target: Entity, modifiers: Dictionary = {}, source: Entity = null)`.
    - *Note: Meteor uses explicit arguments in `init`, but generic `cast_spell` often passes a dictionary. Check implementation.*
    - **Meteor Pattern**: `func init(target: Entity, damage_percent: float, radius: float, on_hit_callbacks:Array = [], source: Entity = null) -> void:`
- **Logic**:
    - Use `_deploy_timer` if there is a delay.
    - Implement `queue_free()` when done.

## 5. Setup Spell Scene (`.tscn`)
- **Root**: `Node3D`.
- **Script**: Attach `<spell_name>.gd`.
- **Visuals**: Instance your `<spell_name>_visual.tscn` as a child node.
- **Timers**: Add `Timer` nodes (e.g., `%DeployTimer`) if needed.
- **Areas**: Add `Area3D` for detection if AOE.
    - Connect `body_entered`/`exited` signals.

## 5. Register in ActionModule
- Open `Modules/EntityModules/ActionModule/action_module.gd`.
- **Preload Scene**: Add a constant at the top:
    ```gdscript
    const MY_SPELL_SCENE: PackedScene = preload("res://SpellsAndProjectiles/Spells/<SpellName>/<spell_name>.tscn")
    ```
- **Update `cast_spell`**: Add your enum to the match statement:
    ```gdscript
    match spell_type:
        Spell.Type.MY_NEW_SPELL: _cast_my_new_spell(target, spell_modifier)
    ```
- **Implement Casting Function**: Create `_cast_my_new_spell` (usually at the bottom of the Spells region):
    ```gdscript
    func _cast_my_new_spell(target: Entity, spell_modifier: Dictionary) -> void:
        _owner.signal_spell_casted(target, Spell.Type.MY_NEW_SPELL, spell_modifier)
        var spell_instance: MyNewSpell = MY_SPELL_SCENE.instantiate()
        
        # Extract modifiers
        var damage: float = spell_modifier.get(Spell.MyNewSpellModifier.DAMAGE, 10.0)
        
        # Init and Spawn
        spell_instance.init(target, damage)
        _spawn_manager.spawn_spell(spell_instance)
    ```

## 6. Create Tooltip (Optional)
- Open `UI/Tool/Tooltip/Dictionary`.
- Create new Resource (`.tres`) extending `TooltipDesc`.
- **Properties**:
    - `Key`: Unique key (e.g., "MY_SPELL").
    - `Title`: Display title (use curly brackets for colors, e.g., `{{COLOR:FIRE}}METEOR{{/COLOR}}`).
    - `Description`: Description text (use square brackets for icons/keywords, e.g., `[[MAGICAL_DAMAGE]]`).
    - `Icon Key`: Key for the icon to display.

## 7. Triggering the Spell
- In a Family Manager (e.g., `FireManager`), usage:
    ```gdscript
    _owner.cast_spell(target, Spell.Type.MY_NEW_SPELL, {
        Spell.MyNewSpellModifier.DAMAGE: 10.0,
        Spell.MyNewSpellModifier.RADIUS: 2.5
    })
    ```

