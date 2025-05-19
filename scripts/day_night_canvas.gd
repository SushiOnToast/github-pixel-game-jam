extends CanvasModulate

class_name DayNightManager

@onready var neighbours: Node = $"../Neighbours"
@onready var state_manager: StateManager = get_tree().get_root().find_child("StateManager", true, false)

const CYCLE_DURATION = PI/2 

@export var gradient: GradientTexture1D
@export var cycle_speed: float = 200 
@export var is_night = false

var time: float = 0.0
var cycle_finished: bool = false
var animation_playing := false

func _process(delta: float) -> void:
	if not cycle_finished:
		var value = (sin(time - (PI / 2)) + 1.0)
		self.color = gradient.gradient.sample(value)
		
	var all_interaction = _all_neighbours_interacted()
	
	time += delta / cycle_speed
	
	if time >= CYCLE_DURATION:
		cycle_finished = true
	
	if all_interaction and not is_night:
		animation_playing = true
		is_night = true	
		state_manager.animation_player.play("night_transition")
		await state_manager.animation_player.animation_finished
		animation_playing = false
		state_manager.animation_player.play_backwards("night_transition")
	
	if is_night and not animation_playing:
		self.color = Color("#1e2237")
		
	if Input.is_action_just_pressed("switch world"):
		is_night = true
		all_interaction = true
		_set_all_night()
		
#func _all_neighbours_interacted():
func _all_neighbours_interacted() -> bool:
	for child in neighbours.get_children():
		var c = child.get_children()[0]
		if c == null:
			continue
		if c.type == "bones":
			continue
		if not c.had_interaction:
			return false
	_set_all_night()
	return true
	
func _set_all_night():
	for child in neighbours.get_children():
		var c = child.get_children()[0]
		c.night = true
