extends Area2D

@export var to_scene: PackedScene

@onready var state_manager: StateManager = get_tree().get_root().find_child("StateManager", true, false)
@onready var day_night_manager: DayNightManager = get_tree().get_root().find_child("DayNightManager", true, false)
@onready var texture_rect: TextureRect = $TextureRect
@onready var label: Label = $Label

var player_in_area: bool = false
var to_scene_path: String = ""
var to_scene_key: String = ""
var parent_name: String = ""

var dream_has_fragment = true	

func _ready() -> void:
	texture_rect.visible = false
	label.visible = false

	# Extract path and key if a scene is assigned
	if to_scene:
		to_scene_path = to_scene.resource_path
		to_scene_key = to_scene_path.get_file().get_basename()

	# Fallback for houses with no explicit scene
	parent_name = get_parent().name
	if parent_name.begins_with("House") and to_scene_path == "":
		to_scene_path = "res://scenes/neighbourhood.tscn"
		to_scene_key = "Neighbourhood"

func _process(_delta: float) -> void:
	var is_house = parent_name.begins_with("House")
	var is_night = true	
	if !parent_name.begins_with("House"):
		is_night = day_night_manager.is_night
	var is_dream_with_fragment_collected = false

	if to_scene_key.begins_with("Dream".to_lower()):
		is_dream_with_fragment_collected = state_manager.collected_fragments.has(to_scene_key.to_lower())

	if is_house or is_night:
		if player_in_area and Input.is_action_just_pressed("interact"):
			if is_dream_with_fragment_collected:
				return
			state_manager.switch_to(to_scene_path, to_scene_key)

		# Only show the label/texture if the fragment is not collected
		var can_show_prompt = not is_dream_with_fragment_collected
		texture_rect.visible = player_in_area and can_show_prompt
		label.visible = player_in_area and can_show_prompt
	else:
		texture_rect.visible = false
		label.visible = false


func _on_body_entered(_body: CharacterBody2D) -> void:
	player_in_area = true

func _on_body_exited(_body: CharacterBody2D) -> void:
	player_in_area = false
