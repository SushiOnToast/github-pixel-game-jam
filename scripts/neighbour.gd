extends CharacterBody2D
class_name NeighbourBody

@export var conversation_file: Resource

func return_convo_path():
	if conversation_file:
		var path = conversation_file.resource_path
		return path
