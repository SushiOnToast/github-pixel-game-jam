extends Area2D
class_name Neighbour

var balloon_scene = preload("res://dialogue/dialogue_balloon.tscn")

@onready var state_manager: StateManager
@onready var texture_rect: TextureRect = $TextureRect
@onready var label: Label = $Label

var player_in_area = false
var num_interactions = 0
@export var had_interaction = false
@export var night = false

func _ready() -> void:
	texture_rect.visible = false
	label.visible = false
	state_manager = get_tree().get_root().find_child("StateManager", true, false)
	
func _process(delta: float) -> void:
	if player_in_area and not had_interaction or player_in_area and night and num_interactions == 1:
		texture_rect.visible = true
		label.visible = true
	else:
		texture_rect.visible = false
		label.visible = false
		
	if player_in_area and Input.is_action_just_pressed("jump or interact") and not had_interaction and not night:
		var balloon: BaseDialogueBalloon = balloon_scene.instantiate()
		get_tree().current_scene.add_child(balloon)
		balloon.start(load("res://dialogue/conversations/NPC1.dialogue"), "start")
		
		while is_instance_valid(balloon) and balloon.get_parent() != null:
			await get_tree().process_frame
		
		had_interaction = true
		num_interactions += 1
	elif night and player_in_area and Input.is_action_just_pressed("jump or interact") and num_interactions == 1:
		num_interactions += 1
		state_manager.switch_world()

func _on_body_entered(body: CharacterBody2D) -> void:
	player_in_area = true


func _on_body_exited(body: CharacterBody2D) -> void:
	player_in_area = false
