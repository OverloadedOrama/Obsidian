extends Panel


func _ready() -> void:
	%ReturnToMenu.grab_focus()
	if TranslationServer.get_locale().begins_with("el_"):
		%LanguageOptionButton.select(1)


func _on_return_to_menu_pressed() -> void:
	get_tree().change_scene_to_packed(GameManager.MENU_TSCN)


func _on_sound_volume_slider_value_changed(value: float) -> void:
	var bus_index := AudioServer.get_bus_index(&"Sounds")
	AudioServer.set_bus_volume_db(bus_index, linear_to_db(value / 100.0))


func _on_language_option_button_item_selected(index: int) -> void:
	if index == 1:
		TranslationServer.set_locale("el_GR")
	else:
		TranslationServer.set_locale("en")
