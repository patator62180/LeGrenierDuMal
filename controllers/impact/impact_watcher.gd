extends Node3D

@export var _audio_curve: AudioCurve

@onready var _audio_stream_player : AudioStreamPlayer3D = $AudioStreamPlayer3D

var _rigid_body: RigidBody3D

func _ready():
    var parent = get_parent()
    
    if parent != null and is_instance_of(parent, RigidBody3D):
        _rigid_body = parent
    
    if _rigid_body == null:
        printerr("ImpactWatcher is deactivated because it's not under a rigid body")
        set_process(false)
        set_physics_process(false)

    if _audio_curve == null:
        printerr("ImpactWatcher is deactivated because curve hasn't been set")
        set_process(false)
        set_physics_process(false)
    else:
        _audio_stream_player.stream = _audio_curve.stream
    
    if _rigid_body != null and _audio_curve != null:
        _rigid_body.body_entered.connect(_on_body_entered)
        _rigid_body.contact_monitor = true
        _rigid_body.max_contacts_reported = 5

func _on_body_entered(body: Node):
    var velocity = _rigid_body.linear_velocity.length()
    Game.Controller.instance.add_impact(_audio_curve.curve, velocity, _rigid_body.mass, _audio_stream_player)
    _audio_stream_player.play();
