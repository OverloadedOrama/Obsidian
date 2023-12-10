extends Panel

var master_bus_index := AudioServer.get_bus_index(&"Master")
var music_bus_index := AudioServer.get_bus_index(&"Music")
var sound_bus_index := AudioServer.get_bus_index(&"Sounds")

@onready var master_volume_slider: ValueSlider = %MasterVolumeSlider
@onready var master_mute_button: TextureButton = %MasterMuteButton
@onready var music_volume_slider: ValueSlider = %MusicVolumeSlider
@onready var music_mute_button: TextureButton = %MusicMuteButton
@onready var sound_volume_slider: ValueSlider = %SoundVolumeSlider
@onready var sound_mute_button: TextureButton = %SoundMuteButton


func _ready() -> void:
	%ReturnToMenu.grab_focus()
	var master_volume := db_to_linear(AudioServer.get_bus_volume_db(master_bus_index))
	master_volume_slider.value = master_volume * 100.0
	var music_volume := db_to_linear(AudioServer.get_bus_volume_db(music_bus_index))
	music_volume_slider.value = music_volume * 100.0
	var sound_volume := db_to_linear(AudioServer.get_bus_volume_db(sound_bus_index))
	sound_volume_slider.value = sound_volume * 100.0
	if TranslationServer.get_locale().begins_with("el_"):
		%LanguageOptionButton.select(1)


func _on_return_to_menu_pressed() -> void:
	get_tree().change_scene_to_packed(GameManager.MENU_TSCN)


func _on_language_option_button_item_selected(index: int) -> void:
	if index == 1:
		TranslationServer.set_locale("el_GR")
	else:
		TranslationServer.set_locale("en_US")


func _on_master_volume_slider_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(master_bus_index, linear_to_db(value / 100.0))
	if is_zero_approx(value):
		master_mute_button.button_pressed = true
	else:
		master_mute_button.button_pressed = false


func _on_master_mute_button_toggled(toggled_on: bool) -> void:
	if toggled_on:
		master_volume_slider.value = 0
	else:
		master_volume_slider.value = 100


func _on_music_volume_slider_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(music_bus_index, linear_to_db(value / 100.0))
	if is_zero_approx(value):
		music_mute_button.button_pressed = true
	else:
		music_mute_button.button_pressed = false


func _on_music_mute_button_toggled(toggled_on: bool) -> void:
	if toggled_on:
		music_volume_slider.value = 0
	else:
		music_volume_slider.value = 100


func _on_sound_volume_slider_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(sound_bus_index, linear_to_db(value / 100.0))
	if is_zero_approx(value):
		sound_mute_button.button_pressed = true
	else:
		sound_mute_button.button_pressed = false


func _on_sound_mute_button_toggled(toggled_on: bool) -> void:
	if toggled_on:
		sound_volume_slider.value = 0
	else:
		sound_volume_slider.value = 100
