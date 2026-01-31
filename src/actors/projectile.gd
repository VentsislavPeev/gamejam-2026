extends Area2D

@onready var player = get_node("/root/Game/Player")
@onready var sprite = $AnimatedSprite2D
@onready var projectile = $"."

var travel_distance = 0
var count_hit = 0;

func _physics_process(delta: float):
	if(player.earth_mask):
		sprite.play("earth_arrow")
	elif(player.fire_mask):
		sprite.play("fire_arrow")
	elif(player.fire_mask && player.earth_mask):pass
	else: sprite.play("normal_arrow")
	
	const SPEED = 1000
	const RANGE = 1200
	
	var direction = Vector2.RIGHT.rotated(rotation)
	position += direction * SPEED * delta
	travel_distance += SPEED * delta
	if travel_distance > RANGE:
		queue_free()

#func earth_mask_effect():
	#sprite.play("earth_arrow")
#
#func fire_mask_effect():
	#sprite.play("fire_arrow")
#
#func fire_and_earth_mask():
	#sprite.play("normal_arrow")

func _on_body_entered(body: Node2D) -> void:
	if(player.earth_mask && body.has_method("take_dmg")):
		print(player.health)
		body.take_dmg()
		sprite.scale *= 0.7
		count_hit += 1
		if count_hit == 3:
			queue_free()
		
	elif (player.fire_mask && body.has_method("take_fire_dmg")):
		body.take_dmg()
		body.take_fire_dmg()
		queue_free()
	elif body.has_method("take_dmg"):
		body.take_dmg()
		queue_free()
