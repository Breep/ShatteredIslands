class_name TutorialSequence
extends Resource

# An ordered list of TutorialStep that fires when the game enters trigger_state
# for the first time in a play session.

#region ============================== Export ==============================
@export var id: StringName

## The GameManager.GameState that triggers this sequence (mirrored as int because GDScript
## can't reference an autoload's enum from a Resource without runtime cost).
@export var trigger_state: int = 0

@export var steps: Array[TutorialStep] = []
#endregion
