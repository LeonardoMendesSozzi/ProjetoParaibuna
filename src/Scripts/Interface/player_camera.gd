extends Camera2D
class_name PlayerCamera

@export var min_pos: Vector2 = Vector2(-240.0, -10.0)
@export var max_pos: Vector2 = Vector2(240.0, -10.0)
var player: Player

func _process(_delta: float) -> void:
	if player == null:
		print("Erro, player não definido!")
		return
	
	move_camera(player.global_position)

func move_camera(pos: Vector2) -> void:
	pos.x = clamp(pos.x, min_pos.x, max_pos.x)
	pos.y = clamp(pos.y, min_pos.y, max_pos.y)
	global_position = pos
