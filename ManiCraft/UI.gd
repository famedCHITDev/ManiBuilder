extends Control

@export var hotbar : Node2D
@export var pauseMenu : Node2D
@export var inventory : Node2D
# Called when the node enters the scene tree for the first time.
func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS
	hotbar = $HUD/SelectTool
	pauseMenu = $HUD/PauseMenu
	inventory = $HUD/Inventory
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	#Pausing
	if Input.is_action_just_released("exit") and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	elif Input.is_action_just_released("exit") and Input.get_mouse_mode() == Input.MOUSE_MODE_VISIBLE:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	if Input.is_action_just_pressed("exit"):
		if pauseMenu.visible:
			pauseMenu.visible = false
			get_tree().paused = false
		else:
			pauseMenu.visible = true
			get_tree().paused = true
	
	# Go through hotbar
	for i in range(1,10):
		if Input.is_action_just_pressed(str(i)):
			hotbar.position.x = 271 + 67 * (i-1)
	
	# inventory TODO add a smarter cursor
	if Input.is_action_just_pressed("inventory") and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		inventory.visible = true
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	elif Input.is_action_just_pressed("inventory") and Input.get_mouse_mode() == Input.MOUSE_MODE_VISIBLE:
		inventory.visible = false
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		
