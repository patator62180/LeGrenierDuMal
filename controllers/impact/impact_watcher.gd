class_name ImpactWatcher
extends Node3D

@export_group("Sounds")
@export var _impact_sounds: Array[AudioStream]

@export_group("Pitch")
@export var _random_pitch_variations: bool = false
@export var _min_random_pitch: float = 1
@export var _max_random_pitch: float = 1

@onready var _audio_stream_player : AudioStreamPlayer3D = $AudioStreamPlayer3D



const AUDIO_BUS_COUNT: int = 20
const TIME_BETWEEN_IMPACTS: float = 0.3
const IMPACTS_BUS_NAME = "Impacts"

class AudioBusHandle:
    const EXPIRATION_DURATION: float = 1
    
    var _time_since_impact: float
    var _pitch_shift: AudioEffectPitchShift
    var _bus_name: StringName
    var _impact_watcher: ImpactWatcher

    var expired: bool:
        get: return _time_since_impact >= EXPIRATION_DURATION

    var bus_name: StringName:
        get: return _bus_name

    func _init(bus_idx: int, impact_watcher: ImpactWatcher):
        _pitch_shift = AudioServer.get_bus_effect(bus_idx, 0)
        _bus_name = AudioServer.get_bus_name(bus_idx)
        _impact_watcher = impact_watcher

    func update(delta: float):
        _time_since_impact += delta
    
    func handle_impact():
        _pitch_shift.pitch_scale = _impact_watcher.get_pitch_scale()
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

static func _allocate_audio_bus(impact_watcher: ImpactWatcher):
    for bus_idx in range(_initial_bus_count, AUDIO_BUS_COUNT + _initial_bus_count):
        if _audio_bus_handles[bus_idx] == null or _audio_bus_handles[bus_idx].expired:
            _audio_bus_handles[bus_idx] = AudioBusHandle.new(bus_idx, impact_watcher)
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

    if _impact_sounds.size() == 0:
        printerr("%s: ImpactWatcher has no AudioStream" % parent.name)
        set_process(false)
        set_physics_process(false)
    
    if _rigid_body != null and _impact_sounds.size() > 0:
        _rigid_body.contact_monitor = true
        _rigid_body.max_contacts_reported = 20
        _rigid_body.contact_occured.connect(_on_contact_occured)

func _on_contact_occured(impact_strengh: float):
    if _audio_bus_handle == null or _audio_bus_handle.expired:
        _audio_bus_handle = _allocate_audio_bus(self)
        
        if _audio_bus_handle != null:
            _audio_stream_player.bus = _audio_bus_handle.bus_name

    if _audio_bus_handle != null:
        var velocity_ratio = remap(impact_strengh, Game.MIN_VELOCITY, Game.MAX_VELOCITY, 0, 1)
        
        _audio_stream_player.volume_linear = min(velocity_ratio, 1)
        _audio_bus_handle.handle_impact()
        _audio_stream_player.stream = _impact_sounds[randi_range(0, _impact_sounds.size() - 1)]
        _audio_stream_player.play();
    else:
        printerr("Not enough AudioBus available to allocate for impact")

func get_pitch_scale():
    return randf_range(_min_random_pitch, _max_random_pitch) if _random_pitch_variations else 1
