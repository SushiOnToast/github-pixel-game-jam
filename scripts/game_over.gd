extends Control

class_name GameOver

var balloon_scene = preload("res://dialogue/dialogue_balloon.tscn")
@onready var game_over_sceen: Panel = $GameOverSceen
@onready var state_manager: StateManager = get_tree().get_root().find_child("StateManager", true, false)

@export var target_scene_path: String
@export var target_scene_key: String

func _ready():
	game_over_sceen.hide()
	
	await get_tree().create_timer(1.0).timeout
	
	var balloon: BaseDialogueBalloon = balloon_scene.instantiate()
	get_tree().current_scene.add_child(balloon)
	balloon.start(load("res://dialogue/conversations/game_over.dialogue"), "start")
	await _wait_for_balloon_end(balloon)
	
	await get_tree().create_timer(1.0).timeout

	game_over_sceen.show()
	$AnimationPlayer.play("show")
	await $AnimationPlayer.animation_finished
	
func _process(delta) -> void:
	if game_over_sceen.visible:
		if Input.is_action_just_pressed("quit"):
			get_tree().quit()
		if Input.is_action_just_pressed("ui_accept"):
			state_manager.switch_to("res://scenes/neighbourhood.tscn", "Neighbourhood")
	
func _wait_for_balloon_end(balloon: BaseDialogueBalloon) -> void:
	while is_instance_valid(balloon) and balloon.get_parent() != null:
		await get_tree().process_frame
