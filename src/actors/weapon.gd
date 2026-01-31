extends Area2D

@onready var shooting = $CharShoot

func _physics_process(delta: float):
	look_at(get_global_mouse_position())
	
func shoot():
	shooting.play()
	const PROJECTILE = preload("res://src/actors/projectile.tscn")
	var new_projectile = PROJECTILE.instantiate()
	new_projectile.global_position = %ShootingPoint.global_position
	new_projectile.global_rotation = %ShootingPoint.global_rotation
	%ShootingPoint.add_child(new_projectile)


func _on_timer_timeout():
	shoot()
