extends ColorRect

const MAX_VALUE: float = 0.06
const COOLDOWN_VELOCITY: float = 0.5

@export var _min_frequency: float
@export var _max_frequency: float

@onready var _spectrum_analyzer: AudioEffectSpectrumAnalyzerInstance = AudioServer.get_bus_effect_instance(AudioServer.get_bus_index("Impacts"), 0)
@onready var _value: ColorRect = $Value

func _ready():
    _value.scale.y = 0

func _process(delta):
    var magnitude = _spectrum_analyzer.get_magnitude_for_frequency_range(_min_frequency, _max_frequency).length()
    var value = min(magnitude / MAX_VALUE, 1)
    
    if _value.scale.y < value:
        _value.scale.y = value
    else:
        var diff = COOLDOWN_VELOCITY * delta
        _value.scale.y = (_value.scale.y - diff) if diff < _value.scale.y else 0
