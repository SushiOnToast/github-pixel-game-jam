extends Node


var current_health = 50
var max_health = 50
var damage = 20
var game_over = false

var target_scene_path: String
var target_scene_key: String

var house_mapping: Dictionary = {
	"amelia": "res://enemies/amelia.tres",
	"scout1": "res://enemies/scout1.tres",
	"alex": "res://enemies/alex.tres",
	"bob": "res://enemies/bob.tres",
	"adam": "res://enemies/adam.tres",
}
