extends Area2D

@onready var player = $Game/Player
@onready var sprite = $AnimatedSprite2D

var travel_distance = 0

func _physics_process(delta: float):
	if(player.earth_mask):
		sprite.play("earth_arrow")
	elif(player.fire_mask):
		sprite.play("fire_arrow")
	else: sprite.play("normal_arrow")
	const SPEED = 1000
	const RANGE = 1200
	
	var direction = Vector2.RIGHT.rotated(rotation)
	position += direction * SPEED * delta
	
	travel_distance += SPEED * delta
	if travel_distance > RANGE:
		queue_free()




func _on_body_entered(body: Node2D) -> void:
	queue_free()
	if(player.earth_mask && body.has_method("take_dmg")):
		player.health += 1;
		print(player.health)
		body.take_dmg()

	elif (player.fire_mask && body.has_method("take_fire_dmg")):
		body.take_dmg()
		body.take_fire_dmg()
	elif body.has_method("take_dmg"):
		body.take_dmg()
