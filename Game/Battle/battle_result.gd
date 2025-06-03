class_name BattleResult
extends Resource

var battle_id: int
var battle_type: Battle.BattleType
var players: Dictionary[int, Array] # This is the results of the battle
# Example: From Loosers to winners
# { 2:[Player1, Player3], 1:[Player4, Player7] } Here Player1 and 3 from team 2 lost the 2v2 against Player4 and 7 from team 1
# { 2:[Player1], 3:[Player8], 1:[Player2] } Here Player 1 from team 2 lost the FFA, Player8 from team 3 was second, Player2 from team 1 won
