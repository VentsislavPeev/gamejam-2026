extends Control

# Reference to the Timer node
@onready var clock = get_node("/root/Game/Clock")
# Reference to the RichTextLabel child
@onready var label = $RichTextLabel
@onready var player = get_node("/root/Game/Player")
@onready var weapon = get_node("/root/Game/Player/Weapon")

func _ready():
	player.dashed.connect(_update_dash_cooldown)
	weapon.triple_shot_signal.connect(_update_triple_shot_cooldown)

func _process(_delta):
	# 1. Get the time remaining on the timer
	var time_left = clock.time_left
	
	# 2. Calculate minutes and seconds
	var seconds = str(int(time_left)) 
	
	# 3. Update the text using String Formatting
	# "%02d" means "Format as a digit, at least 2 characters wide, padding with zero"
	label.text = "[font_size=72]"+seconds+"[/font_size]"
	
func _update_dash_cooldown(seconds):
	# Fix 1: Use '/' to access children, not '$' twice
	var bar = $Dash/ProgressBar 
	
	bar.max_value = 1

	if seconds > 0:
		bar.visible = true
		bar.value = seconds
	else:
		bar.visible = false
		bar.value = 0


func _update_triple_shot_cooldown(seconds):
	# Fix 1: Use '/' to access children, not '$' twice
	var bar = $TripleShot/ProgressBar 
	
	bar.max_value = 2

	if seconds > 0:
		bar.visible = true
		bar.value = seconds
	else:
		bar.visible = false
		bar.value = 0
