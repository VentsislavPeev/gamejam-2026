extends CharacterBody2D

# --- SIGNALS ---
signal health_changed(new_health)

@onready var animated_sprite = $AnimatedSprite2D
@export var health = 100.0 # Make sure this is a float for delta math
@export var max_health = 100
@export var experience = 0
@onready var weapon_timer = $Weapon/Timer
# Use the onready var you already defined (don't re-declare it inside functions)
@onready var hp_bar = $Camera2D/HUD/TextureProgressBar 

@export var level = 1
@export var speed = 600
@export var damage = 1
@export var DMG_CAP = 5.0

var earth_mask = false
var fire_mask = true
var lightning_mask = false
const BASE_LEVEL_XP = 100

# --- DASH VARIABLES ---
@export var dash_speed = 1600 
@export var dash_duration = 0.2
@export var dash_cooldown = 1.0
var is_dashing = false
var can_dash = true
# ----------------------

func _ready():
	# Initialize the bar when the game starts
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

	if earth_mask:
		keep_max_health()

# --- NEW FUNCTION ---
func take_damage(amount: float):
	health -= amount
	
	health_changed.emit(health)
	
	if hp_bar:
		hp_bar.value = health
		
	if health <= 0.0:
		die()

func die():
	print("DIED")
	# Add your game over logic here (e.g., get_tree().reload_current_scene())

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
	if experience >= exp_to_level:
		level_up()

func level_up():
	print('LEVELED UP')
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

func on_item_pickup():
	$ItemDuration.start()

func _on_item_duration_timeout() -> void:
	pass
