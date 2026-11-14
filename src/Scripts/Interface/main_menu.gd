extends Control

@onready var score: Label = $Score

func _ready() -> void:
	score.text = "HIGHEST SCORE: " + str(Global.high_score)

func _on_start_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/world.tscn")

func _on_options_pressed() -> void:
	if Global.full_screen:
		Global.full_screen = false
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	else:
		Global.full_screen = true
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)

func _on_exit_pressed() -> void:
	get_tree().quit()
