extends Node2D

var world := "neighbourhood"

var neighbourhood_scene: Node2D
var dream_scene: Node2D

func _ready() -> void:
	# Instance both scenes once
	neighbourhood_scene = preload("res://scenes/neighbourhood.tscn").instantiate()
	dream_scene = preload("res://scenes/dream_world.tscn").instantiate()

	# Add them both to the current scene tree
	add_child(neighbourhood_scene)
	add_child(dream_scene)

	# Start with only neighbourhood visible
	neighbourhood_scene.visible = true
	dream_scene.visible = false


func switch_world() -> void:
	if world == "neighbourhood":
		world = "dream"
		neighbourhood_scene.visible = false
		dream_scene.visible = true
	elif world == "dream":
		world = "neighbourhood"
		neighbourhood_scene.visible = true
		dream_scene.visible = false
		

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("switch world"):
		switch_world()
