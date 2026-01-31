extends Area2D

var item_type : int # 0:earth mask, 1:fire mask
					# 2: lightning mask, 3: buff tocken

var mask_earth = preload("res://assets/sprites/earth_mask.png")
var mask_fire = preload("res://assets/sprites/fire_mask.png")
var mask_lightning = preload("res://assets/sprites/lightning_mask.png")
var textures = [mask_earth, mask_fire, mask_lightning]

func _ready():
	$Sprite2D.texture = textures[item_type]
	
func _on_body_entered(body):
	if item_type == 0:
		body.on_item_pickup()
	elif item_type == 1:
		pass
	elif item_type == 2:
		pass
	
