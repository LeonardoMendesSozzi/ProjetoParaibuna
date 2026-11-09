extends CharacterBody2D
class_name BaseEnemy

### Referencias
var world: WorldScene
var player: Player

### Status base
var health: int = 4
var damage: int = 1
var speed: float = 40.0

### Altitude
@export var height: float = 0.0
var height_velocity: float = 0.0
@export var vertical_hit_box: float = 25.0
@export var is_flying: bool = false
const GRAVITY: float = 200.0

### Knockback
@export var knockback_intensity: float = 60.0
@export var dead_intensity: float = 80.0

### Nodos
@onready var target_area: Area2D = $TargetArea
@onready var attack_cooldown: Timer = $AttackCooldown
@onready var sprite: Sprite2D = $SpriteContainer/Sprite
@onready var attack_area_left: Area2D = $AttackAreaLeft
@onready var attack_area_right: Area2D = $AttackAreaRight
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var collision: CollisionShape2D = $Collision
@onready var sprite_container: Node2D = $SpriteContainer

### Direção
var face_dir: Vector2 = Vector2.RIGHT
var target_dir: Vector2 = Vector2.ZERO

### Player ao alcance
var player_at_range: bool = false

### Pronto para atacar
var ready_to_attack: bool = false

### Parametros de Ataque
var attack_velocity: Vector2 = Vector2.ZERO
@export var attack_intensity: float = 100.0

### Escala de Movimento
@export var speed_scale: Vector2 = Vector2(1.0, 0.6)

### Função de Dano
func take_damage(damage: int, direction: Vector2):
	pass

func if_no_health() -> void:
	pass

func handle_dead() -> void:
	pass

### Sinais do Target Area
func _on_target_area_area_entered(area: Area2D) -> void:
	pass

func _on_target_area_area_exited(area: Area2D) -> void:
	pass

### Areas de Dano
func _on_attack_area_left_area_entered(area: Area2D) -> void:
	pass
	
func _on_attack_area_right_area_entered(area: Area2D) -> void:
	pass

### Sinais do Timer
func _on_attack_cooldown_timeout() -> void:
	pass
