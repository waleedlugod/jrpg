extends Node2D

var players: Array = []
var focus: int = 0:
	set(new_focus):
		players[focus].unfocus()
		players[new_focus].focus()
		focus = new_focus

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	players = get_children()
	for i in players.size():
		players[i].position = Vector2(0, i*36)
		
	focus = 0

func _reset_defend() -> void:
	for player in players:
		player.is_defending = false

