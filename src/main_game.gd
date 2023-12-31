extends Node2D

enum { PLAYING, WON, LOST }
enum ActivatedStates { NONE, WATER, LAVA, BOTH }
const OUTLINE_TEXTURE := preload("res://assets/outline.png")
const WATER_SOURCE_ATLAS_COORDS := Vector2i.ZERO
const WATER_ACTIVATED_ATLAS_COORDS := Vector2i(1, 0)
const LAVA_SOURCE_ATLAS_COORDS := Vector2i(2, 0)
const LAVA_ACTIVATED_ATLAS_COORDS := Vector2i(3, 0)
const INACTIVE_ATLAS_COORDS := Vector2i(4, 0)

var levels: Array[PackedScene] = [
	preload("res://src/Levels/level_1.tscn"),
	preload("res://src/Levels/level_2.tscn"),
	preload("res://src/Levels/level_3.tscn"),
	preload("res://src/Levels/level_4.tscn"),
	preload("res://src/Levels/level_5.tscn"),
	preload("res://src/Levels/level_6.tscn"),
	preload("res://src/Levels/level_7.tscn"),
	preload("res://src/Levels/level_8.tscn"),
	preload("res://src/Levels/level_9.tscn"),
	preload("res://src/Levels/level_10.tscn"),
	preload("res://src/Levels/level_11.tscn"),
	preload("res://src/Levels/level_12.tscn"),
	preload("res://src/Levels/level_13.tscn"),
]
var current_level := 0
var water_targets_activated := 0
var lava_targets_activated := 0
var water_pipes := 0
var lava_pipes := 0
var currently_selected_tile_cell := Vector2i.ZERO
var game_is_over := PLAYING:
	set(value):
		game_is_over = value
		if value == PLAYING:
			timer.start()
		else:
			timer.stop()

@onready var tile_map_holder: Node2D = $TileMapHolder
@onready var tile_map: GameMap
@onready var level_label: Label = %LevelLabel
@onready var water_texture_rect: TextureRect = %WaterTextureRect
@onready var water_targets: Label = %WaterTargets
@onready var lava_texture_rect: TextureRect = %LavaTextureRect
@onready var lava_targets: Label = %LavaTargets
@onready var game_result: Label = %GameResult
@onready var moves_label: Label = %MovesLabel
@onready var time_label: Label = %TimeLabel
@onready var rotate_tip: Label = %RotateTip
@onready var water_lava_warning: Label = %WaterLavaWarning
@onready var rotate_pipe_sound: AudioStreamPlayer = $RotatePipeSound
@onready var water_activated_sound: AudioStreamPlayer = $WaterActivatedSound
@onready var lava_activated_sound: AudioStreamPlayer = $LavaActivatedSound
@onready var victory_sound: AudioStreamPlayer = $VictorySound
@onready var lose_sound: AudioStreamPlayer = $LoseSound
@onready var timer: Timer = $Timer


func _ready() -> void:
	change_level()


func _input(event: InputEvent) -> void:
	if not is_instance_valid(tile_map):
		return
	if game_is_over == WON:
		if event.is_action_released("rotate"):
			go_to_next_level()
		return
	elif game_is_over == LOST:
		if event.is_action_released("rotate"):
			change_level()  # Restart
		return
	currently_selected_tile_cell += Vector2i(Input.get_vector(&"ui_left", &"ui_right", &"ui_up", &"ui_down"))
	if event is InputEventMouseMotion or event is InputEventScreenTouch:
		var pos: Vector2 = event.position - tile_map.global_position
		if pos.x >= 0 and pos.y >= 0:
			currently_selected_tile_cell = tile_map.local_to_map(pos)
	if event.is_action_released("rotate"):
		var coords := currently_selected_tile_cell
		var tile_data := tile_map.get_cell_tile_data(0, coords)
		if is_instance_valid(tile_data):
			# Rotate pipes
			var atlas_coords := tile_map.get_cell_atlas_coords(0, coords)
			# Don't rotate sources/targets and static pipes
			if atlas_coords.y >= 1 and atlas_coords.x <= 2:
				var alternative_tile := tile_map.get_cell_alternative_tile(0, coords) + 1
				if alternative_tile > 3:
					alternative_tile = 0
				tile_map.set_cell(0, coords, 1, atlas_coords, alternative_tile)
				tile_map.moves += 1
				moves_label.text = "%s" % tile_map.moves
				rotate_pipe_sound.play()
			calculate_game_status()
	queue_redraw()


func _draw() -> void:
	var draw_pos := tile_map.global_position + tile_map.map_to_local(currently_selected_tile_cell) - tile_map.tile_set.tile_size / 2.0
	draw_texture(OUTLINE_TEXTURE, draw_pos)


