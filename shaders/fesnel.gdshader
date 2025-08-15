shader_type spatial;

uniform float amount : hint_range(0,2);
uniform vec3 color : source_color;

float fresnel(vec3 normal, vec3 view)
{
	return pow((1.0 - clamp(dot(normalize(normal), normalize(view)), 0.0, 1.0 )), amount);
}

void fragment()
{
	float basic_fresnel = fresnel( NORMAL, VIEW);
	ALBEDO = color;
    ALPHA = basic_fresnel;
}