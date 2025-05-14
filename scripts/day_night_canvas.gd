extends CanvasModulate

const MINUTES_PER_DAY = 1440
const INGAME_TO_REAL_MINUTE_DURATION = (2 * PI) / MINUTES_PER_DAY
const CYCLE_DURATION = PI/2  # One full sine wave cycle

@export var gradient: GradientTexture1D
@export var cycle_speed: float = 100.0 # Adjust this to make it slower/faster

var time: float = 0.0
var cycle_finished: bool = false

func _process(delta: float) -> void:
	if cycle_finished:
		return
	
	time += delta / cycle_speed
	
	var value = (sin(time - (PI/2)) + 1.0)
	self.color = gradient.gradient.sample(value)
	
	if time >= CYCLE_DURATION:
		cycle_finished = true
	
	_recalculate_time()

func _recalculate_time() -> void:
	var total_minutes = int(time / INGAME_TO_REAL_MINUTE_DURATION)
