class_name HUD
extends Control

@onready var _sound_gauge: SoundGauge = $SoundGauge
@onready var _animation_player: AnimationPlayer = $AnimationPlayer
@onready var _vignette : CanvasItem = $Vignette
@onready var _game_win_timer: Label = $GameWin/Timer

func _ready():
    Game.Controller.instance.cumulated_sound_changed.connect(_on_cumulated_sound_changed)
    Game.Controller.instance.loading_completed.connect(_on_loading_complete)
    Game.Controller.instance.death_triggered.connect(_on_death)
    Game.Controller.instance.escape_triggered.connect(_on_escape)
    Game.Controller.instance.time_updated.connect(_on_time_updated)
    _animation_player.animation_finished.connect(_on_animation_finished)
    _animation_player.play("loading")

static func seconds2hhmmss(total_seconds: float) -> String:
    var seconds:float = fmod(total_seconds , 60.0)
    var minutes:int = int(total_seconds / 60.0) % 60
    var hours: int = int(total_seconds / 3600.0)

    return "%02d:%02d:%05.2f" % [hours, minutes, seconds]

func _on_time_updated(time: float):
    var formatted_time = seconds2hhmmss(time)
    _game_win_timer.text = formatted_time

func _on_loading_complete():
    _animation_player.play("close_loading")

func _on_cumulated_sound_changed(sound: float):
    var relative_sound = min(Game.MAX_SOUND_VALUE, sound) / Game.MAX_SOUND_VALUE
    _sound_gauge.value = relative_sound
    _vignette.material.set_shader_parameter("inner_radius", 1.0-relative_sound)

func _on_death():
    _animation_player.play("death")

func _on_escape():
    _animation_player.play("escape")
    
func _on_animation_finished(animation_name : StringName):
    if animation_name == "death" or animation_name == "escape":
        get_tree().change_scene_to_file("res://menus/main_menu.tscn")
        
