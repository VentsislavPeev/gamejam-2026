extends TextureProgressBar

# Use %Player if you set "Access as Unique Name" on the Player node
# Otherwise, keep your get_node path if it works
@onready var player = get_node("/root/Game/Player")

func _ready():
	# 1. Initialize the bar immediately
	max_value = player.max_health
	value = player.health
	
	# 2. Connect the signal to a specific function
	# The signal emits (new_health), so our function must accept (new_health)
	player.health_changed.connect(_on_health_changed)

# This function matches the signal: health_changed(new_health)
func _on_health_changed(new_health):
	value = new_health
