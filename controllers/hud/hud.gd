extends Control

@onready var _sound_value = $Sound/Value

func _ready():
    _sound_value.text = str(0)
    Game.Controller.instance.cumulated_sound_changed.connect(_on_cumulated_sound_changed)

func _on_cumulated_sound_changed(sound: float):
    _sound_value.text = str(floor(sound))
