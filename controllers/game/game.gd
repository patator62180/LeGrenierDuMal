class_name Game
extends Node3D

const MAX_VELOCITY: float = 3
const MIN_VELOCITY: float = 0.001

class Impact:
    var curve: Curve
    var velocity: float
    var time_left: float
    
    func _init(curve: Curve, velocity: float):
        self.curve = curve
        self.velocity = velocity
        self.time_left = 1

class Controller:
    #region singleton
    
    static var _instance: Controller
    static var instance: Controller:
        get:
            _instance = Controller.new() if _instance == null else _instance
            return _instance
    #endregion

    signal cumulated_sound_changed
    
    var _impacts: Array[Impact] = []
    
    func add_impact(curve: Curve, velocity: float):
        _impacts.push_back(Impact.new(curve, velocity))

    func update(delta: float):
        var cumulated_sound = 0
        var new_impacts: Array[Impact] = []
        
        for impact in _impacts:
            var velocity_ratio = (max(min(impact.velocity, MAX_VELOCITY), MIN_VELOCITY) - MIN_VELOCITY) / (MAX_VELOCITY - MIN_VELOCITY)
            cumulated_sound += impact.curve.sample(1.0 - impact.time_left) * velocity_ratio
            impact.time_left -= delta
            
            if impact.time_left > 0:
                new_impacts.push_back(impact)

        cumulated_sound_changed.emit(cumulated_sound)
        
        _impacts = new_impacts

        


func _process(delta):
    Controller.instance.update(delta)
