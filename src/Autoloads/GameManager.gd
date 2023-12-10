extends Node

const SAVED_HIGHSCORE_PATH := "user://hiscores.ini"
const MENU_TSCN := preload("res://src/Menus/menu.tscn")
const MAIN_GAME_TSCN := preload("res://src/main_game.tscn")
const HISCORES_TSCN := preload("res://src/Menus/hiscores.tscn")
const SETTINGS_TSCN := preload("res://src/Menus/settings.tscn")
const CREDITS_TSCN := preload("res://src/Menus/credits.tscn")
const MUSIC := preload("res://assets/audio/music/580898__bloodpixelhero__in-game.ogg")

var config := ConfigFile.new()
var levels: Array[LevelData] = []

class LevelData:
	var moves := 0
	var seconds := 0:
		set(value):
			if value >= 60:
				minutes += floor(value / 60)
				seconds = value - 60 * floor(value / 60)
			else:
				seconds = value
	var minutes := 0

	func minutes_to_seconds() -> int:
		var conv_seconds := seconds
		conv_seconds += minutes * 60
		return conv_seconds


func _ready() -> void:
	if OS.get_locale().begins_with("el"):
		TranslationServer.set_locale(OS.get_locale())
	config.load(SAVED_HIGHSCORE_PATH)
	var music_player := AudioStreamPlayer.new()
	music_player.stream = MUSIC
	music_player.bus = &"Music"
	add_child(music_player)
	music_player.play()


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


func store_hiscores() -> void:
	for i in levels.size():
		var level := levels[i]
		var current_moves_hiscore = config.get_value("moves", str(i), 0)
		var current_time_hiscore = config.get_value("time", str(i), 0)
		if level.moves < current_moves_hiscore or current_moves_hiscore == 0:
			config.set_value("moves", str(i), level.moves)
		var raw_seconds := level.minutes_to_seconds()
		if raw_seconds < current_time_hiscore or current_time_hiscore == 0:
			config.set_value("time", str(i), raw_seconds)
	config.save(SAVED_HIGHSCORE_PATH)
