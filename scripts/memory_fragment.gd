extends Area2D

class_name MemoryFragment

@onready var state_manager: StateManager
@onready var texture_rect: TextureRect = $TextureRect
@onready var label: Label = $Label
@onready var balloon_scene = preload("res://dialogue/dialogue_balloon.tscn")

@export var sprite: Texture
@export var type: String

var player_in_area = false

func _ready() -> void:
	texture_rect.visible = false
	label.visible = false
	state_manager = get_tree().get_root().find_child("StateManager", true, false)
	$Sprite.texture = sprite
	
func say_text(text: String) -> void:
	var dialogue_text := "~ start\n : %s" % text
	var resource = DialogueManager.create_resource_from_text(dialogue_text)

	if resource == null:
		print("Failed to compile dialogue resource")
		return
	
	var balloon: BaseDialogueBalloon = balloon_scene.instantiate()
	get_tree().current_scene.add_child(balloon)
	balloon.start(resource, "start")

	while is_instance_valid(balloon) and balloon.get_parent() != null:
		await get_tree().process_frame
	
func _process(delta: float) -> void:
	if player_in_area:
		texture_rect.visible = true
		label.visible = true
	else:
		texture_rect.visible = false
		label.visible = false
	
	if player_in_area and Input.is_action_just_pressed("interact"):
		state_manager.collected_fragments[get_parent().name.to_lower()] = true
		say_text("You picked up %s" % type.to_upper())
		state_manager.switch_to("res://scenes/neighbourhood.tscn", "Neighbourhood")
		queue_free()

func _on_body_entered(body: CharacterBody2D) -> void:
	player_in_area = true
	
func _on_body_exited(body: CharacterBody2D) -> void:
	player_in_area = false
