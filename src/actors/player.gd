extends CharacterBody2D

@onready var animated_sprite = $AnimatedSprite2D
var health = 100

var earth_mask = true;
var fire_mask = false;
var lightning_mask = false;

func _physics_process(delta: float):
	var direction = Input.get_vector("move_left","move_right","move_up","move_down")
	if direction.x < 0:
		animated_sprite.flip_h = true;
	else: animated_sprite.flip_h = false;
	velocity = direction * 600
	move_and_slide()
	
	const DMG_RATE = 5.0
	var overlapping_mobs = %HurtBox.get_overlapping_bodies()
	if overlapping_mobs.size() > 0:
		health -= DMG_RATE*overlapping_mobs.size()*delta
		if health <= 0.0:
			print("DIED")
	
	if earth_mask:
		keep_max_health()

func keep_max_health():
	if health > 100:
		health = 100
		
func on_item_pickup():
	$ItemDuration.start()
	# make the buffs, change speed, make speed constant in the
	# player script for easier change, add defense, etc
	
func _on_item_duration_timeout() -> void:
	pass # remove buffs
