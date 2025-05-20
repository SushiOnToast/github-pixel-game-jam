# game.gd
extends Node2D

@onready var pause_menu: Control = $PauseMenu
@onready var state_manager: StateManager = $StateManager
@onready var game_over: GameOver = $GameOver

var final_played = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	state_manager.show_menu()

func _process(delta: float) -> void:
	if state_manager.collected_fragments.size() == 5 and !state_manager.dialogue and !final_played:
		final_played = true
		await get_tree().create_timer(2.0).timeout
		state_manager.switch_to("res://scenes/final_scene.tscn", "FinalScene")
	if Input.is_action_just_pressed("pause"):
		state_manager.show_pause()
