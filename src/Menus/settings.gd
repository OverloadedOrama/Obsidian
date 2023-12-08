extends Panel

var menu := load("res://src/Menus/menu.tscn") as PackedScene


func _ready() -> void:
	%ReturnToMenu.grab_focus()


func _on_return_to_menu_pressed() -> void:
	get_tree().change_scene_to_packed(menu)


func _on_sound_volume_slider_value_changed(value: float) -> void:
	var bus_index := AudioServer.get_bus_index(&"Sounds")
	AudioServer.set_bus_volume_db(bus_index, linear_to_db(value / 100.0))
