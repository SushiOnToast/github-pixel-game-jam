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
var had_night_interaction := false
var is_talking := false

func _ready() -> void:
	texture_rect.visible = false
	label.visible = false
	convo_path = neighbour.return_convo_path()
	type = neighbour.NPC_type

func _process(delta: float) -> void:
	if night and type != "bones":
		neighbour.should_clear = true
	
	_update_interaction_ui()

	if _can_start_conversation():
		_start_conversation()

func _update_interaction_ui() -> void:
	var show_ui := false

	if type == "bones":
		show_ui = player_in_area and not is_talking
	else:
		show_ui = player_in_area and not night

	texture_rect.visible = show_ui
	label.visible = show_ui

func _can_start_conversation() -> bool:
	if not player_in_area or is_talking or not Input.is_action_just_pressed("interact"):
		return false

	if type == "bones":
		return true  # Allow dialogue even at night or after interaction
	else:
		return not night

func _start_conversation() -> void:
	is_talking = true
	state_manager.dialogue = true
	
	if type == "bones":
		if night:
			if had_night_interaction:
				convo_path = "res://dialogue/conversations/bones/night_post_interaction.dialogue"
			else:	
				convo_path = "res://dialogue/conversations/bones/night.dialogue"
		else:
			if had_interaction:
				convo_path = "res://dialogue/conversations/bones/day_post_interaction.dialogue"

	var balloon: BaseDialogueBalloon = balloon_scene.instantiate()
	get_tree().current_scene.add_child(balloon)
	balloon.start(load(convo_path), "start")

	await _wait_for_balloon_end(balloon)
	
	if night:
		had_night_interaction = true

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
