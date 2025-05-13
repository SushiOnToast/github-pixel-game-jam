extends Node2D

var world := "neighbourhood"
# world paths
const NEIGHBOURHOOD_PATH = "res://scenes/neighbourhood.tscn"
const DREAM_PATH = "res://scenes/dream_world.tscn"

var current_scene: Node2D = null
var saved_scenes: Dictionary = {}

func switch_to(scene_path: String, scene_key: String) -> void:
	# if current scene exists, remove it but preserve state
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
	elif world == "dream":
		world = "neighbourhood"
		switch_to(NEIGHBOURHOOD_PATH, "Neighbourhood")
		
func _ready() -> void:
	switch_to(NEIGHBOURHOOD_PATH, "Neighbourhood")

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("switch world"):
		switch_world()
