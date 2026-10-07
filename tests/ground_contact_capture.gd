extends "res://tests/cleanup_survey.gd"

func run() -> void:
 root.size = Vector2i(1280,720)
 set_meta("normal_play",true)
 game = load("res://scenes/main/GameRoot.tscn").instantiate()
 root.add_child(game)
 current_scene = game
 await frames(25)
 game.clock.set_process(false)
 game.clock.paused = true
 game.waves.enabled = false
 game.player.health.damage_enabled = false
 game.hud.hide()
 game.clock.seek(1,9,0)
 var args := OS.get_cmdline_user_args()
 var index := args.find("--targets")
 var targets: Array = JSON.parse_string(FileAccess.get_file_as_string(args[index+1]))
 var camera := Camera3D.new()
 game.add_child(camera)
 camera.current = true
 camera.far = 350
 camera.fov = 50
 for target in targets:
  var foot := Vector3(target.worst[0],target.worst[1],target.worst[2])
  foot.y = SceneryGrounding.surface_height(Vector2(foot.x,foot.z))
  for side in 2:
   var distance := clampf(target.world_height*1.3,2.4,5.0)
   var offset := Vector3(1,0,1 if side==0 else -1).normalized()*distance
   camera.position = foot+offset
   camera.position.y = SceneryGrounding.surface_height(Vector2(camera.position.x,camera.position.z))+0.85
   camera.look_at(foot+Vector3.UP*0.35)
   await frames(6)
   await capture(String(target.asset).replace(" ","_")+"_"+str(side))
 print("GROUND_CAPTURE_RESULT failures=",failures)
 quit(1 if failures else 0)
