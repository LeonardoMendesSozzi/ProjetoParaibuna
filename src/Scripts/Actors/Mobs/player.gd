extends CharacterBody2D
class_name Player


# Referencia ao mundo
var world: WorldScene

### STATE MACHINE
enum State {
	IDLE,
	FIRE_RIGHT,
	FIRE_LEFT,
	JUMP,
	JUMP_F_RIGHT,
	JUMP_F_LEFT,
	HURT,
	DEAD,
}

var state: State = State.IDLE

### Animation Map
var anim_map: Dictionary={
	State.IDLE: "idle",
	State.FIRE_RIGHT: "fire_right",
	State.FIRE_LEFT: "fire_left",
	State.JUMP: "jump",
	State.JUMP_F_RIGHT: "jump_fire_r",
	State.JUMP_F_LEFT: "jump_fire_l",
	State.HURT: "dead",
	State.DEAD: "dead",
}


const GRAVITY: float = 1200.0

# Colisão
@onready var collision: CollisionShape2D = $Collision

# Atributos de jogo
var points: int
var lifes: int = 3
var power_up: bool = false
var speed_up: bool = false
var shield: bool = false

# Velocidade de Movimento e Pulo
@export var speed: float = 100.0
@export var speed_scale: Vector2 = Vector2.ONE
@export var jump_intencity: float = 360.0
@export var knockback_intensity: float = 200.0

# Eixo de Direção e Disparo
var direction: Vector2
var shoot_dir: Vector2 = Vector2.ZERO

# Tempos de disparo
@export var normal_shoot_time: float = 0.2
@export var speed_shoot_time: float = 0.1
var shoot_cooldown: float = 0.0
@onready var speed_up_timer: Timer = $SpeedUpTimer

# Altura e velocidade de queda
var height: float = 0.0
var height_speed: float = 0.0
@export var dead_height: float = 200.0

# Buffer do pulo e disponibilidade
var jump_buffer: bool = false
var jump_available: bool = true

# Nodos de Sprites e Animação
@onready var sprite_container: Node2D = $SpriteContainer
@onready var animation_player: AnimationPlayer = $AnimationPlayer

# Timer do Buffer de Pulo
@onready var jump_buffer_timer: Timer = $JumpBufferTimer
@onready var jump_height_timer: Timer = $JumpHeightTimer

# Nodos referentes a disparo
@export var proj_scene: PackedScene
@onready var left_muzzle: Marker2D = $MuzzleContainer/LeftMuzzle
@onready var right_muzzle: Marker2D = $MuzzleContainer/RightMuzzle

# Nodos do texto de item coletado
@export var text_scene: PackedScene

# Sinais
signal change_points(points: int)
signal spawn_item_text(text: ItemText)
signal spawn_projectile(proj: PlayerProjectile)


### FUNÇÃO PRINCIPAL
func _physics_process(delta: float) -> void:
	handle_input()
	handle_movement(delta)
	handle_jump(delta)
	handle_shoot(delta)
	if_no_health()
	if_hurt()
	handle_animation()
	print(global_position)


### HANDLE
# Comandos
func handle_input() -> void:
	if state in [State.HURT, State.DEAD]:
		return
	
	# Direções
	direction = Input.get_vector(
		"Press_Left",
		"Press_Right",
		"Press_Up",
		"Press_Down"
	)
	
	# Pulo
	if Input.is_action_just_pressed("Press_Jump"):
		if jump_available:
			jump_height_timer.start()
			jump_action()
		else:
			jump_buffer = true
			jump_buffer_timer.start()
			
	
	# Disparo
	shoot_dir.x = Input.get_axis("Press_Shoot_Left", "Press_Shoot_Right")

# Movimentação
func handle_movement(_delta: float) -> void:
	if direction:
		velocity = direction * speed * speed_scale
	elif state not in [State.HURT, State.DEAD]:
		velocity = velocity.move_toward(Vector2.ZERO, speed)
	
	move_and_slide()

# Pulo
func handle_jump(delta: float) -> void:	
	height += height_speed * delta
	height_speed -= GRAVITY * delta
	if height <= 0.0:
		height = 0.0
		height_speed = 0.0
		
		if jump_buffer:
			jump_action()
			jump_buffer = false
			jump_buffer_timer.stop()
		else:
			jump_available = true
	
	sprite_container.position.y = -height
	
	if state in [State.HURT, State.DEAD]:
		return
	
	if height == 0.0:
		set_collision_mask_value(3, true)
		set_collision_mask_value(5, true)
		state = State.IDLE
	else:
		set_collision_mask_value(3, false)
		set_collision_mask_value(5, false)
		state = State.JUMP

