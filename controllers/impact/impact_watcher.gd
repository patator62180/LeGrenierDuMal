extends Node3D

@export var _curve: Curve

var _rigid_body: RigidBody3D

func _ready():
    var parent = get_parent()
    
    if parent != null and is_instance_of(parent, RigidBody3D):
        _rigid_body = parent
    
    if _rigid_body == null:
        printerr("ImpactWatcher is deactivated because it's not under a rigid body")
        set_process(false)
        set_physics_process(false)

    if _curve == null:
        printerr("ImpactWatcher is deactivated because curve hasn't been set")
        set_process(false)
        set_physics_process(false)
    
    if _rigid_body != null and _curve != null:
        _rigid_body.body_entered.connect(_on_body_entered)
        _rigid_body.contact_monitor = true
        _rigid_body.max_contacts_reported = 5

func _on_body_entered(body: Node):
    Game.Controller.instance.add_impact(_curve, _rigid_body.linear_velocity.length())
