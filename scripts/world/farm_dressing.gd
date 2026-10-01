extends Node3D
## Authored static set dressing. _ready also runs in the navigation bake tool.
## Large props use simple World colliders; ground markings and exterior trees do not.

const POST := "res://Asset/Post Apocolypse Pack.undefined-glb/"
const NATURE := "res://Asset/Stylized Nature MegaKit.undefined-glb/"
const SURVIVAL := "res://Asset/Survival Pack-glb/"
const MODELS := {
	POST+"Chest.glb": preload("res://Asset/Post Apocolypse Pack.undefined-glb/Chest.glb"),
	POST+"Barrel.glb": preload("res://Asset/Post Apocolypse Pack.undefined-glb/Barrel.glb"),
	POST+"Pallet.glb": preload("res://Asset/Post Apocolypse Pack.undefined-glb/Pallet.glb"),
	POST+"Traffic Barrier.glb": preload("res://Asset/Post Apocolypse Pack.undefined-glb/Traffic Barrier.glb"),
	NATURE+"Pine.glb": preload("res://Asset/Stylized Nature MegaKit.undefined-glb/Pine.glb"),
	NATURE+"Rock Medium.glb": preload("res://Asset/Stylized Nature MegaKit.undefined-glb/Rock Medium.glb"),
	SURVIVAL+"Shovel.glb": preload("res://Asset/Survival Pack-glb/Shovel.glb")
}

func _ready() -> void:
	box("OutsideLandscape", Vector3(0, -0.065, 0), Vector3(145, 0.02, 145), Color(0.27, 0.34, 0.24))
	# Base yard links shelter, crafting and the existing twelve growing beds.
	box("BaseYard", Vector3(-8, 0.012, -1.1), Vector3(11, 0.02, 5), Color("787458"))
	box("FarmSoil", Vector3(-7.9, 0.015, 4.6), Vector3(12.2, 0.02, 8), Color("645641"))
	box("RescueRoad", Vector3(13, 0.022, 18.2), Vector3(5, 0.02, 11.5), Color("74776b"))
	box("LandingClearing", Vector3(13, 0.014, 10), Vector3(8, 0.02, 8), Color("777e68"))
	# Low shelter cladding, fascia and a porch make the existing shell a small farm base.
	for z in [-8.6, -7.8, -7.0, -6.2, -5.4, -4.6]:
		box("WallStud", Vector3(-12.18, 1.5, z), Vector3(0.1, 3, 0.12), Color("6b6047"))
	for x in [-12.1, -5.9]:
		box("PorchPost", Vector3(x, 1.45, -3.85), Vector3(0.16, 2.9, 0.16), Color("4b5140"))
	box("RoofFascia", Vector3(-9, 3.08, -3.7), Vector3(6.6, 0.3, 0.15), Color("6f7255"))
	box("PorchFloor", Vector3(-9, 0.018, -3.2), Vector3(6.3, 0.02, 1.5), Color("8c8061"))
	prop("SupplyChest", POST + "Chest.glb", Vector3(-7.2, 0, -7.8), 1.35, 0, true)
	prop("WaterBarrel", POST + "Barrel.glb", Vector3(-13.9, 0, -3), 0.85, 0, true)
	# Stored upright: a low horizontal pallet looks climbable to the nav bake,
	# but CharacterBody movement has no step-up. Keep a broad path beside the house.
	var pallet := prop("SparePallet", POST + "Pallet.glb", Vector3(-14.5, 0.7, -6.8), 1.4, 0, true)
	pallet.rotation.x = PI * 0.5
	prop("FarmShovel", SURVIVAL + "Shovel.glb", Vector3(-11.7, 0.1, -8.55), 0.42, 0, false, 1.55)
	prop("WorkbenchSupplies", POST + "Chest.glb", Vector3(-4.8, 0, -3.1), 0.85, -12, true)
	# Existing 2x2 collision block becomes a recognizable supply stack.
	prop("FieldCrates", POST + "Chest.glb", Vector3(7, 0, 3), 1.8, 0)
	prop("FieldCrateTop", POST + "Chest.glb", Vector3(7, 0.9, 3), 1.3, 8)
	# Broad four-metre approach openings, visually backed by fallen barriers outside the wall.
	for side in 4:
		var angle := side * PI * 0.5
		for step in range(-22, 23, 4):
			if abs(step) < 4: continue
			var p := Vector3(step, 0, -23.8).rotated(Vector3.UP, angle)
			box("FencePost", p + Vector3.UP * 0.9, Vector3(0.17, 1.8, 0.17), Color("625942"))
			for height in [0.62, 1.22]:
				var rail := box("FenceRail", p + Vector3.UP * height, Vector3(3.9, 0.16, 0.12), Color("78765b"))
				rail.rotation.y = angle
		for flank in [-1, 1]:
			var p := Vector3(flank * 5, 0, -21.8).rotated(Vector3.UP, angle)
			prop("EntryRock", NATURE + "Rock Medium.glb", p, 2.4, side * 90 + flank * 17, true)
			prop("EntryPine", NATURE + "Pine.glb", Vector3(flank * 7, 0, -24.8).rotated(Vector3.UP, angle), 4.5, side * 71)
		prop("ClosedRoadBarrier", POST + "Traffic Barrier.glb", Vector3(0, 0, -24.1).rotated(Vector3.UP, angle), 4.8, side * 90)
	# Large silhouettes outside play, no unreachable-looking pockets inside the fence.
	for p in [Vector3(-22,0,-27), Vector3(-27,0,-15), Vector3(-27,0,13), Vector3(-18,0,27), Vector3(19,0,27), Vector3(27,0,14), Vector3(27,0,-17), Vector3(19,0,-27)]:
		prop("OuterPine", NATURE + "Pine.glb", p, 5.6, p.x * 8)
		prop("OuterRock", NATURE + "Rock Medium.glb", p + Vector3(1.5,0,1), 3.4, p.z * 6)
	# Non-solid dry ground cues identify the approaches without narrowing combat routes.
	for p in [Vector3(0,0.011,-17), Vector3(18,0.011,0), Vector3(-18,0.011,0), Vector3(0,0.011,18)]:
		box("ApproachDirt", p, Vector3(5,0.015,5), Color("797b5c"))

