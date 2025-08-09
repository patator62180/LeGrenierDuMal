extends Control

const MAX_SOUND_VALUE: float = 1.25

@onready var _sound_gauge_value: ColorRect = $SoundGauge/Value

func _ready():
    Game.Controller.instance.cumulated_sound_changed.connect(_on_cumulated_sound_changed)

func _on_cumulated_sound_changed(sound: float):
    _sound_gauge_value.scale.x = min(MAX_SOUND_VALUE, sound) / MAX_SOUND_VALUE
