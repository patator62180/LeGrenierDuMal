extends Node3D

@export var _audio_curve: AudioCurve

@onready var _audio_stream_player : AudioStreamPlayer3D = $AudioStreamPlayer3D

const TIME_BETWEEN_IMPACTS: float = 0.3

var _rigid_body: RigidBodish
var _last_impact_rel_time: float = 0

func _ready():
    var parent = get_parent()
    
    if is_instance_of(parent, RigidBodish):
        _rigid_body = parent
    
    if _rigid_body == null:
        printerr("%s: ImpactWatcher parent is not a RigidBodish" % parent.name)
        set_process(false)
        set_physics_process(false)

    if _audio_curve == null:
        printerr("%s: ImpactWatcher has no AudioCurve" % parent.name)
        set_process(false)
        set_physics_process(false)
    else:
        _audio_stream_player.stream = _audio_curve.stream
    
    if _rigid_body != null and _audio_curve != null:
        _rigid_body.contact_monitor = true
        _rigid_body.max_contacts_reported = 20
        _rigid_body.contact_occured.connect(_on_contact_occured)

func _on_contact_occured(velocity: Vector3):
    if _last_impact_rel_time >= TIME_BETWEEN_IMPACTS:
        Game.Controller.instance.add_impact(_audio_curve.curve, velocity.length(), _rigid_body.mass, _audio_stream_player)
        _audio_stream_player.play();
        _last_impact_rel_time = 0

func _process(delta):
    _last_impact_rel_time += delta
