extends CanvasLayer
class_name GameHUD


@onready var label_points: Label = $Points

func change_points(points: int) -> void:
	label_points.set_text("POINTS: " + str(points))
