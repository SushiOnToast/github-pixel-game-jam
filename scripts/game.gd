# game.gd
extends Node2D

@onready var state_manager: StateManager = $StateManager

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	state_manager.initialize()
