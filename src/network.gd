extends Node2D

enum ActivatedStates { NONE, WATER, LAVA, BOTH }

@export var grid_size := Vector2i(8, 8)
var water_source_atlas_coords := Vector2i.ZERO
var water_activated_atlas_coords := Vector2i(1, 0)
var lava_source_atlas_coords := Vector2i(2, 0)
var lava_activated_atlas_coords := Vector2i(3, 0)
var inactive_atlas_coords := Vector2i(4, 0)
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
				deactivate_entire_grid()
				check_entire_grid()


func deactivate_entire_grid() -> void:
	for x in grid_size.x:
		for y in grid_size.y:
			var coords := Vector2i(x, y)
			toggle_tile(coords, ActivatedStates.NONE)


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
	var state := active_neighbor_1 | active_neighbor_2 | active_neighbor_3 | active_neighbor_4
	if state >= ActivatedStates.BOTH:
		print("LOST")
		state = ActivatedStates.NONE
	return toggle_tile(coords, state)


func is_neighbor_active(neighbor_data: TileData, coords: Vector2i, look_at_dir: Vector2i) -> ActivatedStates:
	if not is_instance_valid(neighbor_data):
		return ActivatedStates.NONE
	if look_at_dir == Vector2i.ZERO:
		return ActivatedStates.NONE
	var neighbor_coords := coords + look_at_dir
	var neighbor_active := ActivatedStates.NONE
	var atlas_coords := tile_map.get_cell_atlas_coords(0, neighbor_coords)
	if atlas_coords == water_source_atlas_coords or atlas_coords.y == ActivatedStates.WATER + 1:
		neighbor_active = ActivatedStates.WATER
	elif atlas_coords == lava_source_atlas_coords or atlas_coords.y == ActivatedStates.LAVA + 1:
		neighbor_active = ActivatedStates.LAVA
	if neighbor_active == ActivatedStates.NONE:
		return ActivatedStates.NONE
	var can_activate := ActivatedStates.NONE
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
			can_activate = neighbor_active
	return can_activate


func toggle_tile(coords: Vector2i, set_state: ActivatedStates) -> bool:
	var has_changed := false
	var atlas_coords := tile_map.get_cell_atlas_coords(0, coords)
	if atlas_coords == water_source_atlas_coords or atlas_coords == lava_source_atlas_coords:
		# Never de-activate the sources
		return false
	var alternative_tile := tile_map.get_cell_alternative_tile(0, coords)
	if atlas_coords.y == 0:
		var target_coords := inactive_atlas_coords
		if set_state == ActivatedStates.WATER:
			target_coords = water_activated_atlas_coords
		elif set_state == ActivatedStates.LAVA:
			target_coords = lava_activated_atlas_coords
		if atlas_coords != target_coords:
			tile_map.set_cell(0, coords, 1, target_coords, alternative_tile)
			has_changed = true
	else:
		if atlas_coords.y != set_state + 1:
			atlas_coords.y = set_state + 1
			tile_map.set_cell(0, coords, 1, atlas_coords, alternative_tile)
			has_changed = true
	#else:
		#if atlas_coords == Vector2i(1, 0):
			#tile_map.set_cell(0, coords, 1, Vector2i(5, 0), alternative_tile)
			#has_changed = true
		#elif atlas_coords.y == 1:
			#atlas_coords.y = set_state + 1
			#tile_map.set_cell(0, coords, 1, atlas_coords, alternative_tile)
			#has_changed = true
	return has_changed
