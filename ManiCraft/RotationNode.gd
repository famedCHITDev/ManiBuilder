extends Node3D

var mouseDelta : Vector2 = Vector2()

var minLookAngle : float = -90.0
var maxLookAngle : float = 90.0
@export var lookSensitivity : float = 20.0
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	rotation_degrees.x -= mouseDelta.y * lookSensitivity * delta

	# clamp camera x rotation axis
	rotation_degrees.x = clamp(rotation_degrees.x, minLookAngle, maxLookAngle)

	# rotate the player along their y-axis
	rotation_degrees.y -= mouseDelta.x * lookSensitivity * delta

	# reset the mouseDelta vector
	mouseDelta = Vector2()
func _input(event):
	if event is InputEventMouseMotion:
		mouseDelta = event.relative
