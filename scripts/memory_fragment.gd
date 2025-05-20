extends Area2D

class_name MemoryFragment

@onready var state_manager: StateManager
@onready var texture_rect: TextureRect = $TextureRect
@onready var label: Label = $Label
@onready var balloon_scene = preload("res://dialogue/dialogue_balloon.tscn")

@export var sprite: Texture
@export var type: String

var player_in_area = false
var interacted = false

func _ready() -> void:
	self.visible = false
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
		
	if State.memory_fragment_tracking[get_parent().name.to_lower()]:
		self.visible = true
	
	if player_in_area and Input.is_action_just_pressed("interact") and not interacted:
		interacted = true	
		state_manager.dialogue = true
		state_manager.collected_fragments[get_parent().name.to_lower()] = true
		await say_text("You picked up %s" % type.to_upper())
		
		await get_tree().create_timer(1).timeout
		
		var balloon: BaseDialogueBalloon = balloon_scene.instantiate()
		get_tree().current_scene.add_child(balloon)
		balloon.start(load("res://dialogue/conversations/fragments/%s.dialogue" % get_parent().name.to_lower()), "start")
		await _wait_for_balloon_end(balloon)
		queue_free()
		
func _wait_for_balloon_end(balloon: BaseDialogueBalloon) -> void:
	while is_instance_valid(balloon) and balloon.get_parent() != null:
		await get_tree().process_frame
	state_manager.dialogue = false

func _on_body_entered(body: CharacterBody2D) -> void:
	player_in_area = true
	
func _on_body_exited(body: CharacterBody2D) -> void:
	player_in_area = false
