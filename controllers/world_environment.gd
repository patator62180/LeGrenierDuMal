extends WorldEnvironment

#func _ready():
    #Game.Controller.instance.cumulated_sound_changed.connect(_on_cumulated_sound_changed)
    #environment.volumetric_fog_emission_energy = 0
    #environment.volumetric_fog_density = 0
#
#func _on_cumulated_sound_changed(sound: float):
    #environment.volumetric_fog_emission_energy = remap(sound, 0, Game.MAX_SOUND_VALUE, 0, 1)
    #environment.volumetric_fog_density = remap(sound, 0, Game.MAX_SOUND_VALUE, 0.5, 1)
