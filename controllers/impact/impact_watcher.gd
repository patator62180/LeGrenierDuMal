extends Node3D

var _rigid_body: RigidBody3D

func _ready():
    var parent = get_parent()
    
    if parent != null and is_instance_of(parent, RigidBody3D):
        _rigid_body = parent
    
    if _rigid_body == null:
        printerr("ImpactWatcher is deactivated because it's not under a rigid body")
        set_process(false)
        set_physics_process(false)
    else:
        _rigid_body.body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node):
    Game.Controller.instance.add_impact(_rigid_body.mass, _rigid_body.linear_velocity.length(), 0.5)
