extends Node2D

@export var grid_size := Vector2i(8, 8)
@onready var tile_map: TileMap = $TileMap


func _ready() -> void:
	for x in grid_size.x:
		for y in grid_size.y:
			var coords := Vector2i(x, y)
			var tile_data := tile_map.get_cell_tile_data(0, coords)
			if is_instance_valid(tile_data):
				var atlas_coords := tile_map.get_cell_atlas_coords(0, coords)
				if atlas_coords.y < 1:
					continue
				check_if_active(tile_data, coords)


func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.pressed:
			var pos: Vector2 = event.position - tile_map.position
			var coords := tile_map.local_to_map(pos)
			var tile_data := tile_map.get_cell_tile_data(0, coords)
			if is_instance_valid(tile_data):
				var atlas_coords := tile_map.get_cell_atlas_coords(0, coords)
				if atlas_coords.y < 1:
					return
				var alternative_tile := tile_map.get_cell_alternative_tile(0, coords) + 1
				if alternative_tile > 3:
					alternative_tile = 0
				tile_map.set_cell(0, coords, 1, atlas_coords, alternative_tile)
				var new_tile_data := tile_map.get_cell_tile_data(0, coords)
				check_if_active(new_tile_data, coords)


func check_if_active(tile_data: TileData, coords: Vector2i) -> void:
	#var active := tile_data.get_custom_data("activated") as bool
	var look_at_1 := tile_data.get_custom_data("look_at_1") as Vector2i
	var look_at_2 := tile_data.get_custom_data("look_at_2") as Vector2i
	var look_at_3 := tile_data.get_custom_data("look_at_3") as Vector2i
	var look_at_4 := tile_data.get_custom_data("look_at_4") as Vector2i
	var neighbor_1 := tile_map.get_cell_tile_data(0, coords + look_at_1)
	var neighbor_2 := tile_map.get_cell_tile_data(0, coords + look_at_2)
	var neighbor_3 := tile_map.get_cell_tile_data(0, coords + look_at_3)
	var neighbor_4 := tile_map.get_cell_tile_data(0, coords + look_at_4)
	var active_neighbor_1 := false
	if is_instance_valid(neighbor_1):
		active_neighbor_1 = neighbor_1.get_custom_data("activated")
	var active_neighbor_2 := false
	if is_instance_valid(neighbor_2):
		active_neighbor_2 = neighbor_2.get_custom_data("activated")
	var active_neighbor_3 := false
	if is_instance_valid(neighbor_3):
		active_neighbor_3 = neighbor_3.get_custom_data("activated")
	var active_neighbor_4 := false
	if is_instance_valid(neighbor_4):
		active_neighbor_4 = neighbor_4.get_custom_data("activated")
	var is_active := active_neighbor_1 or active_neighbor_2 or active_neighbor_3 or active_neighbor_4
	tile_data.set_custom_data("activated", is_active)
	if is_active:
		tile_data.modulate = Color.WHITE
	else:
		tile_data.modulate = Color.GRAY
