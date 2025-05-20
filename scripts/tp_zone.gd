extends Area2D

@export var to_scene: PackedScene
@export var battle: bool = false

@onready var state_manager: StateManager = get_tree().get_root().find_child("StateManager", true, false)
@onready var day_night_manager: DayNightManager = get_tree().get_root().find_child("DayNightManager", true, false)
@onready var texture_rect: TextureRect = $TextureRect
@onready var label: Label = $Label

var player_in_area: bool = false
var to_scene_path: String = ""
var to_scene_key: String = ""
var parent_name: String = ""

var house_mapping: Dictionary = State.house_mapping

@export var battle_scene: PackedScene = preload("res://scenes/battle.tscn")

func _ready() -> void:
	texture_rect.visible = false
	label.visible = false

	# Extract path and key if a scene is assigned
	if to_scene:
		to_scene_path = to_scene.resource_path
		to_scene_key = to_scene_path.get_file().get_basename()

	parent_name = get_parent().name

	# Fallback for house NPCs with no explicit scene
	if house_mapping.has(parent_name.to_lower()) and to_scene_path == "" and not battle:
		to_scene_path = "res://scenes/neighbourhood.tscn"
		to_scene_key = "Neighbourhood"

func _process(_delta: float) -> void:
	var is_house = house_mapping.has(parent_name.to_lower())
	var is_night = true
	if not is_house:
		is_night = day_night_manager.is_night
		
	if house_mapping.has(parent_name.to_lower()) and battle:
		if State.memory_fragment_tracking[parent_name.to_lower()]:
			queue_free()

	if is_house or is_night:
		if player_in_area and Input.is_action_just_pressed("interact"):
			if house_mapping.has(parent_name.to_lower()) and battle:
				var enemy_path = house_mapping[parent_name.to_lower()]
				State.current_battle = enemy_path
				state_manager.switch_to("res://scenes/battle.tscn", "Battle")
			else:
				state_manager.switch_to(to_scene_path, to_scene_key)

		texture_rect.visible = player_in_area
		label.visible = player_in_area
	else:
		texture_rect.visible = false
		label.visible = false

func _on_body_entered(_body: CharacterBody2D) -> void:
	player_in_area = true

func _on_body_exited(_body: CharacterBody2D) -> void:
	player_in_area = false
