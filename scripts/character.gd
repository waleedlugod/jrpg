extends CharacterBody2D


@onready var _focus: Sprite2D = $focus
@onready var progress_bar: ProgressBar = $ProgressBar
@onready var animation_player: AnimationPlayer = $AnimationPlayer

@export var MAX_HEALTH: float = 7

var is_defending: bool = false

var health: float = 7:
	set(value):
		health = value
		_update_progress_bar()
		_play_animation()
		
func _update_progress_bar():
	progress_bar.value = (health/MAX_HEALTH) * 100
	
func _play_animation():
	animation_player.play("hurt")

func focus():
	_focus.show()

func unfocus():
	_focus.hide()

func take_damage(value):
	if not is_defending: health -= value
