extends Node

# ===== DATA SET =====
# dictionary of round logs
# PREPARATION:
# Card bought by players
# BATTLE:
# ---> Who fight
# ---> Who win/loose/how much player hp lost
# ---> Battle logs
# ------> All actions with timestamps (damage, heal, stacks, spell casted, summons)


# ===== API =====
# export DATA as json
# convert data to be exploited by a match_history_viewer in game that will show stats with graphs and tabs


# ===== Internal API =====
# Listen to Battle writer to record all battle logs
# Listen to preparation events to records all preparation events
