extends CharacterBody2D

var health = 3
var dot_active = false;
var item_scene := preload("res://src/actors/item.tscn")
@onready var player = get_node("/root/Game/Player")
@onready var main_scene = get_node("/root/Game")
@onready var animated_sprite = $AnimatedSprite2D

@onready var enemy_kill = $AnimatedSprite2D/EnemyKill
@onready var burning_enemy = $AnimatedSprite2D/BurnEnemy
const DROP_CHANCE: float = 0.5
const DROP_EXP: int = 25
var drop_items = 0
var direction = 0
@export var speed = 100
var knockback_vector = Vector2.ZERO

func _physics_process(delta: float):
	# 1. Calculate your normal movement (e.g., chasing player)
	var direction_to_player = global_position.direction_to(player.global_position)
	var normal_velocity = direction_to_player * speed
	
	# 2. Add the Knockback Vector to your movement
	velocity = normal_velocity + knockback_vector
	
	move_and_slide()
	
	# 3. Smoothly reduce knockback to zero (Friction)
	# The '200' here is the friction strength. Higher = stops faster.
	if knockback_vector != Vector2.ZERO:
		knockback_vector = knockback_vector.move_toward(Vector2.ZERO, 500 * delta)

func take_fire_dmg(duration: float = 3.0, tick: float = 1.0) -> void:
	if dot_active:
		return
	dot_active = true
	burning_enemy.play()
	
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
	player.gain_experience(DROP_EXP)
	enemy_kill.play()
	animated_sprite.play('death')
	await animated_sprite.animation_finished
	queue_free()
	if randf() <= DROP_CHANCE and drop_items < 1:
		drop_item()
		drop_items += 1
		
func drop_item():
	var item = item_scene.instantiate()
	item.position = position
	item.item_type = randi_range(0,2)
	main_scene.add_child(item)
	item.add_to_group("items")
	
