extends Control

@onready var _button : Button = $TextureRect2/Button
@onready var _best_time: Control = $BestTime
@onready var _best_time_value: Label = $BestTime/Value

func _ready() -> void:
    Game.Controller.delete_instance()
    _button.pressed.connect(start_game)
    var game_save: GameSave.Content = GameSave.load()
    
    if game_save == null:
        _best_time.visible = false
    else:
        _best_time_value.text = HUD.seconds2hhmmss(game_save.best_time)

func start_game():
    get_tree().change_scene_to_file("res://main.tscn")
