extends Area3D

func _ready():
    body_entered.connect(on_body_entered)
    
func on_body_entered(body : Node3D):
    if body.name == "Character":
        Game.Controller.instance.escape_triggered.emit()
