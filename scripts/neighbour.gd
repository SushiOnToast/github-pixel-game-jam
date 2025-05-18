extends CharacterBody2D
class_name NeighbourBody

@export var conversation_file: Resource
@export var NPC_type: String = ""

var should_clear := false

func _process(delta: float) -> void:
	if should_clear:
		queue_free()

func return_convo_path():
	if conversation_file:
		var path = conversation_file.resource_path
		return path
