extends Node3D

const RAY_LENGTH = 1000
const PULL_VELOCITY = 2

class FocusedObject:
    var contact: Vector3
    var object: RigidBody3D
    var dragging: bool
    var distance_to_contact: float
    var normal: Vector3
    var pause_time_left: float

    func _init(result: Dictionary, camera: Camera3D):
        contact = result['position']
        object = result['collider']
        normal = result['normal'].normalized()
        dragging = false
        distance_to_contact = camera.global_position.distance_to(contact)

    func pause():
        (object as RigidBody3D).set_deferred('freeze', true)
        pause_time_left = 0.1

    func update(delta: float):
        if pause_time_left > 0:
            pause_time_left -= delta
            if pause_time_left <= 0:
                (object as RigidBody3D).set_deferred('freeze', false)



@onready var _camera: Camera3D = get_viewport().get_camera_3d()
@onready var _joint: Generic6DOFJoint3D = $Joint
@onready var _drag_wall: Area3D = $Hand/DragWall
@onready var _hand: CharacterBody3D = $Hand

var _focused_object: FocusedObject = null

func _physics_process(delta):
    var mousepos = get_viewport().get_mouse_position()
    var space_state = get_world_3d().direct_space_state
    var origin = _camera.project_ray_origin(mousepos)
    var end = origin + _camera.project_ray_normal(mousepos) * RAY_LENGTH

    if _focused_object == null or not _focused_object.dragging:
        var query = PhysicsRayQueryParameters3D.create(origin, end, 2)
        query.collide_with_areas = false
        query.collide_with_bodies = true

        var result: Dictionary = space_state.intersect_ray(query)
        
        _focused_object = FocusedObject.new(result, _camera) if result.size() > 0 else null
    
    if _focused_object != null and _focused_object.dragging:
        _focused_object.update(delta)
        _hand.global_position = _camera.global_position + _camera.global_position.direction_to(_hand.global_position) * _focused_object.distance_to_contact

        _drag_wall.global_rotation.y = _camera.global_rotation.y
        var query = PhysicsRayQueryParameters3D.create(origin, end)
        query.collide_with_areas = true
        query.collide_with_bodies = false

        var result: Dictionary = space_state.intersect_ray(query)
        
        if result.size() > 0:
            _hand.global_position = _camera.global_position + _camera.global_position.direction_to(result['position']) * _camera.global_position.distance_to(_hand.global_position)
            
    

func _process(delta):
    if _focused_object != null:
        if not _focused_object.dragging and Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
            _hand.global_position = _focused_object.contact
            _joint.global_position = _focused_object.contact
            _focused_object.dragging = true
            _joint.set_node_a(_hand.get_path())
            _joint.set_node_b(_focused_object.object.get_path())
            _focused_object.pause()
        elif _focused_object.dragging and not Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
            _focused_object.dragging = false
            _joint.set_node_a(NodePath(""))
            _joint.set_node_b(NodePath(""))
