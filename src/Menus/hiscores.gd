extends Panel

@onready var score_container: GridContainer = %ScoreContainer


func _ready() -> void:
	%ReturnToMenu.grab_focus()
	for i in GameManager.levels.size():
		var level := GameManager.levels[i]
		var level_label := Label.new()
		var moves_label := Label.new()
		var time_label := Label.new()
		level_label.text = "Level %s" % (i + 1)
		moves_label.text = str(level.moves)
		time_label.text =  GameManager.format_timer(level.minutes, level.seconds)
		score_container.add_child(level_label)
		score_container.add_child(moves_label)
		score_container.add_child(time_label)


func _on_return_to_menu_pressed() -> void:
	get_tree().change_scene_to_packed(GameManager.MENU_TSCN)
