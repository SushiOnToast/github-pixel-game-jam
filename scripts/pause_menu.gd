extends Control

@onready var state_manager: StateManager = get_tree().get_root().find_child("StateManager", true, false)
	
func _process(delta) -> void:
	if Input.is_action_just_pressed("quit"):
		get_tree().quit()
	if Input.is_action_just_pressed("ui_accept"):
		state_manager.resume()
