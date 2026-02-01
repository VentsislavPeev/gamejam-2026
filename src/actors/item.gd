extends Area2D

var item_type : int # 0:earth mask, 1:fire mask
					# 2: lightning mask, 3: buff tocken

var mask_earth = preload("res://assets/sprites/earth_mask_mini.png")
var mask_fire = preload("res://assets/sprites/fire_mask_mini.png")
var mask_lightning = preload("res://assets/sprites/lightning_mask_mini.png")
var textures = [mask_earth, mask_fire, mask_lightning]

@onready var mask_pickup_sound = %MaskPickUp

func _ready():
	$Sprite2D.texture = textures[item_type]
	
	start_floating()


func start_floating():
	# Create a tween and set it to loop infinitely
	var tween = create_tween().set_loops()
	# Move the sprite UP by 10 pixels over 1 second
	# Use 'relative' so it moves 10px from its current spot
	tween.tween_property($Sprite2D, "position:y", -10.0, 1.0).as_relative().set_trans(Tween.TRANS_SINE)
	mask_pickup_sound.play()
	# Move the sprite DOWN by 10 pixels over 1 second
	tween.tween_property($Sprite2D, "position:y", 10.0, 1.0).as_relative().set_trans(Tween.TRANS_SINE)


func _on_body_entered(body):
	if item_type == 0 && body.has_method("on_item_pickup"):
		
		
		body.on_item_pickup(0)
		
	elif item_type == 1 && body.has_method("on_item_pickup"):
		body.on_item_pickup(1)
		
		mask_pickup_sound.play()
	elif item_type == 2 && body.has_method("on_item_pickup"):
		
		mask_pickup_sound.play()
		body.on_item_pickup(2)
	
	queue_free()
