extends Control

var item_type : int # 0:earth mask, 1:fire mask 2: lightning mask,
var mask_earth = preload("res://assets/sprites/earth_mask.png")
var mask_fire = preload("res://assets/sprites/fire_mask.png")
var mask_lightning = preload("res://assets/sprites/lightning_mask.png")
var textures = [mask_earth, mask_fire, mask_lightning]
var empty = preload("res://assets/sprites/empty.png")

@onready var player = get_node("/root/Game/Player")
@onready var t1 = $t1
@onready var t2 = $t2


func _ready():
	player.mask_changed.connect(_on_mask_change)

func _on_mask_change(mask_stack):
	if mask_stack[0] != -1:
		t1.texture = textures[mask_stack[0]]
		#$ti1.start()
	else:
		t1.texture = null
	
	if mask_stack[1] != -1:
		t2.texture = textures[mask_stack[1]]
		#$ti2.start()
	else:
		t2.texture = null
	
	

#
#func _on_ti_1_timeout() -> void:
	#t1.texture = null
#
#
#func _on_ti_2_timeout() -> void:
	#t2.texture = null
