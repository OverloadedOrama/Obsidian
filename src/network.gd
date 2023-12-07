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
				check_if_active(tile_data, coords, true)


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
				check_if_active(new_tile_data, coords, false)


func check_if_active(tile_data: TileData, coords: Vector2i, start_of_game: bool) -> void:
	var look_at_1 := tile_data.get_custom_data("look_at_1") as Vector2i
	var look_at_2 := tile_data.get_custom_data("look_at_2") as Vector2i
	var look_at_3 := tile_data.get_custom_data("look_at_3") as Vector2i
	var look_at_4 := tile_data.get_custom_data("look_at_4") as Vector2i
	var neighbor_1 := tile_map.get_cell_tile_data(0, coords + look_at_1)
	var neighbor_2 := tile_map.get_cell_tile_data(0, coords + look_at_2)
	var neighbor_3 := tile_map.get_cell_tile_data(0, coords + look_at_3)
	var neighbor_4 := tile_map.get_cell_tile_data(0, coords + look_at_4)
	var active_neighbor_1 := get_neighbor_status(neighbor_1, coords + look_at_1, start_of_game)
	var active_neighbor_2 := get_neighbor_status(neighbor_2, coords + look_at_2, start_of_game)
	var active_neighbor_3 := get_neighbor_status(neighbor_3, coords + look_at_3, start_of_game)
	var active_neighbor_4 := get_neighbor_status(neighbor_4, coords + look_at_4, start_of_game)
	var is_active := active_neighbor_1 or active_neighbor_2 or active_neighbor_3 or active_neighbor_4
	var alternative_tile := tile_map.get_cell_alternative_tile(0, coords)
	var atlas_coords := tile_map.get_cell_atlas_coords(0, coords)
	if is_active:
		atlas_coords.y = 1
		tile_map.set_cell(0, coords, 1, atlas_coords, alternative_tile)
	else:
		atlas_coords.y = 2
		tile_map.set_cell(0, coords, 1, atlas_coords, alternative_tile)


func get_neighbor_status(neighbor_data: TileData, neighbor_coords: Vector2i, start_of_game: bool) -> bool:
	if not is_instance_valid(neighbor_data):
		return false
	var atlas_coords := tile_map.get_cell_atlas_coords(0, neighbor_coords)
	if atlas_coords == Vector2i.ZERO or atlas_coords == Vector2i(1, 0):
		return true
	if not start_of_game and atlas_coords.y == 1:
		return true
	return false
