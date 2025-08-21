extends HBoxContainer

@export var _min_frequency: float
@export var _max_frequency: float

@onready var _spectrum_analyzer: AudioEffectSpectrumAnalyzerInstance = AudioServer.get_bus_effect_instance(AudioServer.get_bus_index("Impacts"), 0)
@onready var _value: Label = $Value

func _process(delta):
    _value.text = str(_spectrum_analyzer.get_magnitude_for_frequency_range(_min_frequency, _max_frequency).length())
