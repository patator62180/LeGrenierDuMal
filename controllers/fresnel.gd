extends Node
    
static var fresnel_material : Material = preload("res://materials/fresnel.tres")

static func get_all_children(node : Node, include_internal : bool) -> Array[Node]:
    var res : Array[Node] = []
    res.push_back(node);
    for child in node.get_children(include_internal):
        res.append_array(get_all_children(child, include_internal));
    return res;

static func toggle(object : Node, enable : bool):
    var children = get_all_children(object, true);
    for child in children:
        if child is MeshInstance3D:
            var mesh = child.mesh
            for surfaceId in mesh.get_surface_count():
                if enable:                    
                    var material = mesh.surface_get_material(surfaceId).duplicate() as Material;
                    material.next_pass = fresnel_material
                    child.set_surface_override_material(surfaceId, material)
                else:  
                    child.set_surface_override_material(surfaceId, null)
