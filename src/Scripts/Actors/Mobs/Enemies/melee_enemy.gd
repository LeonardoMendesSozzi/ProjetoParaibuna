extends BaseEnemy
class_name MeleeEnemy


### STATE MACHINE
enum State {
	IDLE,
	WALK,
	AIM,
	ATTACK,
	DEAD
}

var state: State = State.IDLE

### Animation Map
var anim_map: Dictionary={
	State.IDLE: "idle",
	State.WALK: "walk",
	State.AIM: "aim",
	State.ATTACK:"attack",
	State.DEAD: "dead"
}


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	handle_input()
	handle_aim()
	handle_direction()
	handle_attack()
	handle_movement(delta)
	if_no_health()
	handle_animation()

func handle_input() -> void:
	if state == State.DEAD:
		return
	
	if state not in [State.IDLE, State.WALK]:
		velocity = Vector2.ZERO
		return
	
	var self_pos: Vector2 = global_position
	var player_pos: Vector2 = player.global_position
	target_dir = (player_pos - self_pos).normalized()
	
	velocity = target_dir * speed * speed_scale

func handle_aim() -> void:
	if state in [State.AIM, State.ATTACK, State.DEAD]:
		return
	
	if player_at_range:
		state = State.AIM
		attack_cooldown.start()

func handle_movement(delta: float) -> void:
	height += height_velocity * delta
	
	sprite_container.position.y = -height
	
	if not is_flying: height_velocity -= GRAVITY * delta
	
	if height <= 0.0:
		height_velocity = 0.0
	
	if state in [State.IDLE, State.WALK]:
		if velocity == Vector2.ZERO:
			state = State.IDLE
		else:
			state = State.WALK
	elif state in [State.AIM]:
		velocity = Vector2.ZERO
	
	if attack_velocity != Vector2.ZERO:
		velocity = attack_velocity
		
		attack_velocity = attack_velocity.move_toward(Vector2.ZERO, 4 * attack_intensity * delta)
	
	move_and_slide()

func handle_direction() -> void:
	if state == State.ATTACK:
		return
	
	if target_dir.x > 0:
		sprite.flip_h = false
		face_dir = Vector2.RIGHT
	else:
		face_dir = Vector2.LEFT
		sprite.flip_h = true

func handle_attack() -> void:
	if not ready_to_attack:
		return
	
	state = State.ATTACK
	ready_to_attack = false
	
	if face_dir == Vector2.LEFT:
		attack_area_left.monitoring = true
	else:
		attack_area_right.monitoring = true
	
	attack_velocity = target_dir * attack_intensity

func handle_animation() -> void:
	if animation_player.has_animation(anim_map[state]):
		animation_player.play(anim_map[state])

### Quando finalizar a animação de ataque
func on_attack_finished() -> void:
	state = State.IDLE
	
	# Garante que as áres desativem mesmo tendo que haja isso no AnimationPlayer
	attack_area_left.monitoring = false
	attack_area_right.monitoring = false

### Função de Dano
func take_damage(dmg: int, dir: Vector2) -> void:
	health -= dmg

	if health <= 0:
		attack_cooldown.stop()
		state = State.DEAD
		collision.call_deferred("set_disabled", true)
		
		height_velocity += dead_intensity
		velocity = Vector2(dir.x * knockback_intensity, 0.0)

func if_no_health() -> void:
	if health <= 0:
		is_flying = false
		
		if height <= 0.0:
			handle_dead()

func handle_dead() -> void:
	## TODO Fazer a alteração dos pontos de forma mais indireta
	player.add_points(400)
	queue_free()

### Sinais do Target Area
func _on_target_area_area_entered(area: Area2D) -> void:
	if area.is_in_group("Player"):
		player_at_range = true

func _on_target_area_area_exited(area: Area2D) -> void:
	if area.is_in_group("Player"):
		player_at_range = false

### Areas de Dano
func _on_attack_area_left_area_entered(area: Area2D) -> void:
	if area.is_in_group("Player"):
		player.take_damage(Vector2.LEFT)
	
func _on_attack_area_right_area_entered(area: Area2D) -> void:
	if area.is_in_group("Player"):
		player.take_damage(Vector2.RIGHT)

### Sinais do Timer
func _on_attack_cooldown_timeout() -> void:
	ready_to_attack = true
