# game.gd
extends Node2D

@onready var pause_menu: Control = $PauseMenu
@onready var state_manager: StateManager = $StateManager
@onready var game_over: GameOver = $GameOver

var paused = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	state_manager.show_menu()

func _process(delta: float) -> void:
	if State.game_over:
		state_manager.switch_to("res://scenes/game_over.tscn", "GameOver")
	if state_manager.collected_fragments.size() == 5:
		await get_tree().create_timer(2.0).timeout
		state_manager.switch_to("res://scenes/final_scene.tscn", "FinalScene")
		
#func _process(delta: float) -> void:
	#print(state_manager.collected_fragments)
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
