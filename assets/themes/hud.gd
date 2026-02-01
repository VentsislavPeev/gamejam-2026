extends Control

# Reference to the Timer node
@onready var clock = get_node("/root/Game/Clock")
# Reference to the RichTextLabel child
@onready var label = $RichTextLabel

func _process(_delta):
	# 1. Get the time remaining on the timer
	var time_left = clock.time_left
	
	# 2. Calculate minutes and seconds
	var seconds = str(int(time_left)) 
	
	# 3. Update the text using String Formatting
	# "%02d" means "Format as a digit, at least 2 characters wide, padding with zero"
	label.text = "[font_size=64]"+seconds+"[/font_size]"
