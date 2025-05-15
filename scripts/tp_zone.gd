extends Area2D

@export var to_scene: PackedScene

@onready var state_manager: StateManager
@onready var texture_rect: TextureRect = $TextureRect
@onready var label: Label = $Label
@onready var animation_player: AnimationPlayer = $Transition/AnimationPlayer

var player_in_area = false

var to_scene_path: String = ""
var to_scene_key: String = ""

func _ready() -> void:
	texture_rect.visible = false
	label.visible = false
	
	state_manager = get_tree().get_root().find_child("StateManager", true, false)

	# Automatically extract path and key if a scene is assigned
	if to_scene:
		to_scene_path = to_scene.resource_path
		to_scene_key = to_scene.resource_path.get_file().get_basename()

	# Fallback to neighbourhood if parent is a house and no scene explicitly set
	var parent_name = get_parent().name
	if parent_name.begins_with("House") and to_scene_path == "":
		to_scene_path = "res://scenes/neighbourhood.tscn"
		to_scene_key = "Neighbourhood"
	
func _process(delta: float) -> void:
	texture_rect.visible = player_in_area
	label.visible = player_in_area

	if player_in_area and Input.is_action_just_pressed("interact"):	
		#animation_player.play("dissolve")
		#await animation_player.animation_finished
		state_manager.switch_to(to_scene_path, to_scene_key)
		#animation_player.play_backwards("dissolve")

func _on_body_entered(body: CharacterBody2D) -> void:
	player_in_area = true
	
func _on_body_exited(body: CharacterBody2D) -> void:
	player_in_area = false
