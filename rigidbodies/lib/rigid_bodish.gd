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
        var collider_velocity = state.get_contact_collider_velocity_at_position(index)
        
        var contact_direction = state.get_contact_local_position(index).direction_to(state.get_contact_collider_position(index))
        var impact_strengh = abs(velocity.dot(contact_direction))
        
        if not _contact_exists(pos) and not is_instance_of(collider, CharacterBody3D):
            var other: RigidBodish = collider as RigidBodish
            
            if collider_velocity.length() == 0 and other != null:
                contact_occured.emit(impact_strengh / 2)
                other.contact_occured.emit(impact_strengh / 2)
                other._contacts.push_back(state.get_contact_collider_position(index))
            else:
                contact_occured.emit(impact_strengh)
            
            var vfx = Game.Controller.instance._vfx_scene.instantiate() as GPUParticles3D
            get_tree().get_root().add_child(vfx)
            vfx.global_position = pos
            vfx.emitting = true
        
        new_contacts.push_back(pos)
    
    _contacts = new_contacts
