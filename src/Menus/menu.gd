extends Panel

@onready var play_button: Button = %PlayButton
@onready var exit_button: Button = %ExitButton


func _ready() -> void:
	if OS.get_name() == "Web":
		exit_button.visible = false
	play_button.grab_focus()


func _on_play_button_pressed() -> void:
	get_tree().change_scene_to_packed(GameManager.MAIN_GAME_TSCN)


func _on_hi_scores_button_pressed() -> void:
	get_tree().change_scene_to_packed(GameManager.HISCORES_TSCN)


func _on_settings_button_pressed() -> void:
	get_tree().change_scene_to_packed(GameManager.SETTINGS_TSCN)


func _on_credits_button_pressed() -> void:
	get_tree().change_scene_to_packed(GameManager.CREDITS_TSCN)


func _on_exit_button_pressed() -> void:
	get_tree().quit()
