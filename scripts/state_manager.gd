# StateManager.gd
extends Node

class_name StateManager  # This allows you to reference it anywhere via `StateManager`

@onready var animation_player: AnimationPlayer = $Transition/AnimationPlayer

var world := "neighbourhood"

# world paths
const NEIGHBOURHOOD_PATH = "res://scenes/neighbourhood.tscn"
const START_MENU_PATH = "res://scenes/start_menu.tscn"
const PAUSE_MENU_PATH = "res://scenes/pause_menu.tscn"
 

var prev_scene: Node = null
var prev_scene_path: String = ""

var current_scene: Node = null
var current_scene_path: String
var saved_scenes: Dictionary = {}

var transitioning := false

var dialogue: bool

func switch_to(scene_path: String, scene_key: String) -> void:
	if transitioning:
		return
	
	transitioning = true
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
		
	current_scene_path = scene_path
	
	add_child(current_scene)
	animation_player.play_backwards("dissolve")
	await animation_player.animation_finished

	transitioning = false
	
func initialize() -> void:
	switch_to(NEIGHBOURHOOD_PATH, "Neighbourhood")
	
func show_menu() -> void:
	switch_to(START_MENU_PATH, "StartMenu")
	
#func show_pause() -> void:
	#if transitioning or current_scene.name == "StartMenu":
		#return
	#
	#prev_scene = current_scene
	#prev_scene_path = current_scene_path
	#
	#switch_to(PAUSE_MENU_PATH, "PauseMenu")
	#
#func resume() -> void:
	#switch_to(prev_scene_path, prev_scene.name)
