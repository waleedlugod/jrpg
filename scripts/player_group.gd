extends Node2D

var players: Array = []
var focus: int = 0:
	set(new_focus):
		players[focus].unfocus()
		players[new_focus].focus()
		focus = new_focus

# handles player currently taking action
var current_player: int = 0:
	set(new_current_player):
		if current_player < players.size(): players[current_player].unfocus()
		players[new_current_player].focus()
		current_player = new_current_player

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	players = get_children()
	for i in players.size():
		players[i].player_id = i + 1 #player id
		players[i].position = Vector2(0, i*36)
		players[i].character_name = "Player %s" % (i+1)
		
	focus = 0

func _reset_defend() -> void:
	for player in players:
		player.is_defending = false

func clear_focus():
	for player in players: player.unfocus()

func handle_damage(player, damage):
	players[player].take_damage(damage)
	if players[player].health <= 0: players.pop_at(player).queue_free()
	
func _reset_charge() -> void:
	for player in players:
		player.is_charging = false
