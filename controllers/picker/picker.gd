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
@onready var _wrist: Joint3D = $Wrist
@onready var _drag_wall: Area3D = $Hand/DragWall
@onready var _hand: RigidBody3D = $Hand
@onready var _body: RigidBody3D = $Body
@onready var _shoulder: Joint3D = $Shoulder

var _previous_hand_pos: Vector3

var _focused_object: FocusedObject = null
var _last_target_hand_position: Vector3
var _last_position_diff: Vector3
var _mouse_input: Vector2

@export var pid_p: float = 10
@export var pid_i: float = 0
@export var pid_d: float = 0

func _ready():
    _body.process_mode = Node.PROCESS_MODE_DISABLED

func _physics_process(delta):
    var space_state = get_world_3d().direct_space_state

    if _focused_object == null or not _focused_object.dragging:
        var mouse_position = get_viewport().get_mouse_position()
        var origin = _camera.project_ray_origin(mouse_position)
        var end = origin + _camera.project_ray_normal(mouse_position) * RAY_LENGTH
        var query = PhysicsRayQueryParameters3D.create(origin, end, 2)
        query.collide_with_areas = false
        query.collide_with_bodies = true

        var result: Dictionary = space_state.intersect_ray(query)
        
        _focused_object = FocusedObject.new(result, _camera) if result.size() > 0 else null
    
    if _focused_object != null and _focused_object.dragging:
        _focused_object.update(delta)
        #_hand.global_position = _camera.global_position + _camera.global_position.direction_to(_hand.global_position) * _focused_object.distance_to_contact

        _drag_wall.global_rotation.y = _camera.global_rotation.y
        var mouse_position = get_viewport().get_mouse_position() + _mouse_input
        var origin = _camera.project_ray_origin(mouse_position)
        var end = origin + _camera.project_ray_normal(mouse_position) * RAY_LENGTH
        
        var query = PhysicsRayQueryParameters3D.create(origin, end)
        query.collide_with_areas = true
        query.collide_with_bodies = false

        var result: Dictionary = space_state.intersect_ray(query)
        
        if result.size() > 0:
            var position_diff = _last_target_hand_position - _hand.global_position
            var target_hand_position = _camera.global_position + _camera.global_position.direction_to(result['position']) * _camera.global_position.distance_to(_hand.global_position)
            var command = target_hand_position - _hand.global_position
            var force = pid_p * position_diff + pid_i * (position_diff / delta) + pid_d * (position_diff - _last_position_diff) / delta
            
            _hand.apply_force(force)
            _last_target_hand_position = target_hand_position
            _last_position_diff = position_diff
        
        _mouse_input = Vector2.ZERO
   
func _unhandled_input(event : InputEvent):
    if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
        _mouse_input.x += event.relative.x
        _mouse_input.y += event.relative.y

func _process(delta):
    if _focused_object != null:
        if not _focused_object.dragging and Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
            _hand.global_position = _focused_object.contact
            _wrist.global_position = _focused_object.contact
            _focused_object.dragging = true
            _wrist.set_node_a(_hand.get_path())
            _wrist.set_node_b(_focused_object.object.get_path())
            _focused_object.pause()
            Game.Controller.instance.attach_object((_focused_object.object as RigidBody3D).mass)
            _body.global_position = Game.Controller.instance.character.global_position
            _shoulder.global_position = _body.global_position
            _shoulder.set_node_a(_body.get_path())
            _shoulder.set_node_b(_hand.get_path())
            var followed_offset = _focused_object.contact - _focused_object.object.global_position
            Game.Controller.instance.character.follow_object(_focused_object.object, followed_offset, _body)
            _previous_hand_pos = _hand.global_position
            _body.process_mode = Node.PROCESS_MODE_ALWAYS
            _body.axis_lock_linear_x = true
            _body.axis_lock_linear_y = true
            _body.axis_lock_linear_z = true
            _last_target_hand_position = _hand.global_position
            _mouse_input = Vector2.ZERO
        elif _focused_object.dragging and not Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
            _focused_object.dragging = false
            _wrist.set_node_a(NodePath(""))
            _wrist.set_node_b(NodePath(""))
            _shoulder.set_node_a(NodePath(""))
            _shoulder.set_node_b(NodePath(""))
            Game.Controller.instance.release_object()
            Game.Controller.instance.character.stop_following_object()
            _body.process_mode = Node.PROCESS_MODE_DISABLED
