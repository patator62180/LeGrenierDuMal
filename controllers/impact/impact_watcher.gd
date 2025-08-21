extends Node3D

@export var _audio_stream: AudioStream

@onready var _audio_stream_player : AudioStreamPlayer3D = $AudioStreamPlayer3D

const AUDIO_BUS_COUNT: int = 20
const TIME_BETWEEN_IMPACTS: float = 0.3
const IMPACTS_BUS_NAME = "Impacts"

class AudioBusHandle:
    const EXPIRATION_DURATION: float = 1
    
    var _time_since_impact: float
    var _pitch_shift: AudioEffectPitchShift
    var _bus_name: StringName

    var expired: bool:
        get: return _time_since_impact >= EXPIRATION_DURATION

    var bus_name: StringName:
        get: return _bus_name

    func _init(bus_idx: int):
        _pitch_shift = AudioServer.get_bus_effect(bus_idx, 0)
        _bus_name = AudioServer.get_bus_name(bus_idx)

    func update(delta: float):
        _time_since_impact += delta
    
    func handle_impact():
        _pitch_shift.pitch_scale = randf_range(0.9, 1.1)
        _time_since_impact = 0


var _rigid_body: RigidBodish
var _last_impact_rel_time: float = 0
var _audio_bus_handle: AudioBusHandle

static var _audio_server_initialized: bool = false
static var _audio_bus_handles: Dictionary[int, AudioBusHandle] = {}
static var _initial_bus_count: int

@onready var _spectrum_analyzer: AudioEffectSpectrumAnalyzerInstance = AudioServer.get_bus_effect_instance(AudioServer.get_bus_index(IMPACTS_BUS_NAME), 0)

static func _initialize_audio_server():
    if not _audio_server_initialized:
        _initial_bus_count = AudioServer.bus_count
        
        for bus_idx in range(_initial_bus_count, AUDIO_BUS_COUNT + _initial_bus_count):
            AudioServer.add_bus(bus_idx)
            AudioServer.add_bus_effect(bus_idx, AudioEffectPitchShift.new())
            AudioServer.set_bus_send(bus_idx, IMPACTS_BUS_NAME)
            AudioServer.set_bus_name(bus_idx, "Impact %d" % bus_idx)
            _audio_bus_handles[bus_idx] = null

        _audio_server_initialized = true

static func _allocate_audio_bus():
    for bus_idx in range(_initial_bus_count, AUDIO_BUS_COUNT + _initial_bus_count):
        if _audio_bus_handles[bus_idx] == null or _audio_bus_handles[bus_idx].expired:
            _audio_bus_handles[bus_idx] = AudioBusHandle.new(bus_idx)
            return _audio_bus_handles[bus_idx]


func _ready():
    _initialize_audio_server()
    var parent = get_parent()
    
    if is_instance_of(parent, RigidBodish):
        _rigid_body = parent
    
    if _rigid_body == null:
        printerr("%s: ImpactWatcher parent is not a RigidBodish" % parent.name)
        set_process(false)
        set_physics_process(false)

    if _audio_stream == null:
        printerr("%s: ImpactWatcher has no AudioStream" % parent.name)
        set_process(false)
        set_physics_process(false)
    else:
        _audio_stream_player.stream = _audio_stream
    
    if _rigid_body != null and _audio_stream != null:
        _rigid_body.contact_monitor = true
        _rigid_body.max_contacts_reported = 20
        _rigid_body.contact_occured.connect(_on_contact_occured)

func _on_contact_occured(impact_strengh: float):
    if _audio_bus_handle == null or _audio_bus_handle.expired:
        _audio_bus_handle = _allocate_audio_bus()
        
        if _audio_bus_handle != null:
            _audio_stream_player.bus = _audio_bus_handle.bus_name

    if _audio_bus_handle != null:
        var velocity_ratio = remap(impact_strengh, Game.MIN_VELOCITY, Game.MAX_VELOCITY, 0, 1)
        
        _audio_stream_player.volume_linear = min(velocity_ratio, 1)
        _audio_bus_handle.handle_impact()
        _audio_stream_player.play();
    else:
        printerr("Not enough AudioBus available to allocate for impact")
