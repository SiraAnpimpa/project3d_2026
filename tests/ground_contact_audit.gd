extends "res://tests/scenery_placement_audit.gd"
## Check the complete low mesh collar, independently against actual terrain triangles.

func run() -> void:
 set_meta("normal_play",true)
 var game: Node3D = load("res://scenes/main/GameRoot.tscn").instantiate()
 if "--baseline" in OS.get_cmdline_user_args(): game.get_node("MainWorld/RuralEnvironment").set_script(load("res://tests/ground_contact_baseline_environment.gd"))
 root.add_child(game)
 current_scene = game
 await frames(20)
 game.clock.set_process(false)
 var world: Node3D = game.get_node("MainWorld")
 var scenery: RuralEnvironment = world.get_node("RuralEnvironment")
 for spec in [["PlayableTerrain",2.0],["DistantTerrain",4.0],["HorizonTerrain",12.0]]:
  var node := world.get_node("Terrain/"+spec[0]) as MeshInstance3D
  var cells: Dictionary = {}
  var vertices := node.mesh.get_faces()
  for i in range(0,vertices.size(),3):
   var a: Vector3 = node.global_transform*vertices[i]
   var b: Vector3 = node.global_transform*vertices[i+1]
   var c: Vector3 = node.global_transform*vertices[i+2]
   var center := (a+b+c)/3
   var cell := Vector2i(floori(center.x/spec[1]),floori(center.z/spec[1]))
   if not cells.has(cell): cells[cell] = []
   cells[cell].append({"plane":Plane(a,b,c),"polygon":PackedVector2Array([Vector2(a.x,a.z),Vector2(b.x,b.z),Vector2(c.x,c.z)])})
  terrain_cells[spec[1]] = cells

 var records: Array = []
 for asset in scenery._models:
  var tree: bool = str(asset).begins_with("Tree") or str(asset).begins_with("Pine") or str(asset).begins_with("Dead Tree")
  var stone: bool = str(asset).begins_with("Rock") or str(asset).begins_with("Pebble")
  if not tree and not stone: continue
  var info: Dictionary = scenery._models[asset]
  var vertices := PackedVector3Array()
  var unique: Dictionary = {}
  for part in info.parts:
   for vertex: Vector3 in part.mesh.get_faces(): unique[part.transform*vertex] = true
  for vertex: Vector3 in unique: vertices.append(vertex)
  var low := INF
  var high := -INF
  for vertex in vertices:
   low = minf(low,vertex.y)
   high = maxf(high,vertex.y)
  # A true trunk cut is level; exclude rising roots from the collar measurement.
  # Rock collars include the bottom fifth, so a single pointed tip cannot pass.
  var band := (high-low)*(0.03 if tree else 0.20)
  var support := PackedVector3Array()
  for vertex in vertices:
   if vertex.y <= low+maxf(band,0.0001): support.append(vertex)
  # Independent cut-plane polygon from actual triangles; don't reuse the fitter.
  var cap_points := PackedVector2Array()
  for part in info.parts:
   var faces: PackedVector3Array = part.mesh.get_faces()
   for face_index in range(0,faces.size(),3):
    for edge in 3:
     var a: Vector3 = part.transform*faces[face_index+edge]
     var b: Vector3 = part.transform*faces[face_index+(edge+1)%3]
     if a.y <= low+band: cap_points.append(Vector2(a.x,a.z))
     if (a.y < low+band and b.y > low+band) or (b.y < low+band and a.y > low+band):
      var crossing := a.lerp(b,(low+band-a.y)/(b.y-a.y))
      cap_points.append(Vector2(crossing.x,crossing.z))
  var hull := Geometry2D.convex_hull(cap_points)
  for transform: Transform3D in scenery._batches.get(asset,[]):
   var min_gap := INF
   var max_gap := -INF
   var worst := Vector3.ZERO
   for vertex in support:
    var sample := transform*vertex
    var gap := sample.y-mesh_height(sample)
    min_gap = minf(min_gap,gap)
    if gap > max_gap:
     max_gap = gap
     worst = sample
   var exposed_top := -INF
   for vertex in vertices:
    var sample := transform*vertex
    exposed_top = maxf(exposed_top,sample.y-mesh_height(sample))
   var footprint_gap := -INF
   # Rasterize a fan of triangles over the whole collar at a denser, unrelated
   # 7cm spacing, using actual rendered ground planes from the mesh cache.
   var anchor := transform*Vector3(hull[0].x,low+band,hull[0].y)
   for index in range(1,hull.size()-2):
    var b := transform*Vector3(hull[index].x,low+band,hull[index].y)
    var c := transform*Vector3(hull[index+1].x,low+band,hull[index+1].y)
    var divisions := maxi(1,ceili(maxf(anchor.distance_to(b),maxf(anchor.distance_to(c),b.distance_to(c)))/0.07))
    for u in range(divisions+1):
     for v in range(divisions-u+1):
      var sample := anchor+(b-anchor)*float(u)/divisions+(c-anchor)*float(v)/divisions
      footprint_gap = maxf(footprint_gap,sample.y-mesh_height(sample))
   var bounds: AABB = info.bounds
   records.append({"asset":asset,"category":"tree" if tree else "stone","origin":[transform.origin.x,transform.origin.y,transform.origin.z],"min_gap":min_gap,"max_gap":max_gap,"footprint_gap":footprint_gap,"exposed_top":exposed_top,"worst":[worst.x,worst.y,worst.z],"world_height":bounds.size.y*transform.basis.get_scale().y,"source_band":band,"samples":support.size()})
 var summary: Dictionary = {}
 for row in records:
  if not summary.has(row.category): summary[row.category] = {"count":0,"floating":0,"max_gap":-INF,"deepest":INF}
  var entry: Dictionary = summary[row.category]
  entry.count += 1
  if row.footprint_gap > 0.005: entry.floating += 1
  entry.max_gap = maxf(entry.max_gap,row.footprint_gap)
  entry.deepest = minf(entry.deepest,row.min_gap)
 if "--validate" in OS.get_cmdline_user_args():
  for category in summary:
   check(summary[category].floating == 0, category + " whole basal footprint has no gaps above 5mm")
  for row in records:
   var depth_limit: float = row.world_height*(0.15 if row.category=="tree" else 0.65)+0.015
   check(row.min_gap >= -depth_limit, row.asset + " retains natural visible height")
   if row.category=="stone": check(row.exposed_top > row.world_height*0.25, row.asset + " remains visibly above soil")
  check(scenery.tree_positions.size() == 288, "existing tree count and composition retained")
 var output := "user://ground_contact_audit.json"
 var args := OS.get_cmdline_user_args()
 var index := args.find("--output")
 if index >= 0: output = args[index+1]
 var file := FileAccess.open(output,FileAccess.WRITE)
 file.store_string(JSON.stringify({"failures":failures,"summary":summary,"rows":records},"  "))
 print("GROUND_CONTACT_RESULT failures=",failures," summary=",JSON.stringify(summary))
 quit(1 if failures else 0)
