extends CanvasModulate

@onready var neighbours: Node = $"../../Neighbours"

const CYCLE_DURATION = PI/2  # One full sine wave cycle

@export var gradient: GradientTexture1D
@export var cycle_speed: float = 100.0 # Adjust this to make it slower/faster
@export var is_night = false

var time: float = 0.0
var cycle_finished: bool = false

func _process(delta: float) -> void:
	if cycle_finished:
		return
		
	#if not done_checked and _all_neighbours_interacted():
		#print("done")
		#done_checked = true
		
	var all_interaction = _all_neighbours_interacted()
	
	time += delta / cycle_speed
	
	var value = (sin(time - (PI / 2)) + 1.0)
	self.color = gradient.gradient.sample(value)
	
	if time >= CYCLE_DURATION:
		cycle_finished = true
		is_night = true	
	
	if is_night:
		self.color = Color("#1e2237")
		
#func _all_neighbours_interacted():
func _all_neighbours_interacted() -> bool:
	for child in neighbours.get_children():
		var c = child.get_children()[0]
		if c == null or not c.had_interaction:
			return false
	_set_all_night()
	return true
	
func _set_all_night():
	for child in neighbours.get_children():
		var c = child.get_children()[0]
		c.night = true
