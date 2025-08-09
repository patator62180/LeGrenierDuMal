extends CharacterBody3D

const RAY_LENGTH = 1000
const PULL_VELOCITY = 2

class FocusedObject:
    var contact: Vector3
    var object: RigidBody3D
    var dragging: bool
    var distance_to_contact: Vector3

    func _init(result: Dictionary):
        contact = result['position']
        object = result['collider']
        dragging = false

@onready var _camera: Camera3D = get_viewport().get_camera_3d()
@onready var _joint: PinJoint3D = $PinJoint3D
@onready var _drag_wall: Area3D = $DragWall

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
        
        _focused_object = FocusedObject.new(result) if result.size() > 0 else null
    
    if _focused_object != null and _focused_object.dragging:
        _drag_wall.global_position.y = _camera.global_position.y
        _drag_wall.global_rotation.y = _camera.global_rotation.y
        var query = PhysicsRayQueryParameters3D.create(origin, end)
        query.collide_with_areas = true
        query.collide_with_bodies = false

        var result: Dictionary = space_state.intersect_ray(query)
        
        if result.size() > 0:
            #var gap = result['position'].y - global_position.y
            #var direction = Vector3(0, gap, 0).normalized()
            #var direction = (result['position'] - global_position).normalized()
            #velocity = direction * PULL_VELOCITY
            #move_and_slide()
            
            #global_position = result['position']
            #global_position = result['position']
            #pass
            
            var direction: Vector3 =  _camera.global_position.direction_to(result['position'])
            var distance = _camera.global_position.distance_to(global_position)
            global_position = _camera.global_position + direction * distance
            
            
    

func _process(delta):
    if _focused_object != null:
        if not _focused_object.dragging and Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
            global_position = _focused_object.contact
            _focused_object.dragging = true
            _joint.set_node_a(self.get_path())
            _joint.set_node_b(_focused_object.object.get_path())
        elif _focused_object.dragging and not Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
            _focused_object.dragging = false
            _joint.set_node_a(NodePath(""))
            _joint.set_node_b(NodePath(""))
