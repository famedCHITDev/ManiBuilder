extends Node3D

var terrain : VoxelTerrain
var a : Array

func save(content):
	var file = FileAccess.open("insert file path", FileAccess.WRITE)
	file.store_string(content)

func load():
	var file = FileAccess.open("insert file path", FileAccess.READ)
	var content = file.get_as_text()
	return content

func _ready():
	terrain = $VoxelTerrain
	a = terrain.mesher.library.models
	for i in a:
		print(i)

func _process(delta):
	pass
