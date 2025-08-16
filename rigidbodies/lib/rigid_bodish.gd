class_name RigidBodish
extends RigidBody3D

const PRECISION = 0.1

var _contacts: Array[Vector3] = []
var _stop_requested: bool = false

signal contact_occured

func _ready():
    Game.Controller.instance.register_rigid_bodish(self)

func stop():
    _stop_requested = true

func _contact_exists(other: Vector3):
    for contact in _contacts:
        if contact.distance_to(other) <= PRECISION:
            return true
    
    return false

func _integrate_forces(state):
    var new_contacts: Array[Vector3] = []
    
    for index in range(state.get_contact_count()):
        var pos = state.get_contact_local_position(index)
        var collider = state.get_contact_collider_object(index)
        var velocity = state.get_contact_local_velocity_at_position(index)
        
        if not _contact_exists(pos) and not is_instance_of(collider, CharacterBody3D):
            contact_occured.emit(velocity)
        
        new_contacts.push_back(pos)
    
    _contacts = new_contacts
