extends Area2D
class_name Neighbour

var balloon_scene = preload("res://dialogue/dialogue_balloon.tscn")

@onready var state_manager: StateManager = get_tree().get_root().find_child("StateManager", true, false)
@onready var texture_rect: TextureRect = $TextureRect
@onready var label: Label = $Label
@onready var neighbour: NeighbourBody = $".."

@export var type: String
@export var had_interaction := false
@export var night := false

var convo_path
var player_in_area := false
var num_interactions := 0
var is_talking := false

func _ready() -> void:
	texture_rect.visible = false
	label.visible = false
	convo_path = neighbour.return_convo_path()
	type = neighbour.NPC_type

func _process(delta: float) -> void:
	_update_interaction_ui()

	if _can_start_conversation():
		_start_conversation()

func _update_interaction_ui() -> void:
	var show_ui := player_in_area and (
		(not had_interaction) or
		(night and num_interactions == 1)
	)
	
	texture_rect.visible = show_ui
	label.visible = show_ui

func _can_start_conversation() -> bool:
	return (
		player_in_area and
		Input.is_action_just_pressed("interact") and
		not had_interaction and
		not night and
		not is_talking
	)

func _start_conversation() -> void:
	is_talking = true
	state_manager.dialogue = true

	var balloon: BaseDialogueBalloon = balloon_scene.instantiate()
	get_tree().current_scene.add_child(balloon)
	balloon.start(load(convo_path), "start")

	await _wait_for_balloon_end(balloon)

	had_interaction = true
	is_talking = false
	state_manager.dialogue = false

func _wait_for_balloon_end(balloon: BaseDialogueBalloon) -> void:
	while is_instance_valid(balloon) and balloon.get_parent() != null:
		await get_tree().process_frame

func _on_body_entered(body: CharacterBody2D) -> void:
	player_in_area = true

func _on_body_exited(body: CharacterBody2D) -> void:
	player_in_area = false
