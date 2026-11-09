extends Node2D
class_name ItemText


@onready var despawn_timer: Timer = $DespawnTimer
@onready var label_text: Label = $Text

var text: String = "TESTE"

@export var speed: float = 10


func _ready() -> void:
	label_text.set_text(text)

func _process(delta: float) -> void:
	label_text.position.y -= speed * delta

func _on_despawn_timer_timeout() -> void:
	queue_free()
