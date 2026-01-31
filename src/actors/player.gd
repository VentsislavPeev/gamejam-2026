extends CharacterBody2D

var health = 100

var earth_mask = true;
var fire_mask = false;
var lightning_mask = false;

func _physics_process(delta: float):
	var direction = Input.get_vector("move_left","move_right","move_up","move_down")
	velocity = direction * 600
	move_and_slide()
	
	#if earth_mask:
		#keep_max_health()

func keep_max_health():
	if health > 100:
		health = 100
