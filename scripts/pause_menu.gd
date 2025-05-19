extends Control

@onready var state_manager: StateManager = get_tree().get_root().find_child("StateManager", true, false)

func _on_menu_actioned(item: Control) -> void:
	if item.text == "Resume":
		pass
	elif item.text == "Quit":
		get_tree().quit()
