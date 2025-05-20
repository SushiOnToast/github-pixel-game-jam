extends Control

var balloon_scene = preload("res://dialogue/dialogue_balloon.tscn")
@onready var final_screen: Panel = $FinalUI
@onready var state_manager: StateManager = get_tree().get_root().find_child("StateManager", true, false)

@export var target_scene_path: String
@export var target_scene_key: String

func _ready():
	final_screen.hide()
	
	await get_tree().create_timer(1.0).timeout
	
	var balloon: BaseDialogueBalloon = balloon_scene.instantiate()
	get_tree().current_scene.add_child(balloon)
	balloon.start(load("res://dialogue/conversations/final.dialogue"), "start")
	await _wait_for_balloon_end(balloon)
	
	await get_tree().create_timer(1.0).timeout

	final_screen.show()
	$AnimationPlayer.play("show")
	await $AnimationPlayer.animation_finished
	
func _process(delta) -> void:
	if final_screen.visible:
		if Input.is_action_just_pressed("quit"):
			get_tree().quit()
	
func _wait_for_balloon_end(balloon: BaseDialogueBalloon) -> void:
	while is_instance_valid(balloon) and balloon.get_parent() != null:
		await get_tree().process_frame
