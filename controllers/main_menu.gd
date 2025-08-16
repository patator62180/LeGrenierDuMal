extends Control

@onready var _button : Button = $Button

func _ready() -> void:
    _button.pressed.connect(start_game)

func start_game():
    get_tree().change_scene_to_file("res://main.tscn")
