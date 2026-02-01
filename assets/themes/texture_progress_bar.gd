extends TextureProgressBar

# Use %Player if you set "Access as Unique Name" on the Player node
# Otherwise, keep your get_node path if it works
@onready var player = get_node("/root/Game/Player")
@onready var level_label = $LevelText # Reference the node properly
var level = 1
var new_level_exp = 0
var last_level_exp = 0


func _ready():
	# 1. Initialize the bar immediately
	level = player.level
	value = player.experience
	max_value = player.calculate_experience_to_level(level)
	
	update_level_display()
	
	# 2. Connect the signal to a specific function
	# The signal emits (new_health), so our function must accept (new_health)
	player.exp_changed.connect(_on_exp_change)

# This function matches the signal: health_changed(new_health)

func _on_exp_change(new_exp):
	if level != player.level:
		last_level_exp = player.calculate_experience_to_level(level)
		max_value = new_level_exp
		level = player.level
		update_level_display()
		new_level_exp = player.calculate_experience_to_level(level) - last_level_exp
	max_value = player.calculate_experience_to_level(level) - last_level_exp
	value = new_exp - last_level_exp
	
func update_level_display():
	level_label.text = "[font_size=36]LVL"+str(level)+"[/font_size]"