func handle_animation() -> void:
	var animation_name: String = anim_map[state]
	
	if animation_player.current_animation != animation_name:
		animation_player.play(animation_name)

# Disparo
func handle_shoot(delta: float) -> void:
	shoot_cooldown = maxf(shoot_cooldown - delta, 0.0)
	
	if shoot_dir == Vector2.ZERO:
		return
	
	if shoot_dir == Vector2.LEFT:
		if state == State.IDLE:
			state = State.FIRE_LEFT
		elif state == State.JUMP:
			state = State.JUMP_F_LEFT
	
	elif shoot_dir == Vector2.RIGHT:
		if state == State.IDLE:
			state = State.FIRE_RIGHT
		elif state == State.JUMP:
			state = State.JUMP_F_RIGHT
	
	if shoot_cooldown == 0.0:
		# Cooldowns diferentes dependendo do speed_up
		if speed_up:
			shoot_cooldown = speed_shoot_time
		else:
			shoot_cooldown = normal_shoot_time
		
		action_fire()

func if_no_health() -> void:
	if state == State.DEAD:
		if height <= 0.0:
			handle_dead()

# Medida temporária até resolver como trocar de estado ao encostar no chão
func if_hurt() -> void:
	if state == State.HURT and height <= 0.0:
		state = State.IDLE

func handle_dead() -> void:
	world.exit_game()

### AÇÕES
func jump_action() -> void:
	height_speed = jump_intencity
	shoot_cooldown /= 2
	jump_available = false

func action_fire() -> void:
	var new_proj: Node2D = proj_scene.instantiate()
	
	new_proj.direction = shoot_dir
	new_proj.height = height + new_proj.base_height
	
	if new_proj.direction == Vector2.LEFT:
		new_proj.global_position = left_muzzle.global_position
	else:
		new_proj.global_position = right_muzzle.global_position
	
	new_proj.is_powered = power_up
	
	emit_signal("spawn_projectile", new_proj)


### CONDIÇÕES
func is_firing() -> bool:
	return (
		state == State.FIRE_LEFT or
		state == State.FIRE_RIGHT or
		state == State.JUMP_F_LEFT or
		state == State.JUMP_F_RIGHT
	)

### ITENS
func item_points(pts: int) -> void:
	## Tocar som
	prepare_item_text(str(pts))
	add_points(pts)

func item_power_up() -> void:
	## Tocar som
	
	prepare_item_text("POWER UP")
	power_up = true
	
	add_points(200)

func item_speed_up() -> void:
	## Tocar som
	
	prepare_item_text("SPEED UP")
	speed_up = true
	
	speed_up_timer.start()
	
	add_points(200)

func shield_up() -> void:
	## Tocar som
	
	prepare_item_text("SHIELD UP")
	shield = true
	
	add_points(200)

func item_life_up() -> void:
	## Tocar som
	
	prepare_item_text("+1 LIFE")
	lifes += 1
	
	add_points(1000)

func add_points(pts: int) -> void:
	points += pts
	emit_signal("change_points", points)

func prepare_item_text(text: String) -> void:
	var new_text: ItemText = text_scene.instantiate()
	
	new_text.text = text
	new_text.global_position = global_position
	
	emit_signal("spawn_item_text", new_text)

func take_damage(dir: Vector2) -> void:
	height_speed += dead_height
	velocity = Vector2(dir.x * knockback_intensity, 0.0)
	
	if shield:
		shield = false
		state = State.HURT
		return
	
	print("You're dead!")
	state = State.DEAD
	collision.call_deferred("set_disabled", true)
	

### SINAIS
func _on_jump_buffer_timer_timeout() -> void:
	jump_buffer = false

func _on_jump_height_timer_timeout() -> void:
	if !Input.is_action_pressed("Press_Jump"):
		if height_speed > 100.0:
			height_speed *= 0.5
	else:
		pass

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name in [
		"fire_left",
		"fire_right",
		"jump_f_left",
		"jump_f_right",
	]:
		if height == 0.0:
			state = State.IDLE
		else:
			state = State.JUMP

func _on_speed_up_timer_timeout() -> void:
	speed_up = false
