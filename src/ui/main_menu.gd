extends Control

@onready var ambience_loop = $AudioStreamPlayer
@onready var start_button: Button = $StartButton

func _ready() -> void:
	ambience_loop.play()
	start_button.pressed.connect(_on_start_pressed)

func _on_start_pressed() -> void:
	ambience_loop.stop()
	get_tree().change_scene_to_file("res://src/levels/survivor_game.tscn")
