extends Node3D
# Body Variables
var head : Node3D
var torso : Node3D
var lArm : Node3D
var lLeg : Node3D
var rArm : Node3D
var rLeg : Node3D
var hitbox : CollisionShape3D

# Camera Variables
var FPS : Camera3D
var TPS : Node3D

# Player movement Variables
var armArc = 40.0
var legArc = 60.0
var walkSpeed = 3
var armCycle = 1
var legCycle = 1
var move
var angle
var moveCheck

func _ready():
	# init
	head = $UpperBodyHelper/HeadHelper
	torso = $UpperBodyHelper
	lArm = $UpperBodyHelper/LArmHelper
	lLeg = $LLegHelper
	rArm = $UpperBodyHelper/RArmHelper
	rLeg = $RLegHelper
	FPS = get_parent().get_node("FPS")
	TPS = get_parent().get_node("TPSRotate")
	hitbox = get_parent().get_node("Hitbox")
	#maybe following is redundant? IDK get someone actually smart to check
	moveCheck = get_parent().runSpeed

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	# Rotating the Head
	head.rotation.z = FPS.rotation.x
	
	#Movement Check
	moveCheck = get_parent().runSpeed
	if moveCheck == 5:
		move = 1
		angle = 0
	elif moveCheck == 9:
		move = 1.5
		angle = 20
	else:
		move = 0.3333333333333333333333333333333333333333333
		angle = -10
	
	# walking animation
	if Input.is_action_pressed("move_forward") or Input.is_action_pressed("move_backward") or Input.is_action_pressed("move_left") or Input.is_action_pressed("move_right"):
		lArm.rotation_degrees.z += walkSpeed * move * armCycle
		rArm.rotation_degrees.z -= walkSpeed * move * armCycle
		if lArm.rotation_degrees.z >= armArc+angle:
			lArm.rotation_degrees.z = armArc+angle
			rArm.rotation_degrees.z = -armArc-angle
			armCycle = -armCycle
		elif lArm.rotation_degrees.z <= -armArc-angle:
			lArm.rotation_degrees.z = -armArc-angle
			rArm.rotation_degrees.z = armArc+angle
			armCycle = -armCycle
		
		lLeg.rotation_degrees.z -= walkSpeed * move * (legArc / armArc) * legCycle
		rLeg.rotation_degrees.z += walkSpeed * move * (legArc / armArc) * legCycle
		if rLeg.rotation_degrees.z >= legArc+angle * (legArc / armArc):
			lLeg.rotation_degrees.z = -legArc-angle * (legArc / armArc)
			rLeg.rotation_degrees.z = legArc+angle * (legArc / armArc)
			legCycle = -legCycle
		elif rLeg.rotation_degrees.z <= -legArc-angle * (legArc / armArc):
			lLeg.rotation_degrees.z = legArc+angle * (legArc / armArc)
			rLeg.rotation_degrees.z = -legArc-angle * (legArc / armArc)
			legCycle = -legCycle
	else:
		if abs(lArm.rotation_degrees.z) > 0:
			lArm.rotation_degrees.z -= walkSpeed * (lArm.rotation_degrees.z/abs(lArm.rotation_degrees.z))
			rArm.rotation_degrees.z -= walkSpeed * (rArm.rotation_degrees.z/abs(rArm.rotation_degrees.z))
			lLeg.rotation_degrees.z -= walkSpeed * (legArc / armArc) * (lLeg.rotation_degrees.z/abs(lLeg.rotation_degrees.z))
			rLeg.rotation_degrees.z -= walkSpeed * (legArc / armArc) * (rLeg.rotation_degrees.z/abs(rLeg.rotation_degrees.z))
			var chk := abs(lLeg.rotation_degrees.z) as int
			if chk == 0 or chk == 1:
				lArm.rotation_degrees.z = 0
				rArm.rotation_degrees.z = 0
				lLeg.rotation_degrees.z = 0
				rLeg.rotation_degrees.z = 0
			
	# Crouching Animation + Hitbox
	if Input.is_action_pressed("crouch"):
		torso.rotation_degrees.z = 41.8103149
		torso.rotation_degrees.z *= -1
		head.rotation_degrees.z -= torso.rotation_degrees.z
		hitbox.shape.size.y = 1.5
		hitbox.position.y = 0.75
	if Input.is_action_just_released("crouch"):
		torso.rotation_degrees.z = 0
		hitbox.shape.size.y = 1.8
		hitbox.position.y = 0.9
	
	
