extends CharacterBody2D

# --- SIGNALS ---
signal health_changed(new_health)
signal mask_changed(masks)
signal exp_changed(exp)
signal dashed(dash)

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
@export var DMG_CAP = 30
const BASE_LEVEL_XP = 100

# --- DASH VARIABLES ---
@export var dash_speed = 1600 
@export var dash_duration = 0.2
@export var dash_cooldown = 1.0

var hurt_cooldown = 0.4
var hurt_duration = 0.6
var can_hurt_animation = true
var is_dead = false
var is_dashing = false
var can_dash = true

# ----------------------

var mask_stack: Array = []
var player_score = 0

func _ready():
	mask_stack.append(-1)
	mask_stack.append(-1)
	hp_bar.max_value = max_health
	hp_bar.value = health
	animated_sprite.sprite_frames.set_animation_loop("shoot", true)


func _physics_process(delta: float):
	if(is_dead):
		return
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
	if is_dead:
		return
	if can_hurt_animation:
		animated_sprite.play('hurt')
		await animated_sprite.animation_finished
		animated_sprite.play('shoot')
		can_hurt_animation = false
		can_hurt_animation = true


func die():
	is_dead = true
	animated_sprite.play('die')
	await animated_sprite.animation_finished # <--- And this
	game.game_over()
	queue_free()

func perform_dash(dash_direction: Vector2):
	dashed.emit(dash_cooldown)
	$HurtBox/CollisionShape2D.disabled = true;
	animated_sprite.play('dash')
	is_dashing = true
	can_dash = false
	
	velocity = dash_direction.normalized() * dash_speed
	
	await get_tree().create_timer(dash_duration).timeout
	animated_sprite.play('shoot')
	is_dashing = false
	$HurtBox/CollisionShape2D.disabled = false;
	await get_tree().create_timer(dash_cooldown).timeout
	can_dash = true
	dashed.emit(-1)

func calculate_experience_to_level(level: int) -> float:
	return (level - 0.5) ** 2 * BASE_LEVEL_XP


func gain_experience(exp: int) -> void:
	var exp_to_level = calculate_experience_to_level(level)
	experience += exp
	exp_changed.emit(experience)
	if experience >= exp_to_level:
		level_up()

func gain_score(score: int):
	player_score += score

func level_up():
	lvlup_animation.play('default')
	level += 1
	max_health += 3
	
	# Update the bar's max value immediately upon leveling up
	if hp_bar:
		hp_bar.max_value = max_health
		
	damage += 0.5
	speed += 20
	weapon_timer.wait_time -= 0.5
	print(weapon_timer.wait_time)
	
func keep_max_health():
	if health > max_health:
		health = max_health
		# Sync the UI if health was clamped
		if hp_bar: hp_bar.value = health

func on_item_pickup(value: int):
	if mask_stack[0] != -1 and mask_stack[1] != -1:
		if($ItemDuration.wait_time >= $ItemDuration2.wait_time):
			print("mask 1 ", value)
			mask_stack[1] = value
			$ItemDuration2.start()
		else:
			print("mask 0 ", value)
			mask_stack[0] = value
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


func _on_item_duration_2_timeout() -> void:
	mask_stack[1] = -1
	mask_changed.emit(mask_stack)
