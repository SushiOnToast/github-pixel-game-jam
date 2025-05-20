extends Control

@export var enemy: Resource = null

var current_player_health = 0
var current_enemy_health = 0

var is_defending = false

@onready var buttons = {
	"attack1": $ActionsPanel/Actions/Attack1Button,
	"attack2": $ActionsPanel/Actions/Attack2Button,
	"defend": $ActionsPanel/Actions/DefendButton
}

@onready var balloon_scene = preload("res://dialogue/dialogue_balloon.tscn")
@onready var player_progress: ProgressBar = $MarginContainer/ProgressPanel/PlayerProgress
@onready var enemy_progress: ProgressBar = $MarginContainer/ProgressPanel/EnemyProgress

func say_text(text: String) -> void:
	
	$ActionsPanel.hide()
	var dialogue_text := "~ start\n" + "Narrator: %s" % text
	var resource = DialogueManager.create_resource_from_text(dialogue_text)

	if resource == null:
		print("Failed to compile dialogue resource")
		return
	
	var balloon: BaseDialogueBalloon = balloon_scene.instantiate()
	get_tree().current_scene.add_child(balloon)
	balloon.start(resource, "start")

	while is_instance_valid(balloon) and balloon.get_parent() != null:
		await get_tree().process_frame
	
	$ActionsPanel.show()


func _ready() -> void:
	set_health(enemy_progress, enemy.health, enemy.health)
	set_health(player_progress, State.current_health, State.max_health)
	
	# Assign actions to buttons
	buttons["attack1"].text = enemy.actions[0].name
	buttons["attack2"].text = enemy.actions[1].name
	buttons["defend"].text = enemy.actions[2].name

	for i in range(3):
		var btn = buttons.values()[i]
		btn.set_meta("action_index", i)
		btn.pressed.connect(func(): _on_action_button_pressed(btn))

	
	$Enemy.texture = enemy.texture
	
	current_player_health = State.current_health
	current_enemy_health = enemy.health	
	
	$ActionsPanel.hide()
	await say_text("%s appears" % enemy.name.to_upper())
	$ActionsPanel.show()

func set_health(progress_bar_node, health, max_health):
	progress_bar_node.value = health
	progress_bar_node.max_value = max_health
	progress_bar_node.get_node("Label").text = "HP:%d/%d" % [health, max_health]

func enemy_turn():
	await say_text("%s lashes out!" % enemy.name.to_upper())

	var damage_taken = enemy.damage
	if is_defending:
		damage_taken = int(damage_taken * 0.5)
		is_defending = false  # Reset flag after one use
		await say_text("Your guard softened the blow!")

	current_player_health = max(0, current_player_health - damage_taken)
	set_health(player_progress, current_player_health, State.max_health)
	
	$AnimationPlayer.play("player_damaged")
	await $AnimationPlayer.animation_finished
	
	await say_text("You took %d damage" % damage_taken)
	
func handle_attack(action: MindDuelAction):
	if action.triggers_minigame:
		await say_text("You prepare for a mental challenge!")
		# Call your mini-game scene or logic here
		# Simulate success for now:
		await say_text("You overcame the guilt!")  # Example
	else:
		await say_text("You strike with: %s" % action.name)

	current_enemy_health = max(0, current_enemy_health - action.damage)
	set_health(enemy_progress, current_enemy_health, enemy.health)
	$AnimationPlayer.play("enemy_damaged")
	await $AnimationPlayer.animation_finished

	await say_text("You dealt %d damage" % action.damage)

	if current_enemy_health == 0:
		await say_text("Enemy defeated")
		$AnimationPlayer.play("enemy_died")
		await $AnimationPlayer.animation_finished
		
func handle_defend(action: MindDuelAction):
	match action.defend_type:
		"SHIELD":
			is_defending = true
			await say_text("You raise a mental barrier")
		"HEAL":
			current_player_health = min(State.max_health, current_player_health + action.damage)
			set_health(player_progress, current_player_health, State.max_health)
			await say_text("You regain clarity (+%d HP)" % action.damage)
		"NULLIFY":
			is_defending = true  # Add extra flag if needed to nullify all enemy damage
			await say_text("You reject the negative thought")
		_:
			await say_text("You defend yourself")


func _on_action_button_pressed(button: Button):
	var index = button.get_meta("action_index") as int
	var action: MindDuelAction = enemy.actions[index]

	match action.type:
		MindDuelAction.ActionType.ATTACK:
			await handle_attack(action)
		MindDuelAction.ActionType.DEFEND:
			await handle_defend(action)

	# If enemy still alive
	if current_enemy_health > 0:
		await enemy_turn()

		# Check if player died after enemy's turn
		if current_player_health == 0:
			await say_text("You lost the duel...")
			$AnimationPlayer.play("player_died")
			await $AnimationPlayer.animation_finished
			
			#await say_text("Everything fades to black...")
			#get_tree().change_scene_to_file("res://game_over_scene.tscn")  # replace with your actual game over scene
