extends Node2D

var enemies: Array = []

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	enemies = get_children()
	for i in enemies.size():
		enemies[i].position = Vector2(0, i*36)
		enemies[i].character_name = "Enemy %s" % (i+1)


func clear_focus() -> void:
	for enemy in enemies: enemy.unfocus()

func handle_damage(enemy, damage):
	if enemy >= enemies.size() or enemies[enemy] == null:
		return
		
	enemies[enemy].take_damage(damage)
	  
	if enemies[enemy].health <= 0:
		enemies[enemy].is_dead = true
		enemies[enemy].visible = false
