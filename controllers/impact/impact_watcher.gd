@tool
class_name ImpactWatcher
extends Node3D

@onready var _audio_stream_player : AudioStreamPlayer3D = $AudioStreamPlayer3D
@onready var _regions: Array[ImpactRegion] = _get_regions()

const AUDIO_BUS_COUNT: int = 20
const IMPACTS_BUS_NAME = "Impacts"

class AudioBusHandle:
    const EXPIRATION_DURATION: float = 1
    
    var _time_since_impact: float
    var _pitch_effect: AudioEffectPitchShift
    var _bus_name: StringName
    var _impact_watcher: ImpactWatcher
    
    var pitch_effect: AudioEffectPitchShift:
        get: return _pitch_effect

    var expired: bool:
        get: return _time_since_impact >= EXPIRATION_DURATION

    var bus_name: StringName:
        get: return _bus_name

    func _init(bus_idx: int, impact_watcher: ImpactWatcher):
        _pitch_effect = AudioServer.get_bus_effect(bus_idx, 0)
        _bus_name = AudioServer.get_bus_name(bus_idx)
        _impact_watcher = impact_watcher

    func update(delta: float):
        _time_since_impact += delta

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

    if _regions.size() == 0:
        printerr("%s: ImpactWatcher has no ImpactRegion" % parent.name)
        set_process(false)
        set_physics_process(false)
    
    if _rigid_body != null and _regions.size() > 0:
        _rigid_body.contact_occured.connect(_on_contact_occured)

func _on_contact_occured(impact_point: ImpactPoint, impact_strengh: float):
    if _audio_bus_handle == null or _audio_bus_handle.expired:
        _audio_bus_handle = _allocate_audio_bus(self)
        
        if _audio_bus_handle != null:
            _audio_stream_player.bus = _audio_bus_handle.bus_name

    if _audio_bus_handle != null:
        var velocity_ratio = remap(impact_strengh, Game.MIN_VELOCITY, Game.MAX_VELOCITY, 0, 1)
        
        _handle_impact(impact_point, velocity_ratio)
    else:
        printerr("Not enough AudioBus available to allocate for impact")

func _get_regions() -> Array[ImpactRegion]:
    var regions: Array[ImpactRegion] = []
    
    for child in get_children():
        if is_instance_of(child, ImpactRegion):
            regions.push_back(child)
    
    return regions

func _get_configuration_warnings():
    var warnings = []
    var regions = _get_regions()

    if regions.size() == 0:
        warnings.append("Add at least one ImpactRegion")

    return warnings

func _handle_impact(impact_point: ImpactPoint, velocity_ratio: float):
    for region in _regions:
        if region.handle_impact(_audio_stream_player, _audio_bus_handle.pitch_effect, velocity_ratio, impact_point):
            break
