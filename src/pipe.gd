extends Sprite2D

@export var active := false
@export var look_at_1 := Vector2i.ZERO
@export var look_at_2 := Vector2i.ZERO
@export var look_at_3 := Vector2i.ZERO
@export var look_at_4 := Vector2i.ZERO


func rotate_pipe() -> void:
	rotation_degrees += 90
	look_at_1 = Vector2(look_at_1).rotated(90)
	look_at_2 = Vector2(look_at_2).rotated(90)
	look_at_3 = Vector2(look_at_3).rotated(90)
	look_at_4 = Vector2(look_at_4).rotated(90)
