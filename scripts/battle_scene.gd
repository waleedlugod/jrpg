extends Node2D

@onready var action_choice: VBoxContainer = $"./CanvasLayer/Choice"
@onready var enemies = $EnemyGroup.enemies
@onready var playerGroup = $PlayerGroup
@onready var players = $PlayerGroup.players


# handles target focus when attacking
var action_target: int = 0:
	set(new_action_target):
		enemies[action_target].unfocus()
		enemies[new_action_target].focus()
		action_target= new_action_target


# handles player currently taking action
var current_player: int = 0:
	set(new_current_player):
		players[current_player].unfocus()
		players[new_current_player].focus()
		current_player= new_current_player


var action_queue: Array = []
var chosen_action: String = ""
var enemy_action_queue: Array = []
var rng: RandomNumberGenerator = RandomNumberGenerator.new()

var is_battling: bool = false


func _ready() -> void:
	show_choice()


func _process(_delta: float) -> void:
	if not action_choice.visible:
		if Input.is_action_just_pressed("ui_up"):
			if action_target > 0:
				action_target -= 1
				
		if Input.is_action_just_pressed("ui_down"):
			if action_target < enemies.size() - 1:
				action_target += 1
				
		if Input.is_action_just_pressed("ui_accept"):
			action_queue.push_back({
				chosen_action = chosen_action,
				target = action_target
			})
			if current_player + 1 < players.size():
				current_player += 1
			clear_action_target_focus()
			show_choice()

	if action_queue.size() == players.size() and not is_battling:
		is_battling = true
		start_battle_sequence()


func start_battle_sequence():
	action_choice.hide()
	for action in action_queue:
		print(action)
		match action.chosen_action:
			"attack": enemies[action.target].take_damage(1)
			"defend": players[action.target].is_defending = true
			"magic": enemies[action.target].take_damage(rng.randi_range(1, 5))
		await get_tree().create_timer(1).timeout
	
	end_battle_sequence()

func end_battle_sequence():
	is_battling = false
	current_player = 0
	playerGroup._reset_defend()
	action_queue.clear()
	show_choice()

func generate_enemy_actions():
	pass

func show_choice():
	action_choice.show()
	action_choice.find_child("Attack").grab_focus()


func clear_action_target_focus() -> void:
	for enemy in enemies: enemy.unfocus()


func start_choose_action_target():
	action_choice.hide()
	clear_action_target_focus()
	action_target = 0


func _on_attack_pressed() -> void:
	start_choose_action_target()
	chosen_action = "attack"


func _on_defend_pressed() -> void:
	action_queue.push_back({chosen_action = "defend", target = current_player})
	if current_player + 1 < players.size(): current_player += 1


func _on_magic_pressed() -> void:
	chosen_action = "magic"
	start_choose_action_target()
