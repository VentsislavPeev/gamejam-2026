extends CharacterBody2D

# --- SIGNALS ---
signal health_changed(new_health)
signal mask_changed(masks)
signal exp_changed(exp)

@onready var game = get_node("/root/Game")
@onready var animated_sprite = $AnimatedSprite2D
@onready var lvlup_animation = $lvlup
@onready var weapon_timer = $Weapon/Timer
@onready var hp_bar = $Camera2D/HUD/TextureProgressBar 
@export var health = 100.0 # Make sure this is a float for delta math
@export var max_health = 100
@export var experience = 0

@export var level = 1
@export var speed = 600
@export var damage = 1
@export var DMG_CAP = 5.0
const BASE_LEVEL_XP = 100

# --- DASH VARIABLES ---
@export var dash_speed = 1600 
@export var dash_duration = 0.2

var hurt_cooldown = 0.4
var hurt_duration = 0.6
var can_hurt_animation = true
@export var dash_cooldown = 1.0
var is_dashing = false
var can_dash = true

# ----------------------

var mask_stack: Array = []
var score = 0

func _ready():
	mask_stack.append(-1)
	mask_stack.append(-1)
	hp_bar.max_value = max_health
	hp_bar.value = health

func _physics_process(delta: float):
	if is_dashing:
		move_and_slide()
		return

	# --- MOVEMENT ---
	var direction = Input.get_vector("move_left","move_right","move_up","move_down")

	if direction.x < 0:
		animated_sprite.flip_h = true
	else: 
		animated_sprite.flip_h = false
	
	velocity = direction * speed
	
	var keyDash = Input.is_action_just_pressed('dash')
	if keyDash and can_dash and direction != Vector2.ZERO:
		perform_dash(direction)
	
	move_and_slide()
	
	# --- DAMAGE LOGIC ---
	var overlapping_mobs = %HurtBox.get_overlapping_bodies()
	if overlapping_mobs.size() > 0:
		# Calculate the damage amount for this frame
		var damage_amount = DMG_CAP * overlapping_mobs.size() * delta
		take_damage(damage_amount)


# --- NEW FUNCTION ---
func take_damage(amount: float):
	health -= amount
	
	health_changed.emit(health)
	
	if hp_bar:
		hp_bar.value = health
		
	if health <= 0.0:
		die()
	
	if can_hurt_animation:
		animated_sprite.play('hurt')
		await get_tree().create_timer(hurt_duration).timeout
		animated_sprite.play('shoot')
		can_hurt_animation = false
		await get_tree().create_timer(hurt_cooldown).timeout
		can_hurt_animation = true


func die():
	animated_sprite.play('die')
	game.game_over()



func perform_dash(dash_direction: Vector2):
	animated_sprite.play('dash')
	is_dashing = true
	can_dash = false
	
	velocity = dash_direction.normalized() * dash_speed
	
	await get_tree().create_timer(dash_duration).timeout
	animated_sprite.play('shoot')
	is_dashing = false
	
	await get_tree().create_timer(dash_cooldown).timeout
	can_dash = true

func calculate_experience_to_level(level: int) -> float:
	return (level - 0.5) ** 2 * BASE_LEVEL_XP

func gain_experience(exp: int) -> void:
	var exp_to_level = calculate_experience_to_level(level)
	experience += exp
	exp_changed.emit(experience)
	if experience >= exp_to_level:
		level_up()

func level_up():
	print('LEVELED UP')
	lvlup_animation.play('default')
	level += 1
	max_health += 3
	
	# Update the bar's max value immediately upon leveling up
	if hp_bar:
		hp_bar.max_value = max_health
		
	damage += 0.2
	speed += 20
	weapon_timer.wait_time -= 0.05
	print(weapon_timer.wait_time)
	
func keep_max_health():
	if health > max_health:
		health = max_health
		# Sync the UI if health was clamped
		if hp_bar: hp_bar.value = health

func on_item_pickup(value: int):
	if mask_stack[0] != -1 and mask_stack[1] != -1:
		if($ItemDuration.wait_time >= $ItemDuration2.wait_time):
			mask_stack[0] = value
			$ItemDuration2.start()
		else: 
			mask_stack[1] = value
			$ItemDuration.start()
	elif mask_stack[0] != -1:
		mask_stack[1] = value
		$ItemDuration2.start()
	elif mask_stack[1] != -1:
		mask_stack[0] = value
		$ItemDuration.start()
	
	else:
		mask_stack[0] = value
		$ItemDuration.start()
		
	mask_changed.emit(mask_stack)
	# make the buffs, change speed, make speed constant in the
	# player script for easier change, add defense, etc


func _on_timer_timeout() -> void:
	mask_stack[0] = -1
	mask_changed.emit(mask_stack)
	print("POPPED")


func _on_item_duration_2_timeout() -> void:
	mask_stack[1] = -1
	mask_changed.emit(mask_stack)
