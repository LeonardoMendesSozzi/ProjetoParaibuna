extends Node2D
class_name PlayerProjectile


@onready var sprite: AnimatedSprite2D = $Sprite
@onready var detection: Area2D = $Area

@export var base_height: float = 20.0
@export var move_speed: float = 200.0

var splashed: bool = false
var direction: Vector2 = Vector2.RIGHT
var height: float = 0.0
var velocity: Vector2

var is_powered: bool = false
var power_damage: int = 2
var normal_damage: int = 1


func _ready() -> void:
	if is_powered:
		sprite.play("power")
	
	if direction == Vector2.LEFT:
		scale.x = -1
	else:
		scale.x = 1
	
	velocity = direction * move_speed
	
	sprite.position.y = - height


func _physics_process(delta: float) -> void:
	if not splashed:
		position += velocity * delta

func _on_visible_on_screen_notifier_screen_exited() -> void:
	self.queue_free()

func _on_area_body_entered(body: Node2D) -> void:
	if (
		height < body.height or
		height > body.height + body.vertical_hit_box
	):
		return
	
	if not body.has_method("take_damage"):
		return
	
	if is_powered:
		body.take_damage(power_damage, direction)
	else:
		body.take_damage(normal_damage, direction)
	
	detection.set_deferred("monitoring", false)
	detection.set_deferred("monitorable", false)
	splashed = true
	sprite.play("splash")

func _on_sprite_animation_finished() -> void:
	queue_free()
