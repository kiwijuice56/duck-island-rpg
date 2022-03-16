extends MeshInstance

func _process(_delta):
	get_surface_material(0).set_shader_param("centerPos", get_node("../Spatial").get_global_transform().origin)
	get_surface_material(0).set_shader_param("cameraPos", get_node("../Spatial").get_global_transform().origin)
