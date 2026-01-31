extends CharacterBody2D

var health = 3
var dot_active = false;
@onready var player = get_node("/root/Game/Player")

func _physics_process(delta: float):
	var direction = global_position.direction_to(player.global_position)
	velocity = direction * 300
	move_and_slide()

func take_fire_dmg(duration: float = 3.0, tick: float = 1.0) -> void:
	if dot_active:
		return
	dot_active = true
	print('Burnt')
#activate animation here.

	var elapsed := 0.0
	while elapsed < duration and is_inside_tree():
		take_dmg()
		await get_tree().create_timer(tick).timeout
		elapsed += tick

	dot_active = false

func take_dmg():
	health -= 1
	
	if health == 0:
		queue_free()
