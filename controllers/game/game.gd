class_name Game
extends Node3D

const MAX_VELOCITY: float = 3
const MIN_VELOCITY: float = 0.001

const MAX_SOUND_VALUE: float = 1.25
const HIGH_MASS: float = 30
const LOADING_PERIOD: float = 2
const LOADING_PERIOD_IMPACTS_THRESHOLD = 80

class Impact:
    var curve: Curve
    var velocity: float
    var time_left: float
    var mass: float
    var audio_player: AudioStreamPlayer3D
    
    func _init(curve: Curve, velocity: float, mass: float, audio_player: AudioStreamPlayer3D):
        self.curve = curve
        self.velocity = velocity
        self.time_left = 1
        self.mass = mass
        self.audio_player = audio_player

class Controller:
    #region singleton
    
    static var _instance: Controller
    static var instance: Controller:
        get:
            _instance = Controller.new() if _instance == null else _instance
            return _instance
    #endregion

    signal cumulated_sound_changed
    signal loading_completed
    
    var _impacts: Array[Impact] = []
    var _loading_period_finished: bool = false
    var _loading_period_counter: float = 0
    
    func add_impact(curve: Curve, velocity: float, mass: float, audio_player: AudioStreamPlayer3D):
        _impacts.push_back(Impact.new(curve, velocity, mass, audio_player))

    func update(delta: float):
        if not _loading_period_finished:
            if _impacts.size() <= LOADING_PERIOD_IMPACTS_THRESHOLD:
                _loading_period_counter += delta
                
                if _loading_period_counter >= LOADING_PERIOD:
                    _loading_period_finished = true
                    loading_completed.emit()
            else:
                _loading_period_counter = 0
        else:
            var cumulated_sound = 0
            
            for impact in _impacts:
                var velocity_ratio = (max(min(impact.velocity, MAX_VELOCITY), MIN_VELOCITY) - MIN_VELOCITY) / (MAX_VELOCITY - MIN_VELOCITY)
                var velocity_curve_sample = impact.curve.sample(1.0 - impact.time_left) * velocity_ratio
                
                impact.audio_player.volume_linear = remap(velocity_curve_sample, 0, 2, 0, 1)
                
                cumulated_sound += velocity_curve_sample * impact.mass / HIGH_MASS
                
            cumulated_sound_changed.emit(cumulated_sound)
            
        var new_impacts: Array[Impact] = []

        for impact in _impacts:
            impact.time_left -= delta

            if impact.time_left > 0:
                new_impacts.push_back(impact)

        _impacts = new_impacts

        


func _process(delta):
    Controller.instance.update(delta)
