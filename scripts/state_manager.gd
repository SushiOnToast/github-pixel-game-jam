# StateManager.gd
extends Node

class_name StateManager  # This allows you to reference it anywhere via `StateManager`

var world := "neighbourhood"

# world paths
const NEIGHBOURHOOD_PATH = "res://scenes/neighbourhood.tscn"
const DREAM_PATH = "res://scenes/dream_world.tscn"

var current_scene: Node2D = null
var saved_scenes: Dictionary = {}

func switch_to(scene_path: String, scene_key: String) -> void:
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

func switch_world() -> void:
	if world == "neighbourhood":
		world = "dream"
		switch_to(DREAM_PATH, "DreamWorld")
	else:
		world = "neighbourhood"
		switch_to(NEIGHBOURHOOD_PATH, "Neighbourhood")
		

func initialize() -> void:
	switch_to(NEIGHBOURHOOD_PATH, "Neighbourhood")
