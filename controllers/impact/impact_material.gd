class_name ImpactMaterial
extends Resource

@export_group("Sounds")
@export var impact_sounds: Array[AudioStream]

@export_group("Pitch")
@export var random_pitch_variations: bool = false
@export var min_random_pitch: float = 1
@export var max_random_pitch: float = 1
