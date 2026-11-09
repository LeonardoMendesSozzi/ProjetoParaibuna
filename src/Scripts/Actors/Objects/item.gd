extends Area2D
class_name Item


##TODO Fazer com que o item seje pego na altura certa

var stats: ItemStats
@onready var sprite: Sprite2D = $Sprite
@export var points: int
@export var item_type: ItemTypes.Type

@export var speed: float = 30.0
var height_velocity: float = 0.0
var velocity: Vector2 = Vector2.ZERO
var height: float = 0.0
const GRAVITY: float = 200.0

var is_flying: bool = false


func _ready() -> void:
	sprite.texture = stats.texture
	points = stats.points
	item_type = stats.item_type


func _on_area_entered(area: Area2D) -> void:
	if area.get_parent() is Player:
		handle_collected(area.get_parent())

# Aciona funções exclusivas do player ao ser coletado
func handle_collected(player: Player) -> void:
	match item_type:
		ItemTypes.Type.POINTS:
			player.item_points(points)
		ItemTypes.Type.POWER_UP:
			player.item_power_up()
		ItemTypes.Type.SPEED_UP:
			player.item_speed_up()
		ItemTypes.Type.SHIELD:
			player.shield_up()
		ItemTypes.Type.LIFE_UP:
			player.item_life_up()
	
	queue_free()
