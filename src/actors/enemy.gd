extends CharacterBody2D

@export var max_health := 3
@export var move_speed := 300.0
@export var drop_chance := 0.5
@export var drop_exp := 25
@export var drop_score := 20

var drop_items = 0
var health: int
var dot_active = false;
var item_scene := preload("res://src/actors/item.tscn")
var knockback_vector = Vector2.ZERO

@onready var player = get_node("/root/Game/Player")
@onready var main_scene = get_node("/root/Game")
@onready var animated_sprite = $AnimatedSprite2D
@onready var enemy_kill = $AnimatedSprite2D/EnemyKill
@onready var burning_enemy = $AnimatedSprite2D/BurnEnemy


func _ready():
	health = max_health
	
func _physics_process(delta: float):
	# 1. Calculate direction once
	var direction_to_player = global_position.direction_to(player.global_position)
	
	# 2. Handle sprite flipping
	animated_sprite.flip_h = direction_to_player.x < 0
	
	# 3. Combine normal movement AND knockback
	var normal_velocity = direction_to_player * move_speed
	velocity = normal_velocity + knockback_vector
	
	# 4. Move
	move_and_slide()
	
	# 5. Decay knockback over time
	if knockback_vector != Vector2.ZERO:
		knockback_vector = knockback_vector.move_toward(Vector2.ZERO, 500 * delta)
func take_fire_dmg(duration: float = 3.0, tick: float = 1.0) -> void:
	if dot_active:
		return
	dot_active = true
	animated_sprite.play('burning')
	burning_enemy.play()
	
	#arrow_fire

	var elapsed := 0.0
	while elapsed < duration and is_inside_tree():
		take_dmg() #changeble
		await get_tree().create_timer(tick).timeout
		elapsed += tick
	dot_active = false
	animated_sprite.play("default")

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
	player.gain_score(drop_score)
	enemy_kill.play()
	animated_sprite.play('death')
	await animated_sprite.animation_finished
	if randf() <= drop_chance and drop_items < 1:
		drop_item()
		drop_items += 1
	queue_free()


func drop_item():
	var item = item_scene.instantiate()
	item.position = position
	item.item_type = randi_range(0,2)
	main_scene.add_child(item)
	item.add_to_group("items")
	
