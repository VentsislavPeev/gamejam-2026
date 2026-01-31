extends CharacterBody2D

var health = 3
var dot_active = false;
var item_scene := preload("res://src/actors/item.tscn")
@onready var player = get_node("/root/Game/Player")
@onready var main_scene = get_node("/root/Game")
@onready var animated_sprite = $AnimatedSprite2D

const DROP_CHANCE: float = 0.1

func _physics_process(delta: float):
	var direction = global_position.direction_to(player.global_position)
	if direction.x < 0:
		animated_sprite.flip_h = true;
	else: animated_sprite.flip_h = false;
	velocity = direction * 300
	move_and_slide()

func take_fire_dmg(duration: float = 3.0, tick: float = 1.0) -> void:
	if dot_active:
		return
	dot_active = true
	print('Burnt')
	
	animated_sprite.play('burning')

	var elapsed := 0.0
	while elapsed < duration and is_inside_tree():
		take_dmg()
		await get_tree().create_timer(tick).timeout
		elapsed += tick

	dot_active = false

func take_dmg(amount: int = 1):
	health -= amount
	die()

func die():
	if health == 0:
		animated_sprite.play('death')
		await animated_sprite.animation_finished
		queue_free()
		if randf() <= DROP_CHANCE:
			drop_item()
		
func drop_item():
	var item = item_scene.instantiate()
	item.position = position
	item.item_type = randi_range(0,2)
	main_scene.add_child(item)
	item.add_to_group("items")
	
