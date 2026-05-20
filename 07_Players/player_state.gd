class_name PlayerState
extends Resource

# Pure data slice of a Player : ce qui doit persister à travers un save/load de
# run mais qui n'appartient pas au héros (donc pas migré sur HeroSpec).
# Aujourd'hui : juste le gold (porte-monnaie). Le deck/level/xp/data_memory du
# héros vivent sur HeroSpec dans party.formation.

@export var gold: int = 0
