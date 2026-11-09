extends StaticBody2D
class_name Prop

### TODO: Fazer com que o World spawne os itens, não os props

@export var item_scene: PackedScene
@export var item_stats: ItemStats
@export var item_will_fly: bool = false

@onready var sprite: Sprite2D = $Sprite
@onready var collision: CollisionShape2D = $CollisionShape

const GRAVITY: float = 200.0

@export var knockback_intensity: float = 10.0
@export var destroyed_intensity: float = 60.0
@export var speed: float = 40.0
var height_velocity: float = 0.0
var velocity: Vector2 = Vector2.ZERO

@export var height: float = 0.0
@export var is_flying: bool = false
@export var vertical_hit_box: float = 0.0

@export var health: int = 1


func _ready() -> void:
	velocity = Vector2.LEFT * speed
	sprite.position.y = -height
	if is_flying:
		set_collision_layer_value(5, false)
		set_collision_layer_value(6, true)


func _process(delta: float) -> void:
	handle_movement(delta)
	if_no_health()
	handle_offscreen()

func handle_movement(delta: float) -> void:
	height += height_velocity * delta
	
	sprite.position.y = -height
	
	if not is_flying: height_velocity -= GRAVITY * delta
	
	if height <= 0.0:
		height_velocity = 0.0
	
	position += velocity * delta

func if_no_health() -> void:
	if health <= 0:
		is_flying = false
		
		if height <= 0.0:
			handle_destruction()

func take_damage(dmg: int, dir: Vector2) -> void:
	health -= dmg

	if health <= 0:
		collision.call_deferred("set_disabled", true)
		
		velocity.x = dir.x * (speed + knockback_intensity)
		height_velocity += destroyed_intensity

func handle_destruction() -> void:
	if item_stats != null:
		var item: Node = item_scene.instantiate()
		
		item.stats = item_stats
		item.global_position = global_position
		item.height = height if height >= 0.0 else 0.0
		item.is_flying = item_will_fly
		
		get_parent().add_child(item)
	
	queue_free()

func handle_offscreen() -> void:
	if global_position.x < -500 or global_position.x > 500:
		queue_free()
