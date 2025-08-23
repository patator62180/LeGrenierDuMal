@tool
class_name ImpactRegion
extends Area3D

@export var _material: ImpactMaterial:
    set(material):
        if material != _material:
            _material = material
            update_configuration_warnings()

@onready var _collision_shapes: Array[CollisionShape3D] = _get_collision_shapes()

func _get_collision_shapes() -> Array[CollisionShape3D]:
    var collision_shapes: Array[CollisionShape3D]
    
    for child in get_children():
        if is_instance_of(child, CollisionShape3D):
            collision_shapes.push_back(child)
    
    return collision_shapes
    
func _get_configuration_warnings():
    var warnings = []

    if _material == null:
        warnings.append("Assign a material")

    return warnings

func _contains_point(impact_point: ImpactPoint):
    for area in get_overlapping_areas():
        if area == impact_point:
            return true
    
    return false

func handle_impact(audio_stream_player: AudioStreamPlayer3D, pitch_effect: AudioEffectPitchShift, velocity_ratio: float, impact_point: ImpactPoint):
    if _contains_point(impact_point):
        audio_stream_player.volume_linear = min(velocity_ratio, 1)
        pitch_effect.pitch_scale = randf_range(_material.min_random_pitch, _material.max_random_pitch) if _material.random_pitch_variations else 1
        audio_stream_player.stream = _material.impact_sounds[randi_range(0, _material.impact_sounds.size() - 1)]
        audio_stream_player.play()
        
        return true
    
    return false
