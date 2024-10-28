extends Node2D

@onready var action_choice: VBoxContainer = $"./CanvasLayer/Choice"
@onready var enemyGroup = $EnemyGroup
@onready var enemies = $EnemyGroup.enemies
@onready var playerGroup = $PlayerGroup
@onready var players = $PlayerGroup.players

@export var player_id: int 


# handles target focus when attacking
var action_target: int = 0:
	set(new_action_target):
		enemies[action_target].unfocus()
		enemies[new_action_target].focus()
		action_target= new_action_target

var action_queue: Array = []
var chosen_action: String = ""
var rng: RandomNumberGenerator = RandomNumberGenerator.new()

var is_battling: bool = false
var healing_amount = 10 

func _ready() -> void:
	show_choice()
	$Textbox.hide()
	$GameOverScreen.hide()
	
	


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
			if playerGroup.current_player + 1 < players.size():
				playerGroup.current_player += 1
			enemyGroup.clear_focus()
			show_choice()
	
	if Input.is_action_just_pressed("ui_accept") and $Textbox.visible:
		$Textbox.hide()

	if action_queue.size() == players.size() and not is_battling:
		is_battling = true
		start_battle_sequence()



func start_battle_sequence():
	action_choice.hide()
	playerGroup.clear_focus()

	# player action phase
	for action in action_queue:
		print(action)
		
		# Check if player target exists before taking action
		if action.target >= players.size() or players[action.target] == null:
			continue  # Skip action if target player does not exist
		
		match action.chosen_action:
			"attack":
				var player = players[action.target]
				var damage = 2  
				if player.is_charging:
					damage *= player.charge_multiplier
					player.is_charging = false  
				enemyGroup.handle_damage(action.target, damage)
				display_text("Player %d attacked Enemy %d for %d damage" % [action.target + 1, action.target + 1, damage])
			"defend":
				players[action.target].is_defending = true
				display_text("Player %d is defending" % playerGroup.current_player)
			"magic":
				enemyGroup.handle_damage(action.target, rng.randi_range(1, 5))
				display_text("Player %d cast magic on Enemy %d for %d damage" % [action.target + 1, action.target + 1, rng.randi_range(1, 5)])
			"charge":
				players[action.target].is_charging = true 
				display_text("Player %d is charging up for a stronger attack" % [action.target + 1]) 
			"heal":
				var target_player = players[action.target]
				target_player.health = min(target_player.MAX_HEALTH, target_player.health + healing_amount)  
				display_text("Player %d healed for %d HP" % [action.target + 1, healing_amount])
				print("Healed player " + str(action.target) + " for " + str(healing_amount) + " HP")
		await get_tree().create_timer(1).timeout
		
	
	# enemy action phase
	var enemy_action_queue = generate_enemy_actions()
	for action in enemy_action_queue:
		print(action)
		if action.target >= players.size() or players[action.target] == null:
			continue
		match action.chosen_action:
			"attack":
				playerGroup.handle_damage(action.target, 2)
				display_text("Enemy %d attacked Player %d for 2 damage" % [action.target + 1 , action.target + 1])
			"magic":
				playerGroup.handle_damage(action.target, rng.randi_range(1, 5))
				display_text("Enemy %d cast magic on Player %d for %d damage" % [action.target + 1, action.target + 1, rng.randi_range(1, 5)])
		await get_tree().create_timer(1).timeout
	
	end_battle_sequence()


func end_battle_sequence():
	is_battling = false
	playerGroup.current_player = 0
	playerGroup._reset_defend()
	action_queue.clear()
	show_choice()
	check_game_over()
	print("Round Ended")


func generate_enemy_actions() -> Array:
	var queue = []
	for enemy in enemies:
		var action
		match rng.randi_range(0, 1):
			0: action = "attack"
			1: action = "magic"

		var target = rng.randi_range(0, players.size() - 1)
		queue.push_back({
			chosen_action = action,
			target = target
		})
	return queue

func show_choice():
	action_choice.show()
	action_choice.find_child("Attack").grab_focus()

func start_choose_action_target():
	action_choice.hide()
	enemyGroup.clear_focus()
	action_target = 0


func _on_attack_pressed() -> void:
	start_choose_action_target()
	chosen_action = "attack"


func _on_defend_pressed() -> void:
	action_queue.push_back({
		chosen_action = "defend",
		target = playerGroup.current_player
	})
	if playerGroup.current_player + 1 < players.size():
		playerGroup.current_player += 1


func _on_magic_pressed() -> void:
	chosen_action = "magic"
	start_choose_action_target()

func _on_charge_pressed() -> void:
	chosen_action = "charge"
	action_queue.push_back({
		chosen_action = "charge", 
		target = playerGroup.current_player
	})
	if playerGroup.current_player + 1 < players.size():
		playerGroup.current_player += 1
	show_choice()

func _on_heal_pressed() -> void:
	chosen_action = "heal"
	action_queue.push_back({
		chosen_action = "heal",
		target = playerGroup.current_player  # Heal self
	})
	if playerGroup.current_player + 1 < players.size():
		playerGroup.current_player += 1
	show_choice()
	
func display_text(text):
	$Textbox.show()
	$Textbox/RichTextLabel.text = text
	
	
func check_game_over():
	if playerGroup.players.size() == 0:
		display_game_over_screen("Game Over! Player Party wiped out. You Lose!")
	elif enemyGroup.enemies.size() == 0:
		display_game_over_screen("Victory! Enemy Party wiped out. You Win!")
		
func display_game_over_screen(message: String):
	$GameOverScreen.show() 
	$GameOverScreen/RichTextLabel.text = message  
	action_choice.hide()  
	$Textbox.hide()
