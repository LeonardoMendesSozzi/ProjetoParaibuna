extends Node2D
class_name WorldScene

### Cenas do Player
@export var player_scene: PackedScene
var player: Player

### Cenas da PlayerCamera
@export var camera_scene: PackedScene
var camera: PlayerCamera

### Inimigos
@export var melee_scene: PackedScene

# Outras cenas
@onready var actors_container: Node2D = $ActorsContainer
@onready var game_hud: GameHUD = $Game_HUD


func _ready() -> void:
	spawn_player()
	spawn_camera()
	spawn_enemies()
	## TODO Uma forma de spawnar hordas de inimigos e objetos de forma estruturada


func spawn_player() -> void:
	if player_scene == null:
		print("Erro, cena do jogador não definida!")
		return
	
	player = player_scene.instantiate()
	
	player.connect("change_points", player_change_points)
	player.connect("spawn_item_text", player_spawn_text)
	player.connect("spawn_projectile", player_spawn_projectile)
	player.world = self
	player.global_position = Vector2(0.0, 40.0)
	print(player.global_position)
	
	actors_container.add_child(player)

func spawn_camera() -> void:
	if camera_scene == null:
		print("Erro, cena da camera não definida!")
		return
	
	camera = camera_scene.instantiate()
	
	camera.player = player
	
	add_child(camera)

func spawn_enemies() -> void:
	if melee_scene == null:
		print("Erro, cena com inimigos não definida!")
		return
	
	return
	
	for i: int in 5:
		var new_enemy: MeleeEnemy = melee_scene.instantiate()
		
		new_enemy.global_position = Vector2(randf_range(0, 300), randf_range(0, 80))
		
		new_enemy.world = self
		new_enemy.player = player

		actors_container.add_child(new_enemy)
	
	for i: int in 5:
		var new_enemy: MeleeEnemy = melee_scene.instantiate()
		
		new_enemy.global_position = Vector2(randf_range(500, 800), randf_range(0, 80))
		
		new_enemy.world = self
		new_enemy.player = player

		actors_container.add_child(new_enemy)

func exit_game() -> void:
	get_tree().change_scene_to_file("res://Scenes/Interface/main_menu.tscn")

func player_change_points(points: int) -> void:
	game_hud.change_points(points)

func player_spawn_text(text: ItemText) -> void:
	actors_container.add_child(text)

func player_spawn_projectile(proj: PlayerProjectile) -> void:
	actors_container.add_child(proj)
