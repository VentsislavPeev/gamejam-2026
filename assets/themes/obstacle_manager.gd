extends Node2D

@export var segment_scene: PackedScene
@export var player: Node2D

# CHANGED: Use Vector2 to match your exact Parallax2D Repeat Size
var segment_size = Vector2(10080, 6720.0)

var active_segments = {} 

func _ready():
	update_segments(Vector2.ZERO)
	
	if not player:
		var found_nodes = get_tree().get_nodes_in_group("player")
		if found_nodes.size() > 0:
			player = found_nodes[0]
		else:
			return # Still no player found, stop here
	
	# CHANGED: Calculate grid coordinates using X and Y separately
	var p_x = floor(player.global_position.x / segment_size.x)
	var p_y = floor(player.global_position.y / segment_size.y)
	var current_grid_pos = Vector2(p_x, p_y)
	
	update_segments(current_grid_pos)

func update_segments(center: Vector2):
	# We look at the 3x3 grid surrounding the center
	var needed_coords = []
	for x in range(center.x - 10, center.x + 10):
		for y in range(center.y - 10, center.y + 10):
			needed_coords.append(Vector2(x, y))

	# 1. Cleanup old segments
	var coords_to_remove = []
	for coord in active_segments.keys():
		if coord not in needed_coords:
			coords_to_remove.append(coord)
	
	for coord in coords_to_remove:
		active_segments[coord].queue_free()
		active_segments.erase(coord)
	
	# 2. Spawn new segments
	for coord in needed_coords:
		print('spawned at new coords',coord)
		if not active_segments.has(coord):
			spawn_segment(coord)

func spawn_segment(coord: Vector2):
	var new_seg = segment_scene.instantiate()
	add_child(new_seg)
	
	# CHANGED: Multiply Vector2 by Vector2 for accurate positioning
	# (coord.x * 10080, coord.y * 6720)
	new_seg.global_position = coord * segment_size
	
	active_segments[coord] = new_seg
