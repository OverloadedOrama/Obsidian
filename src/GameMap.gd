class_name GameMap
extends TileMap

@export var grid_size := Vector2i(8, 9)
@export var water_targets_needed := 2
@export var lava_targets_needed := 2

var moves := 0
var seconds := 0:
	set(value):
		if value >= 60:
			seconds = 0
			minutes += 1
		else:
			seconds = value
var minutes := 0
