extends Node2D

@export var grid_size := Vector2i(8, 8)
@onready var tile_map: TileMap = $TileMap



func _ready() -> void:
	check_entire_grid()


func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.pressed:
			var pos: Vector2 = event.position - tile_map.position
			var coords := tile_map.local_to_map(pos)
			var tile_data := tile_map.get_cell_tile_data(0, coords)
			if is_instance_valid(tile_data):
				var atlas_coords := tile_map.get_cell_atlas_coords(0, coords)
				if atlas_coords.y >= 1:
					var alternative_tile := tile_map.get_cell_alternative_tile(0, coords) + 1
					if alternative_tile > 3:
						alternative_tile = 0
					tile_map.set_cell(0, coords, 1, atlas_coords, alternative_tile)
				#var new_tile_data := tile_map.get_cell_tile_data(0, coords)
				#check_if_active(new_tile_data, coords)
				check_entire_grid()


func check_entire_grid() -> void:
	for x in grid_size.x:
		for y in grid_size.y:
			var coords := Vector2i(x, y)
			var tile_data := tile_map.get_cell_tile_data(0, coords)
			if is_instance_valid(tile_data):
				var has_changed := check_if_active(tile_data, coords)
				if has_changed:
					check_entire_grid()
					return


func check_if_active(tile_data: TileData, coords: Vector2i) -> bool:
	var atlas_coords := tile_map.get_cell_atlas_coords(0, coords)
	var look_at_1 := tile_data.get_custom_data("look_at_1") as Vector2i
	var look_at_2 := tile_data.get_custom_data("look_at_2") as Vector2i
	var look_at_3 := tile_data.get_custom_data("look_at_3") as Vector2i
	var look_at_4 := tile_data.get_custom_data("look_at_4") as Vector2i
	var neighbor_1 := tile_map.get_cell_tile_data(0, coords + look_at_1)
	var neighbor_2 := tile_map.get_cell_tile_data(0, coords + look_at_2)
	var neighbor_3 := tile_map.get_cell_tile_data(0, coords + look_at_3)
	var neighbor_4 := tile_map.get_cell_tile_data(0, coords + look_at_4)
	var active_neighbor_1 := is_neighbor_active(neighbor_1, coords, look_at_1)
	var active_neighbor_2 := is_neighbor_active(neighbor_2, coords, look_at_2)
	var active_neighbor_3 := is_neighbor_active(neighbor_3, coords, look_at_3)
	var active_neighbor_4 := is_neighbor_active(neighbor_4, coords, look_at_4)
	var is_active := active_neighbor_1 or active_neighbor_2 or active_neighbor_3 or active_neighbor_4
	var alternative_tile := tile_map.get_cell_alternative_tile(0, coords)
	var has_changed := false
	if is_active:
		if atlas_coords == Vector2i(2, 0):
			tile_map.set_cell(0, coords, 1, Vector2i(1, 0), alternative_tile)
			has_changed = true
		elif atlas_coords.y == 2:
			atlas_coords.y = 1
			tile_map.set_cell(0, coords, 1, atlas_coords, alternative_tile)
			has_changed = true
	else:
		if atlas_coords == Vector2i(1, 0):
			tile_map.set_cell(0, coords, 1, Vector2i(2, 0), alternative_tile)
			has_changed = true
		elif atlas_coords.y == 1:
			atlas_coords.y = 2
			tile_map.set_cell(0, coords, 1, atlas_coords, alternative_tile)
			has_changed = true
	return has_changed


func is_neighbor_active(neighbor_data: TileData, coords: Vector2i, look_at_dir: Vector2i) -> bool:
	if not is_instance_valid(neighbor_data):
		return false
	if look_at_dir == Vector2i.ZERO:
		return false
	var neighbor_coords := coords + look_at_dir
	var neighbor_active := false
	var atlas_coords := tile_map.get_cell_atlas_coords(0, neighbor_coords)
	if atlas_coords == Vector2i.ZERO or atlas_coords.y == 1:
		neighbor_active = true
	if not neighbor_active:
		return false
	var can_activate := false
	var neighbor_look_at_dirs: Array[Vector2i] = [
		neighbor_data.get_custom_data("look_at_1") as Vector2i,
		neighbor_data.get_custom_data("look_at_2") as Vector2i,
		neighbor_data.get_custom_data("look_at_3") as Vector2i,
		neighbor_data.get_custom_data("look_at_4") as Vector2i,
	]
	for dir in neighbor_look_at_dirs:
		if dir == Vector2i.ZERO:
			continue
		if dir == -look_at_dir:
			can_activate = true
	return can_activate
