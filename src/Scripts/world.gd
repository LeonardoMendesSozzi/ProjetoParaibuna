extends Node2D
class_name WorldScene

var difficulty: float = 0.0
var spawn_dir: Vector2 = Vector2.LEFT

### Cenas do Player
@export var player_scene: PackedScene
var player: Player

### Cenas da PlayerCamera
@export var camera_scene: PackedScene
var camera: PlayerCamera

### Cenas de Inimigos
@export var melee_scene: PackedScene

### Cenas de Itens
@export var prop_scene: PackedScene
var item_array: Array[ItemStats] = [
	null,
	preload("res://Resources/Items/orange.tres"),
	preload("res://Resources/Items/juice.tres"),
	preload("res://Resources/Items/soda.tres"),
	preload("res://Resources/Items/cake.tres"),
	preload("res://Resources/Items/speed.tres"),
	preload("res://Resources/Items/shield.tres"),
	preload("res://Resources/Items/power.tres"),
	preload("res://Resources/Items/life.tres")
]
var item_weights: Array[int] = [10,20,15,10,5,15,10,10,5]
var item_rng = RandomNumberGenerator.new()

# Outras cenas
@onready var actors_container: Node2D = $ActorsContainer
@onready var game_hud: GameHUD = $Game_HUD


func _ready() -> void:
	spawn_player()
	spawn_camera()
	for i in 2:
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
	
	difficulty += 0.20
	
	# Spawn ds primeiros inimigos
	for i: int in 1 + int(difficulty):
		var new_enemy: MeleeEnemy = melee_scene.instantiate()
		
		new_enemy.global_position = Vector2(200.0 * spawn_dir.x,randf_range(0.0, 80.0))
		new_enemy.world = self
		new_enemy.player = player
		new_enemy.connect("spawn_melee_enemy", spawn_enemies)
		
		actors_container.add_child(new_enemy)
		
		spawn_dir.x *= (-1)

func get_item() -> ItemStats:
	var item := item_rng.rand_weighted(item_weights)
	return item_array[item]

func exit_game() -> void:
	get_tree().change_scene_to_file("res://Scenes/Interface/main_menu.tscn")

func player_change_points(points: int) -> void:
	game_hud.change_points(points)

func player_spawn_text(text: ItemText) -> void:
	actors_container.add_child(text)

func player_spawn_projectile(proj: PlayerProjectile) -> void:
	actors_container.add_child(proj)

### Sinais
func _on_item_spawner_timeout() -> void:
	if prop_scene == null:
		return
	
	var new_prop: Prop = prop_scene.instantiate()
	
	new_prop.global_position = Vector2(240.0, randf_range(10.0, 70.0))
	new_prop.item_stats = get_item()
	
	actors_container.add_child(new_prop)
