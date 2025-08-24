class_name RigidBodish
extends RigidBody3D

const PRECISION = 0.1
const MAX_CONTACTS_REPORTED = 20
const IMPACT_POINTS_COUNT = MAX_CONTACTS_REPORTED * 4

static var _impact_point_factory: PackedScene = load("res://controllers/impact/impact_point.tscn")

var _contacts: Array[Vector3] = []
var _stop_requested: bool = false
var _impact_points: Array[ImpactPoint] = []
var _impact_point_cursor: int

signal contact_occured    

func _ready():
    Game.Controller.instance.register_rigid_bodish(self)
    max_contacts_reported = MAX_CONTACTS_REPORTED
    contact_monitor = true
    
    for idx in range(IMPACT_POINTS_COUNT):
        var impact_point = _impact_point_factory.instantiate()
        add_child(impact_point)
        _impact_points.push_back(impact_point)

func stop():
    _stop_requested = true

func _contact_exists(other: Vector3):
    for contact in _contacts:
        if contact.distance_to(other) <= PRECISION:
            return true
    
    return false

func _integrate_forces(state):
    _impact_point_cursor = 0
    var new_contacts: Array[Vector3] = []

    for index in range(state.get_contact_count()):
        var pos = state.get_contact_local_position(index)
        var collider = state.get_contact_collider_object(index)
        var velocity = state.get_contact_local_velocity_at_position(index)
        var collider_velocity = state.get_contact_collider_velocity_at_position(index)
        
        var contact_direction = state.get_contact_local_position(index).direction_to(state.get_contact_collider_position(index))
        var impact_strengh = abs(velocity.dot(contact_direction))
        
        if not _contact_exists(pos) and not is_instance_of(collider, CharacterBody3D):
            var other: RigidBodish = collider as RigidBodish
            var impact_point = _impact_points[_impact_point_cursor]
            
            _impact_point_cursor += 1
            
            if _impact_point_cursor == IMPACT_POINTS_COUNT:
                _impact_point_cursor = 0
            
            impact_point.global_position = pos
            contact_occured.emit(impact_point, impact_strengh)
            
            var vfx = Game.Controller.instance._vfx_scene.instantiate() as GPUParticles3D
            get_tree().get_root().add_child(vfx)
            vfx.global_position = pos
            vfx.emitting = true
        
        new_contacts.push_back(pos)
    
    _contacts = new_contacts
