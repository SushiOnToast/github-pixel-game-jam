extends Control

@export var enemy: Resource = null

var current_player_health = 0
var current_enemy_health = 0

var shield_active = false         # Shield reduces damage for next enemy attack
var skip_next_turn = false        # Skip player's next turn (e.g., due to reflect)
var buff_next_attack = false      # Next player attack buffed (from shield)
var is_nullifying = false         # Player currently nullifying (reflect)
var turn_state = "PLAYER"
var shield_used = false 

# New debuff states
var clarity_debuff_active = false    # Next attack damage halved (mental fatigue)
var reflect_skip_next_turn = false   # Player must skip next turn after reflect
var enemy_damage_buff_percent = 0.0  # % increase to enemy next attack damage (after reflect)

@onready var buttons = {
	"attack1": $ActionsPanel/Actions/Attack1Button,
	"attack2": $ActionsPanel/Actions/Attack2Button,
	"defend": $ActionsPanel/Actions/DefendButton
}

@onready var minigame_scene = preload("res://scenes/timing_minigame.tscn")

@onready var state_manager: StateManager = get_tree().get_root().find_child("StateManager", true, false)

@onready var balloon_scene = preload("res://dialogue/dialogue_balloon.tscn")
@onready var player_progress: ProgressBar = $MarginContainer/ProgressPanel/PlayerProgress
@onready var enemy_progress: ProgressBar = $MarginContainer/ProgressPanel/EnemyProgress

func say_text(text: String) -> void:
	$ActionsPanel.hide()
	var dialogue_text := "~ start\n : %s" % text
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
	enemy =  load(State.current_battle)
	set_health(enemy_progress, enemy.health, enemy.health)
	set_health(player_progress, State.current_health, State.max_health)

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
	$ActionsPanel.hide()
	await say_text("%s lashes out!" % enemy.name.to_upper())

	if is_nullifying:
		is_nullifying = false
		reflect_skip_next_turn = true    # Must skip next player turn after nullify
		enemy_damage_buff_percent = 0.25  # Increase enemy next attack damage by 25%
		await say_text("You completely reject the attack, but must recover focus next turn!")
		turn_state = "PLAYER"
		$ActionsPanel.show()
		return

	var damage_taken = enemy.damage

	# Apply enemy damage buff from reflect debuff if active
	if enemy_damage_buff_percent > 0.0:
		damage_taken = int(damage_taken * (1.0 + enemy_damage_buff_percent))
		enemy_damage_buff_percent = 0.0  # Reset after applying once

	if shield_active:
		damage_taken = int(damage_taken * 0.5)
		await say_text("Your mental barrier softened the blow!")
		shield_active = false  # Shield used up

	current_player_health = max(0, current_player_health - damage_taken)
	set_health(player_progress, current_player_health, State.max_health)
	$ActionsPanel.hide()
	$AnimationPlayer.play("player_damaged")
	await $AnimationPlayer.animation_finished
	await say_text("You took %d damage" % damage_taken)

	if current_player_health == 0:
		await say_text("You lost the duel...")
		$ActionsPanel.hide()
		$AnimationPlayer.play("player_died")
		await $AnimationPlayer.animation_finished
		state_manager.switch_to("res://scenes/game_over.tscn", "GameOver")

	turn_state = "PLAYER"
	$ActionsPanel.show()

func handle_defend(action: MindDuelAction):
	match action.defend_type:
		"RESIST":
			if not shield_used:
				shield_active = true
				buff_next_attack = true
				shield_used = true
				await say_text("You raise a mental barrier. Your next attack will be empowered!")
			else:
				# Shield penalty: skip next turn, but empower next attack
				skip_next_turn = true
				buff_next_attack = true
				await say_text("You strain your mind to maintain the shield and must skip your next turn, but your next attack will be empowered!")
		"CALM":
			current_player_health = min(State.max_health, current_player_health + action.damage)
			set_health(player_progress, current_player_health, State.max_health)
			await say_text("You regain clarity (+%d HP), but your mind feels fatigued..." % action.damage)
			clarity_debuff_active = true  # Next attack damage halved
			turn_state = "ENEMY"
			await enemy_turn()
			return
		"REFLECT":
			is_nullifying = true
			await say_text("You reflect and reject the negative thought")
		_:
			await say_text("You defend yourself")

	# End turn unless HEAL
	turn_state = "ENEMY"
	await enemy_turn()

var _minigame_success = false
signal minigame_result_signal

func run_minigame() -> bool:
	var minigame = minigame_scene.instantiate()
	self.add_child(minigame)

	var success = await minigame.result

	return success

func _on_minigame_result(success: bool) -> void:
	_minigame_success = success
	emit_signal("minigame_result_signal")

func handle_attack(action: MindDuelAction):
	# Skip attack if skipping next turn due to shield penalty or reflect debuff
	if skip_next_turn or reflect_skip_next_turn:
		if skip_next_turn:
			await say_text("You maintain your mental barrier and skip this attack.")
			skip_next_turn = false
		elif reflect_skip_next_turn:
			await say_text("You are recovering focus and must skip your attack this turn.")
			reflect_skip_next_turn = false
		shield_active = false
		turn_state = "ENEMY"
		await enemy_turn()
		return

	if action.triggers_minigame:
		await say_text("You prepare for a mental challenge!")
		var success = await run_minigame()
		if success:
			await say_text("You pushed through!")
		else:
			await say_text("You failed the mental challenge!")
			# Skip damage application and enemy turn; or just end turn
			turn_state = "ENEMY"
			await enemy_turn()
			return
	else:
		await say_text("You strike with: %s" % action.name)


	var damage = action.damage

	if buff_next_attack:
		damage = int(damage * 1.5)
		buff_next_attack = false  # Reset buff after use

	# Apply clarity debuff to halve attack damage
	if clarity_debuff_active:
		damage = int(damage * 0.5)
		clarity_debuff_active = false  # Reset after applying once
		await say_text("Mental fatigue reduces your attack damage!")

	current_enemy_health = max(0, current_enemy_health - damage)
	set_health(enemy_progress, current_enemy_health, enemy.health)
	$ActionsPanel.hide()

	$AnimationPlayer.play("enemy_damaged")
	await $AnimationPlayer.animation_finished
	await say_text("You dealt %d damage" % damage)

	if current_enemy_health == 0:
		await say_text("Enemy defeated")
		$AnimationPlayer.play("enemy_died")
		await $AnimationPlayer.animation_finished
		State.memory_fragment_tracking[State.key_dict[State.tp_dict[State.current_battle]]] = true
		state_manager.switch_to(state_manager.prev_scene_path, state_manager.prev_scene.name)
		
	else:
		turn_state = "ENEMY"
		await enemy_turn()

func _on_action_button_pressed(button: Button):
	if turn_state != "PLAYER":
		return  # Ignore input if not player's turn

	var index = button.get_meta("action_index") as int
	var action: MindDuelAction = enemy.actions[index]

	match action.type:
		MindDuelAction.ActionType.ATTACK:
			await handle_attack(action)
		MindDuelAction.ActionType.DEFEND:
			await handle_defend(action)
