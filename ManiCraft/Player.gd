extends CharacterBody3D

# physics
var moveSpeed : float = 5.0
var sprintSpeed : float = 9.0
var jumpForce : float = 5.0
var gravity : float = 12.0
@export var runSpeed = moveSpeed

# Voxel tools node variables
var _terrain : VoxelTerrain
var vox : VoxelTool = null

# Player Inventory/Hotbar Variables
var hotbar = 1
var inventory = []

# cam Variables
var minLookAngle : float = -90.0
var maxLookAngle : float = 90.0
@export var lookSensitivity : float = 20.0
var camActive : int = 0 # 0 : FPS, 1 : TPSF, 2 : TPSB

# vectors
var vel : Vector3 = Vector3()
var mouseDelta : Vector2 = Vector2()

# camera node variables
var rotation_node
var camera3D
var camFront
var camBack

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	rotation_node = $TPSRotate
	camera3D = $FPS
	camFront = $TPSRotate/TPSF
	camBack = $TPSRotate/TPSB

	camera3D.make_current()
	
	for i in range(4):
		inventory.append([])
		for j in range(9):
			inventory[i].append(-1)
	
	_terrain = get_node("/root/World/VoxelTerrain")
	vox = _terrain.get_voxel_tool()
	vox.channel = VoxelBuffer.CHANNEL_TYPE

func _get_pointed_voxel() -> VoxelRaycastResult:
	var origin = camera3D.get_global_transform().origin
	var forward = -camera3D.get_global_transform().basis.z.normalized()
	var hit = vox.raycast(origin, forward, 5.25)
	return hit

func _can_place(pos : Vector3):
	# TODO Separate the player to its own Layer
	var space_state := get_viewport().get_world_3d().get_direct_space_state()
	var params := PhysicsShapeQueryParameters3D.new()
	#params.collision_mask =
	params.transform = Transform3D(Basis(), pos + Vector3(1,1,1)*0.5)
	var shape := BoxShape3D.new()
	shape.size = Vector3(1, 1, 1)
	params.set_shape(shape)
	var hits := space_state.intersect_shape(params)
	return hits.size() == 0

func _physics_process(delta):
	# Gravity
	if not is_on_floor():
		velocity.y -= gravity * delta
	# jumping
	if Input.is_action_pressed("jump") and is_on_floor():
		velocity.y = jumpForce
	
	# Sprint Check
	if Input.is_action_pressed("sprint") and is_on_floor():
		runSpeed = sprintSpeed
	elif Input.is_action_pressed("crouch") and is_on_floor():
		runSpeed = moveSpeed * 0.3
	elif is_on_floor():
		runSpeed = moveSpeed
	
	# Crouching Check TODO add hitbox shrink
	if Input.is_action_pressed("crouch"):
		camera3D.set_position(Vector3(camera3D.position.x, 1.37, camera3D.position.z))
		rotation_node.set_position(Vector3(rotation_node.position.x, 1.37, rotation_node.position.z))
	if Input.is_action_just_released("crouch"):
		camera3D.set_position(Vector3(camera3D.position.x, 1.67, camera3D.position.z))
		rotation_node.set_position(Vector3(rotation_node.position.x, 1.67, rotation_node.position.z))
	
	# Movement
	var input_dir = Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * runSpeed
		velocity.z = direction.z * runSpeed
	else:
		velocity.x = move_toward(velocity.x, 0, runSpeed)
		velocity.z = move_toward(velocity.z, 0, runSpeed)
	move_and_slide()

func _process(delta):
	# Toggle TPS
	if Input.is_action_just_pressed("toggleTPS") and camActive == 0:
		camFront.make_current()
		camActive = 1
	elif Input.is_action_just_pressed("toggleTPS") and camActive == 1:
		camBack.make_current()
		camActive = 2
	elif Input.is_action_just_pressed("toggleTPS") and camActive == 2:
		camera3D.make_current()
		camActive = 0
	
	# delete later, just for debug
	for i in range(1,10):
		inventory[3][i-1] = i
	
	# detect input
	for i in range(1,10):
		if Input.is_action_just_pressed(str(i)):
			hotbar = inventory[3][i-1]
	
	# Break / Place voxels
	var voxCast = _get_pointed_voxel()
	if voxCast != null and Input.is_action_just_pressed("left_click"):
		vox.set_voxel(voxCast.position, 0)
	if voxCast != null and Input.is_action_just_pressed("right_click"):
		if _can_place(voxCast.previous_position) and hotbar != -1:
			vox.set_voxel(voxCast.previous_position, hotbar)
	
	#Camera stuff
	# rotate the camera along the x axis
	camera3D.rotation_degrees.x -= mouseDelta.y * lookSensitivity * delta
	# clamp camera x rotation axis
	camera3D.rotation_degrees.x = clamp(camera3D.rotation_degrees.x, minLookAngle, maxLookAngle)
	# rotate the player along their y-axis
	rotation_degrees.y -= mouseDelta.x * lookSensitivity * delta
		# Rotate the third person cameras
	rotation_node.set_global_rotation(camera3D.get_global_rotation())
		# reset the mouseDelta vector
	mouseDelta = Vector2()
	
func _input(event):
	if event is InputEventMouseMotion:
		mouseDelta = event.relative
