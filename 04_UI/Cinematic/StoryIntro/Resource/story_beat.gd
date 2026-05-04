class_name StoryBeat
extends Resource

# A single beat of the intro cinematic. The visual stage (central image,
# side props, animation) lives in `beat_scene` — placed and animated in the
# Godot editor. This Resource only carries the narration data: text, timing,
# and ambient audio.

#region ============================== Export ==============================
@export var id: StringName

@export_multiline var text: String

## The visual stage for this beat. Expected to be a Control (or any Node) with
## an optional child AnimationPlayer named "AnimationPlayer" containing an
## animation called "intro". When present, UIStoryIntro plays that animation
## as the beat starts. When absent, UIStoryIntro just fades the root node in.
@export var beat_scene: PackedScene

## Seconds before the beat auto-advances after the typewriter completes.
@export var hold_after_typewriter: float = 2.5

## Optional ambient stream played while this beat is active. Crossfades with
## the previous beat's stream over ~0.5s.
@export var ambiance_stream: AudioStream
#endregion
