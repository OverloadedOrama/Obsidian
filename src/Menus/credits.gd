extends Panel


func _ready() -> void:
	%ReturnToMenu.grab_focus()


func _on_return_to_menu_pressed() -> void:
	get_tree().change_scene_to_packed(GameManager.MENU_TSCN)
