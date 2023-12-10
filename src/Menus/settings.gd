extends Panel

var sound_bus_index := AudioServer.get_bus_index(&"Master")

@onready var sound_volume_slider: ValueSlider = %SoundVolumeSlider
@onready var mute_button: TextureButton = %MuteButton


func _ready() -> void:
	%ReturnToMenu.grab_focus()
	var volume := db_to_linear(AudioServer.get_bus_volume_db(sound_bus_index))
	sound_volume_slider.value = volume * 100.0
	if TranslationServer.get_locale().begins_with("el_"):
		%LanguageOptionButton.select(1)


func _on_return_to_menu_pressed() -> void:
	get_tree().change_scene_to_packed(GameManager.MENU_TSCN)


func _on_sound_volume_slider_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(sound_bus_index, linear_to_db(value / 100.0))
	if is_zero_approx(value):
		mute_button.button_pressed = true
	else:
		mute_button.button_pressed = false


func _on_language_option_button_item_selected(index: int) -> void:
	if index == 1:
		TranslationServer.set_locale("el_GR")
	else:
		TranslationServer.set_locale("en_US")


func _on_mute_button_toggled(toggled_on: bool) -> void:
	if toggled_on:
		sound_volume_slider.value = 0
	else:
		sound_volume_slider.value = 100
