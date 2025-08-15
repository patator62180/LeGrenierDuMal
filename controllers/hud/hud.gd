extends Control

@onready var _sound_gauge_value: ColorRect = $SoundGauge/Value
@onready var _animation_player: AnimationPlayer = $AnimationPlayer

func _ready():
    Game.Controller.instance.cumulated_sound_changed.connect(_on_cumulated_sound_changed)
    Game.Controller.instance.loading_completed.connect(_on_loading_complete)
    _animation_player.play("loading")

func _on_loading_complete():
    _animation_player.play("close_loading")

func _on_cumulated_sound_changed(sound: float):
    _sound_gauge_value.scale.x = min(Game.MAX_SOUND_VALUE, sound) / Game.MAX_SOUND_VALUE
