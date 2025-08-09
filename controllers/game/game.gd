class_name Game
extends Node3D

class Impact:
    var weight: float
    var velocity: float
    var time_left: float
    
    func _init(weight: float, velocity: float, duration: float):
        self.weight = weight
        self.velocity = velocity
        self.time_left = duration

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
    
    func add_impact(weight: float, velocity: float, duration: float):
        _impacts.push_back(Impact.new(weight, velocity, duration))

    func update(delta: float):
        var cumulated_sound = 0
        var new_impacts: Array[Impact] = []
        
        for impact in _impacts:
            cumulated_sound += impact.weight * impact.velocity * 10
            impact.time_left -= delta
            
            if impact.time_left > 0:
                new_impacts.push_back(impact)
        
        cumulated_sound_changed.emit(cumulated_sound)
        
        _impacts = new_impacts

        


func _process(delta):
    Controller.instance.update(delta)
