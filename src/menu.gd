extends Panel

const NETWORK_TSCN := preload("res://src/main_game.tscn")
@onready var play_button: Button = %PlayButton
@onready var exit_button: Button = %ExitButton


func _ready() -> void:
	if OS.get_name() == "Web":
		exit_button.visible = false
	play_button.grab_focus()


func _on_play_button_pressed() -> void:
	get_tree().change_scene_to_packed(NETWORK_TSCN)