func box(label: String, point: Vector3, size: Vector3, color: Color) -> MeshInstance3D:
	var mesh := MeshInstance3D.new()
	mesh.name = label
	var shape := BoxMesh.new()
	shape.size = size
	mesh.mesh = shape
	var mat := StandardMaterial3D.new()
	mat.albedo_color = color
	mat.roughness = 0.95
	mesh.material_override = mat
	mesh.position = point
	add_child(mesh)
	return mesh

func prop(label: String, path: String, point: Vector3, width: float, yaw: float, solid: bool = false, height: float = 0) -> Node3D:
	var anchor := Node3D.new()
	anchor.name = label
	add_child(anchor)
	anchor.position = point
	anchor.rotation.y = deg_to_rad(yaw)
	var model := (MODELS[path] as PackedScene).instantiate() as Node3D
	anchor.add_child(model)
	var bounds := GamePresentation.model_bounds(model)
	var factor := height / bounds.size.y if height > 0 else width / maxf(bounds.size.x, bounds.size.z)
	model.scale *= factor
	model.position -= Vector3(bounds.get_center().x, bounds.position.y, bounds.get_center().z) * factor
	if solid:
		var body := StaticBody3D.new()
		body.name = "SolidProp"
		anchor.add_child(body)
		var collider := CollisionShape3D.new()
		var shape := BoxShape3D.new()
		shape.size = bounds.size * factor
		collider.shape = shape
		collider.position.y = shape.size.y * 0.5
		body.add_child(collider)
	return anchor
