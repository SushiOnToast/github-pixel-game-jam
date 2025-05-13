# game.gd
extends Node2D

@onready var state_manager: StateManager = $StateManager

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	state_manager.initialize()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("switch world"):
		state_manager.switch_world()
