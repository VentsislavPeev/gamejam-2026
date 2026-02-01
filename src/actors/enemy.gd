extends CharacterBody2D

@export var max_health := 3
@export var move_speed := 300.0
@export var drop_chance := 0.5
@export var drop_exp := 25

var drop_items = 0
var health: int
var dot_active = false;
var item_scene := preload("res://src/actors/item.tscn")
var knockback_vector = Vector2.ZERO

@onready var player = get_node("/root/Game/Player")
@onready var main_scene = get_node("/root/Game")
@onready var animated_sprite = $AnimatedSprite2D

@onready var arrow_hit_sound = $AnimatedSprite2D/ArrowNormalHit
@onready var enemy_kill_sound = $AnimatedSprite2D/EnemyKill
@onready var burning_enemy_sound = $AnimatedSprite2D/BurnEnemy
const DROP_CHANCE: float = 0.1


func _ready():
	health = max_health
	
func _physics_process(delta: float):
	
	var direction_to_player = global_position.direction_to(player.global_position)
	var normal_velocity = direction_to_player * move_speed
	velocity = normal_velocity + knockback_vector
	
	var direction = global_position.direction_to(player.global_position)
	if direction.x < 0:
		animated_sprite.flip_h = true;
	else: animated_sprite.flip_h = false;
	velocity = direction * move_speed
	move_and_slide()
	
	if knockback_vector != Vector2.ZERO:
		knockback_vector = knockback_vector.move_toward(Vector2.ZERO, 500 * delta)

func take_fire_dmg(duration: float = 3.0, tick: float = 1.0) -> void:
	if dot_active:
		return
	dot_active = true
	arrow_hit_sound.play()
	burning_enemy_sound.play()
	await get_tree().create_timer(0.1).timeout
	print('Burnt')
	
	#arrow_fire
	animated_sprite.play('burning')

	var elapsed := 0.0
	while elapsed < duration and is_inside_tree():
		take_dmg()
		await get_tree().create_timer(tick).timeout
		elapsed += tick
	dot_active = false

func get_knocked_back(power):
	var direction = global_position.direction_to(player.global_position)
	
	# Assign to our special variable, NOT the main velocity
	# We use negative direction to push AWAY from player
	knockback_vector = -direction * 300 * power

func take_dmg(amount: int = 1):
	health -= amount
	if health <= 0:
		die()

func die():
	#enemy_kill
	player.gain_experience(drop_exp)
	enemy_kill_sound.play()
	await get_tree().create_timer(0.1).timeout
	animated_sprite.play('death')
	await animated_sprite.animation_finished
	queue_free()
	if randf() <= drop_chance and drop_items < 1:
		drop_item()
		drop_items += 1
		
func drop_item():
	var item = item_scene.instantiate()
	item.position = position
	item.item_type = randi_range(0,2)
	main_scene.add_child(item)
	item.add_to_group("items")
	
