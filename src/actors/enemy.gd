extends CharacterBody2D



var health = 3
var dot_active = false;
@onready var player = get_node("/root/Game/Player")
@onready var animated_sprite = $AnimatedSprite2D

@onready var enemy_kill = $AnimatedSprite2D/EnemyKill
@onready var burning_enemy = $AnimatedSprite2D/BurnEnemy

func _physics_process(delta: float):
	var direction = global_position.direction_to(player.global_position)
	if direction.x < 0:
		animated_sprite.flip_h = true;
	else: animated_sprite.flip_h = false;
	velocity = direction * 300
	move_and_slide()

func take_fire_dmg(duration: float = 3.0, tick: float = 1.0) -> void:
	if dot_active:
		return
	dot_active = true
	burning_enemy.play()
	print('Burnt')
	
	#arrow_fire
	animated_sprite.play('burning')

	var elapsed := 0.0
	while elapsed < duration and is_inside_tree():
		take_dmg()
		await get_tree().create_timer(tick).timeout
		elapsed += tick

	dot_active = false

func take_dmg(amount: int = 1):
	health -= amount
	
	if health == 0:
		#enemy_kill
		enemy_kill.play()
		animated_sprite.play('death')
		await animated_sprite.animation_finished
		queue_free()
