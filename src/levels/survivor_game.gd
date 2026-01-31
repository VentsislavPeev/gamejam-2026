extends Node2D

var score: int = 0
var max_health: int = 100
var current_health: int = 100
var game_active: bool = true

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

func spawn_mob():
	var new_mob = preload("res://src/actors/enemy.tscn").instantiate()
	%PathFollow2D.progress_ratio = randf()
	new_mob.global_position = %PathFollow2D.global_position
	add_child(new_mob)

func _on_timer_timeout():
	spawn_mob()
	
	
func _input(event: InputEvent) -> void:
	if game_active and Input.is_action_just_pressed("ui_cancel"):  # ESC
		toggle_pause()

func _process(delta: float) -> void:
	if game_active:
		# Update UI
		score_label.text = "Score: %d" % score
		time_label.text = "Time: %d:%02d" % [int(timer.time_left / 60), int(timer.time_left) % 60]
		
		# TODO: add_score(10) при hit на mob
		# TODO: take_damage(20) при hit

func toggle_pause() -> void:
	get_tree().paused = !get_tree().paused
	pause_ui.visible = get_tree().paused

func game_over() -> void:
	game_active = false
	get_tree().paused = true
	game_over_ui.visible = true
	game_over_score_label.text = "Final Score: %d" % score
	# Също ако health <= 0: game_over()

func take_damage(amount: int) -> void:
	current_health -= amount
	health_bar.value = current_health
	if current_health <= 0:
		game_over()

func add_score(points: int) -> void:
	score += points

# Button functions
func _on_continue_button_pressed() -> void:
	toggle_pause()


func _on_retry_button_pressed() -> void:
	get_tree().reload_current_scene()


func _on_quit_button_pressed() -> void:
	get_tree().change_scene_to_file("res://src/ui/main_menu.tscn")


func _on_clock_timeout() -> void:
	game_over()
