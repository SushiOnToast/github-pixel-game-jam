# game.gd
extends Node2D

@onready var pause_menu: Control = $PauseMenu
@onready var state_manager: StateManager = $StateManager
var paused = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	state_manager.show_menu()
	
#func _process(delta: float) -> void:
	#if Input.is_action_just_pressed("pause"):
		#pause()
		#
#func pause():
	#if paused:
		#pause_menu.hide()
		#Engine.time_scale = 1
	#else:
		#pause_menu.show()
		#Engine.time_scale = 0
