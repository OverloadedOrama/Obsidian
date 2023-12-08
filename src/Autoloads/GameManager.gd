extends Node

const MENU_TSCN := preload("res://src/Menus/menu.tscn")
const MAIN_GAME_TSCN := preload("res://src/main_game.tscn")
const HISCORES_TSCN := preload("res://src/Menus/hiscores.tscn")
const SETTINGS_TSCN := preload("res://src/Menus/settings.tscn")
const CREDITS_TSCN := preload("res://src/Menus/credits.tscn")

var levels: Array[LevelData] = []

class LevelData:
	var moves := 0
	var seconds := 0:
		set(value):
			if value >= 60:
				seconds = 0
				minutes += 1
			else:
				seconds = value
	var minutes := 0


func add_level_data(tile_map: GameMap, index: int) -> void:
	var level_data: LevelData
	if index < levels.size():
		level_data = levels[index]
	else:
		level_data = LevelData.new()
		levels.append(level_data)
	level_data.moves = tile_map.moves
	level_data.seconds = tile_map.seconds
	level_data.minutes = tile_map.minutes


func format_timer(minutes: int, seconds: int) -> String:
	var minutes_str := ("%s" % minutes).pad_zeros(2)
	var seconds_str := ("%s" % seconds).pad_zeros(2)
	return minutes_str + ":" + seconds_str
