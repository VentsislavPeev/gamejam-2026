extends CharacterBody2D

var health = 100

var earth_mask = false;
var fire_mask = true;
var lightning_mask = false;

func _physics_process(delta: float):
	var direction = Input.get_vector("move_left","move_right","move_up","move_down")
	velocity = direction * 600
	move_and_slide()
	
	const DMG_RATE = 5.0
	var overlapping_mobs = %HurtBox.get_overlapping_bodies()
	if overlapping_mobs.size() > 0:
		health -= DMG_RATE*overlapping_mobs.size()*delta
		print('Damage taken')
		if health <= 0.0:
			print("DIED")
	
	if earth_mask:
		keep_max_health()

func keep_max_health():
	if health > 100:
		health = 100
		
