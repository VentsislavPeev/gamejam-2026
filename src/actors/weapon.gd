extends Area2D

@onready var shooting = $CharShoot

const PROJECTILE = preload("res://src/actors/projectile.tscn")

func _physics_process(delta: float):
	look_at(get_global_mouse_position())
	
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		# We check if the timer is stopped to act as a "Fire Rate" cooldown
		# If you don't use a timer for cooldown, change this to Input.is_action_just_pressed
		if $TripleShotTimer.is_stopped():
			shoot_spread()
			$TripleShotTimer.start() # Restart cooldown
	
func shoot():
	shooting.play()
	var new_projectile = PROJECTILE.instantiate()
	new_projectile.global_position = %ShootingPoint.global_position
	new_projectile.global_rotation = %ShootingPoint.global_rotation
	%ShootingPoint.add_child(new_projectile)

func shoot_spread():
	shooting.play()
	
	# The angles for the 3 shots (Left, Center, Right)
	var angles_deg = [-15, 0, 15]
		
	for angle in angles_deg:
		var new_projectile = PROJECTILE.instantiate()
		
		# 1. Set Start Position
		new_projectile.global_position = %ShootingPoint.global_position
		
		# 2. Set Rotation (Base rotation + Offset converted to radians)
		new_projectile.global_rotation = %ShootingPoint.global_rotation + deg_to_rad(angle)
		
		# 3. CRITICAL FIX: Add to the game world, NOT the gun
		# This prevents bullets from spinning when you turn your character
		get_tree().current_scene.add_child(new_projectile)

func _on_timer_timeout():
	shoot()
