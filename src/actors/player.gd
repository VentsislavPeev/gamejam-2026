extends CharacterBody2D

@onready var animated_sprite = $AnimatedSprite2D
@export var health = 100
@export var max_health = 10
@export var experience = 0
@export var level = 1
@export var speed = 600
@export var damage = 1
@export var DMG_CAP = 5.0
@onready var weapon_timer = $Weapon/Timer

var earth_mask = false;
var fire_mask = true;
var lightning_mask = false;
const BASE_LEVEL_XP = 100

func _physics_process(delta: float):
	var direction = Input.get_vector("move_left","move_right","move_up","move_down")
	if direction.x < 0:
		animated_sprite.flip_h = true;
	else: animated_sprite.flip_h = false;
	velocity = direction * speed
	move_and_slide()
	
	var overlapping_mobs = %HurtBox.get_overlapping_bodies()
	if overlapping_mobs.size() > 0:
		health -= DMG_CAP*overlapping_mobs.size()*delta
		if health <= 0.0:
			print("DIED")
	
	if earth_mask:
		keep_max_health()

func calculate_experience_to_level(level: int) -> float:
	return (level - 0.5) ** 2 * BASE_LEVEL_XP
	
func gain_experience(exp: int) -> void:
	var exp_to_level = calculate_experience_to_level(level)
	experience += exp
	print(experience)
	print(exp_to_level)
	if experience>=exp_to_level:
		level_up()

func level_up():
	print('LEVELED UP')
	level += 1
	max_health += 3
	damage += 0.2
	speed += 20
	weapon_timer.wait_time -= 0.05
	print(weapon_timer.wait_time)
	
func keep_max_health():
	if health > max_health:
		health = max_health
		
func on_item_pickup():
	$ItemDuration.start()
	# make the buffs, change speed, make speed constant in the
	# player script for easier change, add defense, etc
	
func _on_item_duration_timeout() -> void:
	pass # remove buffs