func calculate_game_status() -> void:
	var prev_water_pipes := water_pipes
	var prev_lava_pipes := lava_pipes
	water_pipes = 0
	lava_pipes = 0
	deactivate_entire_grid()
	check_entire_grid()
	if water_pipes > prev_water_pipes:
		water_activated_sound.play()
	if lava_pipes > prev_lava_pipes:
		lava_activated_sound.play()
	water_targets.text = "%s/%s" % [water_targets_activated, tile_map.water_targets_needed]
	lava_targets.text = "%s/%s" % [lava_targets_activated, tile_map.lava_targets_needed]
	if water_targets_activated == tile_map.water_targets_needed and lava_targets_activated == tile_map.lava_targets_needed:
		if game_is_over == PLAYING:
			game_result.text = tr("You have won!")
			game_is_over = WON
			victory_sound.play()


func deactivate_entire_grid() -> void:
	for x in tile_map.grid_size.x:
		for y in tile_map.grid_size.y:
			var coords := Vector2i(x, y)
			toggle_tile(coords, ActivatedStates.NONE)


func check_entire_grid() -> void:
	water_targets_activated = 0
	lava_targets_activated = 0
	for x in tile_map.grid_size.x:
		for y in tile_map.grid_size.y:
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
		game_result.text = tr("You have lost!")
		game_is_over = LOST
		lose_sound.play()
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
	if atlas_coords == WATER_SOURCE_ATLAS_COORDS or atlas_coords == WATER_ACTIVATED_ATLAS_COORDS or atlas_coords.y == ActivatedStates.WATER + 1:
		neighbor_active = ActivatedStates.WATER
	elif atlas_coords == LAVA_SOURCE_ATLAS_COORDS or atlas_coords == LAVA_ACTIVATED_ATLAS_COORDS or atlas_coords.y == ActivatedStates.LAVA + 1:
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
	var atlas_coords := tile_map.get_cell_atlas_coords(0, coords)
	if atlas_coords == WATER_SOURCE_ATLAS_COORDS or atlas_coords == LAVA_SOURCE_ATLAS_COORDS:
		# Never de-activate the sources
		return false
	if atlas_coords == Vector2i(-1, -1):
		return false
	var has_changed := false
	var alternative_tile := tile_map.get_cell_alternative_tile(0, coords)
	if atlas_coords.y == 0:
		var target_coords := atlas_coords
		if set_state == ActivatedStates.WATER:
			water_targets_activated += 1
			target_coords = WATER_ACTIVATED_ATLAS_COORDS
		elif set_state == ActivatedStates.LAVA:
			lava_targets_activated += 1
			target_coords = LAVA_ACTIVATED_ATLAS_COORDS
		else:
			target_coords = INACTIVE_ATLAS_COORDS
		if atlas_coords != target_coords:
			tile_map.set_cell(0, coords, 1, target_coords, alternative_tile)
			has_changed = true
	else:
		if atlas_coords.y != set_state + 1:
			if set_state == ActivatedStates.WATER:
				water_pipes += 1
			elif set_state == ActivatedStates.LAVA:
				lava_pipes += 1
			atlas_coords.y = set_state + 1
			tile_map.set_cell(0, coords, 1, atlas_coords, alternative_tile)
			has_changed = true
	return has_changed


func _on_restart_button_pressed() -> void:
	change_level()


func go_to_next_level() -> void:
	GameManager.add_level_data(tile_map, current_level)
	if current_level == levels.size() - 1:
		finished_all_levels()
	else:
		current_level += 1
	change_level()


func change_level() -> void:
	var new_tile_map := levels[current_level].instantiate() as GameMap
	if is_instance_valid(tile_map):
		tile_map.queue_free()
	tile_map_holder.add_child(new_tile_map)
	tile_map = new_tile_map
	level_label.text = tr("Level %s") % [current_level + 1]
	tile_map.moves = 0
	tile_map.seconds = 0
	tile_map.minutes = 0
	moves_label.text = "%s" % tile_map.moves
	time_label.text = "00:00"
	game_result.text = ""
	game_is_over = PLAYING
	water_texture_rect.visible = tile_map.water_targets_needed > 0
	water_targets.visible = tile_map.water_targets_needed > 0
	lava_texture_rect.visible = tile_map.lava_targets_needed > 0
	lava_targets.visible = tile_map.lava_targets_needed > 0
	rotate_tip.visible = current_level == 0
	water_lava_warning.visible = current_level >= 6
	calculate_game_status()


func finished_all_levels() -> void:
	GameManager.store_hiscores()
	get_tree().change_scene_to_packed(GameManager.HISCORES_TSCN)


func _on_timer_timeout() -> void:
	if game_is_over != PLAYING:
		return
	tile_map.seconds += 1
	time_label.text = GameManager.format_timer(tile_map.minutes, tile_map.seconds)


func _on_return_to_menu_pressed() -> void:
	GameManager.store_hiscores()
	get_tree().change_scene_to_packed(GameManager.MENU_TSCN)
