class_name SceneryGrounding
extends RefCounted
## Fit decoration to the actual piecewise-planar terrain, including the outer visual rings.
## Cached lattice heights avoid repeating the authored height function for every grass blade.

static var _lattice: Dictionary = {}

static func surface_height(point: Vector2) -> float:
	var extent := maxf(absf(point.x),absf(point.y))
	var step := 2.0 if extent < 56.0 else 4.0 if extent < 120.0 else 12.0
	var corner := Vector2(floorf(point.x/step)*step,floorf(point.y/step)*step)
	var fraction := (point-corner)/step
	var a := lattice_height(corner)
	var b := lattice_height(corner+Vector2(step,0))
	var c := lattice_height(corner+Vector2(0,step))
	if fraction.x+fraction.y <= 1.0:
		return a+(b-a)*fraction.x+(c-a)*fraction.y
	var d := lattice_height(corner+Vector2.ONE*step)
	return d+(c-d)*(1.0-fraction.x)+(b-d)*(1.0-fraction.y)

static func lattice_height(point: Vector2) -> float:
	if not _lattice.has(point): _lattice[point] = RuralTerrain.height_at(point.x,point.y)
	return _lattice[point]

static func slope_basis(point: Vector2, yaw: float, amount: float, max_degrees: float = 22.0) -> Basis:
	var dx := surface_height(point+Vector2(0.35,0))-surface_height(point-Vector2(0.35,0))
	var dz := surface_height(point+Vector2(0,0.35))-surface_height(point-Vector2(0,0.35))
	var normal := Vector3(-dx/0.7,1,-dz/0.7).normalized()
	var angle := acos(clampf(normal.y,-1,1))
	var weight := amount if angle < 0.0001 else minf(amount,deg_to_rad(max_degrees)/angle)
	return Basis(Quaternion.IDENTITY.slerp(Quaternion(Vector3.UP,normal),weight))*Basis(Vector3.UP,deg_to_rad(yaw))

static func contact_adjustment(vertices: PackedVector3Array, transform: Transform3D, embedding: float) -> float:
	var lowest := INF
	for vertex in vertices:
		var point := transform*vertex
		lowest = minf(lowest,point.y-surface_height(Vector2(point.x,point.z)))
	return -lowest-embedding if not vertices.is_empty() else 0.0

static func lower_footprint(faces: PackedVector3Array, bottom: float, top: float, fraction: float) -> PackedVector3Array:
	# Clip the actual source mesh at its basal collar, then project that footprint
	# onto the cut plane. A pointed root/rock tip cannot define the support alone.
	var cut := bottom+(top-bottom)*fraction
	var points := PackedVector2Array()
	for i in range(0,faces.size(),3):
		for edge in 3:
			var a := faces[i+edge]
			var b := faces[i+(edge+1)%3]
			if a.y <= cut: points.append(Vector2(a.x,a.z))
			if (a.y < cut and b.y > cut) or (b.y < cut and a.y > cut):
				var cross_point := a.lerp(b,(cut-a.y)/(b.y-a.y))
				points.append(Vector2(cross_point.x,cross_point.z))
	var result := PackedVector3Array()
	if points.is_empty(): return result
	for point in Geometry2D.convex_hull(points): result.append(Vector3(point.x,cut,point.y))
	return result

static func footprint_adjustment(footprint: PackedVector3Array, transform: Transform3D, clearance: float = 0.015) -> float:
	# Test the entire base, including edge/interior terrain dips. Work in world
	# space so large trees and small pebbles use the same 12cm sample spacing.
	if footprint.size() < 3: return 0.0
	var polygon := PackedVector2Array()
	var maximum := -INF
	var lo := Vector2(INF,INF)
	var hi := Vector2(-INF,-INF)
	for vertex in footprint:
		var world := transform*vertex
		var xz := Vector2(world.x,world.z)
		polygon.append(xz)
		lo = lo.min(xz)
		hi = hi.max(xz)
		maximum = maxf(maximum,world.y-surface_height(xz))
	var plane := Plane(transform*footprint[0],transform*footprint[1],transform*footprint[2])
	for i in range(footprint.size()-1):
		var start := transform*footprint[i]
		var finish := transform*footprint[i+1]
		var steps := maxi(1,ceili(start.distance_to(finish)/0.12))
		for j in range(1,steps):
			var world := start.lerp(finish,float(j)/steps)
			maximum = maxf(maximum,world.y-surface_height(Vector2(world.x,world.z)))
	var nx := maxi(1,ceili((hi.x-lo.x)/0.12))
	var nz := maxi(1,ceili((hi.y-lo.y)/0.12))
	for iz in range(nz+1):
		for ix in range(nx+1):
			var xz := Vector2(lerpf(lo.x,hi.x,float(ix)/nx),lerpf(lo.y,hi.y,float(iz)/nz))
			if not Geometry2D.is_point_in_polygon(xz,polygon): continue
			var y := (plane.d-plane.normal.x*xz.x-plane.normal.z*xz.y)/plane.normal.y
			maximum = maxf(maximum,y-surface_height(xz))
	return -maximum-clearance
