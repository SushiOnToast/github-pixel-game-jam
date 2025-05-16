# StateManager.gd
extends Node

class_name StateManager  # This allows you to reference it anywhere via `StateManager`

@onready var animation_player: AnimationPlayer = $Transition/AnimationPlayer

var world := "neighbourhood"

# world paths
const NEIGHBOURHOOD_PATH = "res://scenes/neighbourhood.tscn"
const DREAM_PATH = "res://scenes/dream_world.tscn"

var current_scene: Node2D = null
var saved_scenes: Dictionary = {}

func switch_to(scene_path: String, scene_key: String) -> void:
	animation_player.play("dissolve")
	await animation_player.animation_finished
	
	if current_scene:
		remove_child(current_scene)
		saved_scenes[current_scene.name] = current_scene

	if saved_scenes.has(scene_key):
		current_scene = saved_scenes[scene_key]
	else:
		var scene_resource = load(scene_path)
		current_scene = scene_resource.instantiate()
		saved_scenes[scene_key] = current_scene
	
	add_child(current_scene)
	animation_player.play_backwards("dissolve")
	
func initialize() -> void:
	switch_to(NEIGHBOURHOOD_PATH, "Neighbourhood")
