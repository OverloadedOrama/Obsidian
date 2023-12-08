extends Panel

@onready var score_container: GridContainer = %ScoreContainer


func _ready() -> void:
	%ReturnToMenu.grab_focus()
	var section_keys := GameManager.config.get_section_keys("moves")
	for i in section_keys.size():
		var current_moves_hiscore = GameManager.config.get_value("moves", str(i), 0)
		var current_time_hiscore = GameManager.config.get_value("time", str(i), 0)
		var level_data := GameManager.LevelData.new()
		level_data.moves = current_moves_hiscore
		level_data.seconds = current_time_hiscore
		var level_label := Label.new()
		var moves_label := Label.new()
		var time_label := Label.new()
		level_label.text = "Level %s" % (i + 1)
		moves_label.text = str(level_data.moves)
		time_label.text = GameManager.format_timer(level_data.minutes, level_data.seconds)
		score_container.add_child(level_label)
		score_container.add_child(moves_label)
		score_container.add_child(time_label)


func _on_return_to_menu_pressed() -> void:
	get_tree().change_scene_to_packed(GameManager.MENU_TSCN)
