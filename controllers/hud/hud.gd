extends Control

@onready var _sound_gauge_value: ColorRect = $SoundGauge/Value
@onready var _animation_player: AnimationPlayer = $AnimationPlayer
@onready var _vignette : CanvasItem = $Vignette

func _ready():
    Game.Controller.instance.cumulated_sound_changed.connect(_on_cumulated_sound_changed)
    Game.Controller.instance.loading_completed.connect(_on_loading_complete)
    Game.Controller.instance.death_triggered.connect(_on_death)
    Game.Controller.instance.escape_triggered.connect(_on_escape)
    _animation_player.animation_finished.connect(_on_animation_finished)
    _animation_player.play("loading")

func _on_loading_complete():
    _animation_player.play("close_loading")

func _on_cumulated_sound_changed(sound: float):
    var relative_sound = min(Game.MAX_SOUND_VALUE, sound) / Game.MAX_SOUND_VALUE
    _sound_gauge_value.scale.x = relative_sound
    _vignette.material.set_shader_parameter("inner_radius", 1.0-relative_sound)

func _on_death():
    _animation_player.play("death")

func _on_escape():
    _animation_player.play("escape")
    
func _on_animation_finished(animation_name : StringName):
    if animation_name == "death" or animation_name == "escape":
        get_tree().change_scene_to_file("res://menus/main_menu.tscn")
        
