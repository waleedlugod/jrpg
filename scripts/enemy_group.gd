extends Node2D

var enemies: Array = []
var action_queue: Array  = []
var is_battling: bool = false
var index: int = 0
var currentAction: String = ""

signal next_player
@onready var choice: VBoxContainer = $"../CanvasLayer/Choice"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	enemies = get_children()
	for i in enemies.size():
		enemies[i].position = Vector2(0, i*36)
		
	show_choice()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if not choice.visible:
		if Input.is_action_just_pressed("ui_up"):
			if index > 0:
				index -= 1
				switch_focus(index, index+1)
				
		if Input.is_action_just_pressed("ui_down"):
			if index < enemies.size() - 1:
				index += 1
				switch_focus(index, index-1)
				
		if Input.is_action_just_pressed("ui_accept"):
			action_queue.push_back([currentAction, index])
			emit_signal("next_player")
			_reset_focus()
			show_choice()
		
	if action_queue.size() == enemies.size() and not is_battling:
		is_battling = true
		_action(action_queue)
			
func _action(stack):
	for action in stack:
		match action[0]:
			"attack":
				enemies[action[1]].take_damage(1)
				await get_tree().create_timer(1).timeout
			"defend": # defend logic
				pass
			"magic": # magic logic
				enemies[action[1]].take_damage(3)
				await get_tree().create_timer(1).timeout
				pass
	action_queue.clear()
	is_battling = false
	show_choice()

func switch_focus(x,y):
	enemies[x].focus()
	enemies[y].unfocus()
	
func show_choice():
	choice.show()
	choice.find_child("Attack").grab_focus()
	
func _reset_focus():
	index = 0
	for enemy in enemies:
		enemy.unfocus()
		
func _start_choosing():
	_reset_focus()
	enemies[0].focus()


func _on_attack_pressed() -> void:
	currentAction = "attack"
	choice.hide()
	_start_choosing()

func _on_defend_pressed() -> void:
	action_queue.push_back(["defend"])
	emit_signal("next_player")

func _on_magic_pressed() -> void:
	currentAction = "magic"
	choice.hide()
	_start_choosing()
