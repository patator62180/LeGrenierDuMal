extends AnimationPlayer


func _ready() -> void:
    Game.Controller.instance.death_triggered.connect(play)
