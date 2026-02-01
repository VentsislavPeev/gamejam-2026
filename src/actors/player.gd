extends CharacterBody2D

@onready var animated_sprite = $AnimatedSprite2D
var health = 100

var mask_stack: Array = []
var earth_mask = true;
var fire_mask = false;
var lightning_mask = false;

func _ready():
	mask_stack.append(-1)
	mask_stack.append(-1)

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

func on_item_pickup(value: int):
	if mask_stack[0] != -1:
		mask_stack[1] = value
		$ItemDuration2.start()
	
	elif mask_stack[1] != -1:
		mask_stack[0] = value
		$ItemDuration.start()
		
	elif mask_stack[0] != -1 and mask_stack[1] != -1:
		if(mask_stack[0].value.wait_time >= mask_stack[1].value.wait_time):
			mask_stack[1] = value
			$ItemDuration2.start()
		else: 
			mask_stack[0] = value
			$ItemDuration.start()
		
	else:
		mask_stack[0] = value
		$ItemDuration.start()
		
		
	# make the buffs, change speed, make speed constant in the
	# player script for easier change, add defense, etc


func _on_timer_timeout() -> void:
	mask_stack[0] = -1
	print("POPPED")


func _on_item_duration_2_timeout() -> void:
	mask_stack[1] = -1
