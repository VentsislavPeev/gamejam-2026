extends CanvasLayer
class_name GameUI

signal score_changed(new_score: int)
signal health_changed(new_health: int)
signal time_changed(time_left: float)

@onready var score_label = $ScoreLabel
@onready var health_bar = $HealthBar
@onready var time_label = $TimeLabel
@onready var pause_ui = $PauseUI
@onready var game_over_ui = $GameOverUI

func update_score(score: int):
	score_label.text = "Score: %d" % score
	score_changed.emit(score)

func update_health(health: int):
	health_bar.value = health

func update_time(time_left: float):
	time_label.text = "Time: %d:%02d" % [int(time_left/60), int(time_left)%60]

func show_pause(show: bool):
	pause_ui.visible = show
	get_tree().paused = show

func show_game_over(score: int):
	game_over_ui.visible = true
	$GameOverUI/ScoreLabel.text = "Final Score: %d" % score
	get_tree().paused = true
