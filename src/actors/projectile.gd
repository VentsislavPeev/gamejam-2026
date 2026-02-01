extends Area2D

@onready var player = get_node("/root/Game/Player")
@onready var sprite = $AnimatedSprite2D
@onready var projectile = $"."

var travel_distance = 0
var count_hit = 0;

func _physics_process(delta: float):
	if(player.mask_stack.has(0) && player.mask_stack.has(1)):
		sprite.play("earth_fire_arrow")
	elif(player.mask_stack.has(0)):
		sprite.play("earth_arrow")
	elif(player.mask_stack.has(1)):
		sprite.play("fire_arrow")
	else: sprite.play("normal_arrow")
	
	const SPEED = 1200
	const RANGE = 1200
	
	var direction = Vector2.RIGHT.rotated(rotation)
	position += direction * SPEED * delta
	travel_distance += SPEED * delta
	if travel_distance > RANGE:
		queue_free()

func _on_body_entered(body: Node2D) -> void:
	if !body.has_method("take_dmg"):
		return
	body.take_dmg()

	if player.mask_stack.has(1):
		body.take_fire_dmg()
		
	if player.mask_stack.has(0):
		sprite.scale *= 0.7
		count_hit += 1
		if count_hit == 3:
			queue_free()
	else: queue_free()
