class_name Hand
extends CharacterBody3D

const PRECISION: float = 0.01
const VELOCITY: float = 0.1

class PositionRequest:
    var position: Vector3
    var initial_position: Vector3
    
    func _init(position: Vector3, initial_position: Vector3):
        self.position = position
        self.initial_position = initial_position

var _position_request: PositionRequest = null

var requested_position: Vector3:
    set(value): 
        _position_request = PositionRequest.new(value, global_position)

func _physics_process(delta):
    if _position_request != null:
        if _position_request.position.distance_to(global_position) <= PRECISION:
            global_position = _position_request.position
            _position_request = null
        else:
            velocity = global_position.direction_to(_position_request.position) * VELOCITY
            move_and_slide()
