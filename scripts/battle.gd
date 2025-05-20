extends Control

@export var enemy: Resource = null

var current_player_health = 0
var current_enemy_health = 0

var is_defending = false

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
	
	$Enemy.texture = enemy.texture
	
	current_player_health = State.current_health
	current_enemy_health = enemy.health	
	
	$ActionsPanel.hide()
	await say_text("A wild %s appears" % enemy.name.to_upper())
	$ActionsPanel.show()

func set_health(progress_bar_node, health, max_health):
	progress_bar_node.value = health
	progress_bar_node.max_value = max_health
	progress_bar_node.get_node("Label").text = "HP:%d/%d" % [health, max_health]

func enemy_turn():
	await say_text("%s launches at you fiercely" % enemy.name.to_upper())
	
	if is_defending:
		is_defending = false
		# Do something specific when defending

	current_player_health = max(0, current_player_health - enemy.damage)
	set_health(player_progress, current_player_health, State.max_health)
	
	$AnimationPlayer.play("player_damaged")
	await $AnimationPlayer.animation_finished
	
	await say_text("You suffered %d damage" % enemy.damage)

func _on_run_pressed() -> void:
	await say_text("Got away safely")
	get_tree().quit()

func _on_attack_pressed() -> void:
	await say_text("You swing your sword")

	current_enemy_health = max(0, current_enemy_health - State.damage)
	set_health(enemy_progress, current_enemy_health, enemy.health)
	
	$AnimationPlayer.play("enemy_damaged")
	await $AnimationPlayer.animation_finished
	
	await say_text("You dealt %d damage" % State.damage)
	
	if current_enemy_health == 0:
		await say_text("enemy defeated")
		$AnimationPlayer.play("enemy_died")
		await $AnimationPlayer.animation_finished
	else:
		enemy_turn()

func _on_defend_pressed() -> void:
	is_defending = true
	await say_text("You defend")
	enemy_turn()
