extends Control

@onready var _sound_gauge_value: ColorRect = $SoundGauge/Value

func _ready():
    Game.Controller.instance.cumulated_sound_changed.connect(_on_cumulated_sound_changed)

func _on_cumulated_sound_changed(sound: float):
    _sound_gauge_value.scale.x = min(Game.MAX_SOUND_VALUE, sound) / Game.MAX_SOUND_VALUE
