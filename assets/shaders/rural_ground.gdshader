shader_type spatial;
render_mode diffuse_burley;

// World coordinates keep grain, meadow variation and worn road tracks continuous.
varying vec3 ground_position;
uniform vec2 road_points[7];
uniform vec2 rescue_points[4];

float hash21(vec2 p) {
	return fract(sin(dot(p, vec2(127.1,311.7))) * 43758.5453);
}
float noise21(vec2 p) {
	vec2 cell = floor(p);
	vec2 f = fract(p);
	f = f*f*(3.0-2.0*f);
	return mix(mix(hash21(cell),hash21(cell+vec2(1.0,0.0)),f.x),
		mix(hash21(cell+vec2(0.0,1.0)),hash21(cell+vec2(1.0)),f.x),f.y);
}
float segment_distance(vec2 p, vec2 a, vec2 b) {
	vec2 ab = b-a;
	return length(p-a-ab*clamp(dot(p-a,ab)/dot(ab,ab),0.0,1.0));
}
void vertex() {
	ground_position = (MODEL_MATRIX*vec4(VERTEX,1.0)).xyz;
}
void fragment() {
	vec2 p = ground_position.xz;
	float broad = noise21(p*0.32);
	float grain = noise21(p*9.0);
	float close_detail = 1.0-smoothstep(28.0,78.0,length(VERTEX));
	vec3 earth = COLOR.rgb * (0.84 + 0.16*broad + (grain-0.5)*0.14*close_detail);
	float grass = smoothstep(0.005,0.085,COLOR.g-COLOR.r);
	earth = mix(earth,earth*vec3(0.88,1.015,0.88),grass*0.65);
	// Narrow irregular wheel wear follows the existing road; terrain/collision never move.
	float road = 1000.0;
	for (int i=0; i<6; i++) road = min(road,segment_distance(p,road_points[i],road_points[i+1]));
	for (int i=0; i<3; i++) road = min(road,segment_distance(p,rescue_points[i],rescue_points[i+1]));
	float ruts = 1.0-smoothstep(0.12,0.32,abs(road-0.78+(broad-0.5)*0.12));
	float interruptions = smoothstep(0.17,0.42,noise21(p*0.7+vec2(45.0)));
	earth *= 1.0-ruts*interruptions*0.19;
	// Soft forest floor leaf litter belongs to the western woodland, outside the home yard.
	float forest = exp(-dot((p-vec2(-39.0,17.0))/vec2(17.0,27.0),(p-vec2(-39.0,17.0))/vec2(17.0,27.0)));
	float leaves = smoothstep(0.72,0.89,noise21(p*5.0+vec2(8.0)))*forest*close_detail;
	earth = mix(earth,vec3(0.30,0.235,0.125),leaves*0.30);
	ALBEDO = earth;
	ROUGHNESS = 0.98;
	SPECULAR = 0.08;
}
