---
description: Workflow to add a new card to the game, including script, resource, stats, and manager updates.
---

# Add New Card Workflow

This workflow guides you through adding a new card to the game.

## 1. Gather Information
- **Name**: The name of the card (e.g., "Venomous Darts").
- **Family**: The family it belongs to (e.g., "Poison").
  - Check `Card/Templates/family.gd` for the Enum value (e.g., Poison = 7).
- **Rarity**: Common, Rare, Epic, or Legendary.
- **Mechanics**: Cleanly define what the card does.

## 2. Update Family Stats
- Locate the family stats file: `Entities/Character/FamilyStats/Family<Family>Stats/family_<family>_stats.gd`.
- Add a boolean variable `var <family>_<card_name_snake_case>_activated: bool`.
- Add relevant stat variables (e.g., damage, chance, stacks) that will change with card level.
- Example:
    ```gdscript
    # [Card Name]
    var poison_new_card_activated: bool
    var poison_new_card_damage: float
    ```

## 3. Create Card Script
- Create a new directory: `Card/Descriptions/Cards/<Family>/<Rarity>/<CardName>/`.
- Create the script file: `<family>_<card_name_snake_case>.gd`.
- **Note**: Do NOT add any `uid` or `id` fields to the script manually. Godot will handle this.
- Content template:
    ```gdscript
    class_name <Family><CardName> # e.g. PoisonNewCard
    extends CharacterUpgrade

    @export var _damage: Array[int]
    @export var _duration: Array[float]

    func apply(stats: FamiliesStats, cardlvl: int) -> void:
        if cardlvl < 1 or cardlvl > Card.RARITY_MAX_LEVEL[Card.Rarity.<RARITY>]:
            printerr("<Card Name>: Wrong cardlvl: ", cardlvl)
            return
        
        stats.<family>.<family>_<card_snake_case>_activated = true
        stats.<family>.<family>_<card_snake_case>_damage = _damage[cardlvl - 1]
        stats.<family>.<family>_<card_snake_case>_duration = _duration[cardlvl - 1]

    func get_description(cardlvl: int) -> String:
        if cardlvl < 1 or cardlvl > Card.RARITY_MAX_LEVEL[Card.Rarity.<RARITY>]:
            return "ERROR"
        
        # Use .pad_decimals(0) for integers in strings
        var d = str(_damage[cardlvl - 1]).pad_decimals(0)
        var dur = str(_duration[cardlvl - 1]).pad_decimals(1)
        
        # Use tags like [[POISON_STACK]] for rich text
        return "Inflict " + d + " [[POISON_STACK]] for " + dur + "s."
    ```

## 4. Create Card Resource (TRES)
- Create the resource file: `<family>_<card_name_snake_case>.tres` in the same directory.
- **Set Script**: Assign `Card/Templates/card.gd` to the resource.
- **Fill Properties**:
    - `Name`: Display name of the card.
    - `Picture`: Drag and drop the portrait (if available).
    - `Family`: Set the integer Enum value (e.g., 7 for Poison).
    - `Rarity`: Set the rarity.
    - `Player Upgrade`: Create a new `Resource` (or sub-resource).
        - **Script**: Assign your new script (`<family>_<card_name_snake_case>.gd`) to this sub-resource.
        - **Values**: Fill in the exported arrays (e.g., `_damage`, `_duration`) for each level.
- **IMPORTANT**: Do NOT manually edit the `.tres` file to add UIDs. Let Godot generate them.

## 5. Register Card in Family
- Locate `Card/Descriptions/Families/<family>_family.tres`.
- Add your new card resource (`.tres`) to the `cards` array.

## 6. Update Family Manager
- Locate the manager file: `Entities/Character/FamiliesManagers/<Family>/<family>_manager.gd`.
- **Implement Logic**:
    - **Start/Stop**: Initialize/Cleanup timers or modifiers in `start()` and `stop()`.
    - **Handlers**: Add functions to handle the logic.
    - **Debug Prints**: Add debug prints to verify stats/targets.
    - Example:
        ```gdscript
        func _create_optional_timers() -> void:
            if _poison_stats.poison_new_card_activated:
                print("DEBUG: New Card Activated with duration: ", _poison_stats.poison_new_card_duration)
                _optional_timers.append(Utils.create_perpetual_timer(self, _poison_stats.poison_new_card_duration, _on_new_card_timer_timeout, true))

        func _on_new_card_timer_timeout() -> void:
            var target = _owner.target_module.get_target(TargetModule.TargettingStrategy.RANDOM_ENEMY)
            if target == null:
                 print("DEBUG: New Card - No target found")
                 return
            
            print("DEBUG: New Card - Applying effect to target: ", target.name)
            # Apply effect...
        ```

## 7. Verification
- Run the game.
- Ensure the card appears in the deck/shop.
- Verify the effects work in combat.
