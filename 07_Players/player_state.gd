class_name PlayerState
extends Resource

# Pure data slice of a Player : ce qui doit persister à travers un save/load de
# run mais qui n'appartient pas au héros (donc pas migré sur HeroSpec).
# Porte le gold (porte-monnaie) et le slot du joueur — clé d'ownership stable
# inter-run reliant ce joueur à son Roaster (cf. Party.roasters[slot]).

# Slot joueur stable d'une run à l'autre. C'est l'identité d'ownership : clé du
# Dictionary Party.roasters — surtout PAS le peer id réseau (runtime). Une run
# prêtée garde ses slots ; une surcouche méta reliera plus tard slot ↔ compte.
enum Slot { NONE = 0, PLAYER_1 = 1, PLAYER_2 = 2, PLAYER_3 = 3, PLAYER_4 = 4, PLAYER_5 = 5, PLAYER_6 = 6, PLAYER_7 = 7, PLAYER_8 = 8 }

@export var slot: Slot = Slot.NONE
@export var gold: int = 0
