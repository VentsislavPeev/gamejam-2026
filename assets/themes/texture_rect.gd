extends TextureRect

var item_type : int # 0:earth mask, 1:fire mask 2: lightning mask,
var mask_earth = preload("res://assets/sprites/earth_mask.png")
var mask_fire = preload("res://assets/sprites/fire_mask.png")
var mask_lightning = preload("res://assets/sprites/lightning_mask.png")
var textures = [mask_earth, mask_fire, mask_lightning]

@onready var player = get_node("/root/Game/Player")

func _ready():
	$Sprite2D.texture = textures[item_type]
	player.mask_changes.connect(_on_mask_change)

func _on_mask_change(masks):
	
	
