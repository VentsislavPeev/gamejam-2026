extends Node2D
#note for self, make a separate spawn time scene
#instead of using this script to control spawn
var max_health: int = 100
var current_health: int = 100
var elapsed := 0.0
var game_active: bool = true

@export var spawn_start_interval: float = 0.5   # early (seconds)
@export var spawn_end_interval: float = 0.12    # late (seconds)
@export var spawn_ramp_time: float = 60.0 
@export var enemy_scenes: Array[PackedScene] = []
@export var start_rates: Array[float] = [] # early game rates
@export var end_rates: Array[float] = []   # late game rates
@export var ramp_time := 60.0              # seconds until end_rates

@onready var spawn_timer: Timer = $SpawnTimer
@onready var timer: Timer = $Clock
@onready var ui: CanvasLayer = $UI
@onready var score_label: Label = $UI/ScoreLabel
@onready var health_bar: ProgressBar = $UI/HealthBar
@onready var time_label: Label = $UI/TimeLabel
@onready var pause_ui: Control = $UI/PauseUI
@onready var game_over_ui: Control = $UI/GameOverUI
@onready var game_over_score_label: Label = $UI/GameOverUI/ScoreLabel


func _ready() -> void:
	
	# Hide health bar initially? No, show during game
	health_bar.value = current_health
	health_bar.max_value = max_health
	pause_ui.visible = false
	game_over_ui.visible = false
	
	timer.start(90.0)  # 1:30 мин
	spawn_timer.wait_time = spawn_start_interval
	spawn_timer.start()
	

func current_rate(i: int) -> float:
	var t: float = clamp(elapsed / ramp_time, 0.0, 1.0)
	var a := start_rates[i] if i < start_rates.size() else 1.0
	var b := end_rates[i] if i < end_rates.size() else a
	return lerp(a, b, t)
	
func pick_enemy_by_rate() -> PackedScene:
	if enemy_scenes.is_empty():
		return null

	var total := 0.0
	for i in enemy_scenes.size():
		total += current_rate(i)

	var roll := randf() * total
	var acc := 0.0

	for i in enemy_scenes.size():
		acc += current_rate(i)
		if roll <= acc:
			return enemy_scenes[i]

	return enemy_scenes.back()

func spawn_mob():
	var scene := pick_enemy_by_rate()
	if scene == null:
		return

	var mob = scene.instantiate()
	%PathFollow2D.progress_ratio = randf()
	mob.global_position = %PathFollow2D.global_position
	add_child(mob)
	
func _on_timer_timeout():
	if not game_active:
		return
		
	spawn_mob()
	
	var t: float = clamp(elapsed / spawn_ramp_time, 0.0, 1.0)
	spawn_timer.wait_time = lerp(spawn_start_interval, spawn_end_interval, t)
	   
func _input(event: InputEvent) -> void:
	if game_active and Input.is_action_just_pressed("ui_cancel"):  # ESC
		toggle_pause()

func _process(delta: float) -> void:
	if game_active:
		# Update UI
		score_label.text = "Score: %d" % $Player.player_score
		time_label.text = "Time: %d:%02d" % [int(timer.time_left / 60), int(timer.time_left) % 60]
		if game_active:
			elapsed += delta
		# TODO: add_score(10) при hit на mob
	
func toggle_pause() -> void:
	if get_tree().paused:
		get_tree().paused = false
		pause_ui.visible = false
	else:
		get_tree().paused = true
		pause_ui.visible = true

func game_over() -> void:
	game_active = false
	get_tree().paused = true
	game_over_ui.visible = true
	game_over_score_label.text = "Final Score: %d" % $Player.player_score
	# Също ако health <= 0: game_over()

func take_damage(amount: int) -> void:
	current_health -= amount
	health_bar.value = current_health
	if current_health <= 0:
		game_over()

# Button functions
func _on_continue_button_pressed() -> void:
	toggle_pause()


func _on_quit_button_pressed() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file("res://src/ui/main_menu.tscn")


func _on_clock_timeout() -> void:
	game_over()


func _on_pause_retry_button_pressed() -> void:
	get_tree().paused = false
	get_tree().reload_current_scene()


func _on_quit_retry_button_pressed() -> void:
	get_tree().paused = false
	get_tree().reload_current_scene()
