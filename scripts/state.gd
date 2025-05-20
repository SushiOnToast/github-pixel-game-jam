extends Node


var current_health = 50
var max_health = 50
var damage = 20
var game_over = false

var target_scene_path: String
var target_scene_key: String

var current_battle:String = "res://enemies/amelia.tres"

var house_mapping: Dictionary = {
	"amelia": "res://enemies/amelia.tres",
	"scout1": "res://enemies/scout1.tres",
	"alex": "res://enemies/alex.tres",
	"bob": "res://enemies/bob.tres",
	"adam": "res://enemies/adam.tres",
}

var tp_dict: Dictionary = {
	"res://enemies/amelia.tres": "res://scenes/houses/amelia.tscn",
	"res://enemies/scout1.tres": "res://scenes/houses/amelia.tscn",
	"res://enemies/alex.tres": "res://scenes/houses/amelia.tscn",
	"res://enemies/bob.tres": "res://scenes/houses/amelia.tscn",
	"res://enemies/adam.tres": "res://scenes/houses/amelia.tscn",
}

var key_dict: Dictionary = {
	"res://scenes/houses/amelia.tscn": "amelia",
	"res://scenes/houses/alex.tscn": "alex",
	"res://scenes/houses/scout1.tscn": "scout1",
	"res://scenes/houses/bob.tscn": "bob",
	"res://scenes/houses/adam.tscn": "adam",
}


var memory_fragment_tracking = {
	"amelia": false,
	"alex": false,
	"bob": false,
	"adam": false,
	"scout1": false,
}
