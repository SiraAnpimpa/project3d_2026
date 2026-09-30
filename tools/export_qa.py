"""Export an isolated release-template QA build; restore project settings in finally.
Gameplay resources are identical to the normal candidate. Only entry scene differs.
Usage: python tools/export_qa.py PATH_TO_GODOT campaign|presentation|performance
"""
import json
import re
import subprocess
import sys
from pathlib import Path

godot, case = sys.argv[1:3]
chains = {
    "campaign": ["phase_3_integration_test", "phase_5_weapon_test", "phase_7_full_day_test", "phase_10_campaign_test"],
    "presentation": ["phase_3_integration_test", "phase_5_weapon_test", "phase_9_presentation_test"],
    "performance": ["phase_3_integration_test", "phase_10_performance_test"],
}
functions, variables = {}, {}
for name in chains[case]:
    source = Path("tests", name + ".gd").read_text(encoding="utf-8-sig")
    for m in re.finditer(r"(?m)^var (\w+).*$", source):
        variables[m[1]] = m[0]
    for m in re.finditer(r"(?ms)^func (\w+)\(.*?(?=^func |\Z)", source):
        functions[m[1]] = m[0].rstrip()
source = "extends Node\n" + "\n".join(variables.values()) + "\n\n" + "\n\n".join(functions.values()) + "\n"
source = source.replace('game.debug_controls.execute(&"debug_set_day_10")', 'game.waves.debug_set_day(10)')
source = source.replace("func _initialize()", "func _ready()")
source = source.replace('call_deferred("run")', 'get_tree().current_scene = null\n\tcall_deferred("run")')
source = source.replace("await physics_frame", "await get_tree().physics_frame").replace("await process_frame", "await get_tree().process_frame")
source = source.replace("get_node_count()", "get_tree().get_node_count()")
source = re.sub(r"(?<![\w.])quit\(", "get_tree().quit(", source)
if case == "presentation":
    source = source.replace("\tget_tree().quit(1 if failures else 0)", '''
	if failures > 0:
		get_tree().quit(1)
		return
	await load_menu()
	for button in current_scene.find_children("*", "Button", true, false):
		if button.text == "QUIT":
			print("STANDALONE_QUIT_BUTTON_REQUESTED")
			await click_scaled(button)
			await frames(120)
			push_error("Quit button did not exit")
			get_tree().quit(1)
			return
	push_error("Quit button missing")
	get_tree().quit(1)''')
source += "\nvar root: Window:\n\tget: return get_tree().root\nvar current_scene: Node:\n\tget: return get_tree().current_scene\n\tset(value): get_tree().current_scene = value\nvar paused: bool:\n\tget: return get_tree().paused\n\tset(value): get_tree().paused = value\n"
driver = Path("tests/standalone_campaign_driver.gd")
scene = Path("tests/StandaloneCampaign.tscn")
driver.write_text(source, encoding="utf-8")
scene.write_text('[gd_scene load_steps=2 format=3]\n[ext_resource type="Script" path="res://tests/standalone_campaign_driver.gd" id="1"]\n[node name="StandaloneQA" type="Node"]\nscript = ExtResource("1")\n', encoding="utf-8")
project, preset = Path("project.godot"), Path("export_presets.cfg")
original, original_preset = project.read_bytes(), preset.read_bytes()
out = Path("release/qa")
out.mkdir(parents=True, exist_ok=True)
try:
    project.write_bytes(original.replace(b"res://scenes/main/MainMenu.tscn", b"res://tests/StandaloneCampaign.tscn"))
    config = original_preset.decode().replace('export_files=PackedStringArray(', 'export_files=PackedStringArray("res://tests/StandaloneCampaign.tscn", "res://tests/standalone_campaign_driver.gd", ')
    config = config.replace('exclude_filter="tests/*,docs/*,tools/*"', 'exclude_filter="docs/*,tools/*"')
    preset.write_text(config, encoding="utf-8")
    with Path(".godot/phase10-export-" + case + ".log").open("w", encoding="utf-8") as log:
        result = subprocess.run([godot, "--headless", "--path", ".", "--export-release", "Windows Desktop", str(out / (case + ".exe"))], stdout=log, stderr=subprocess.STDOUT)
    print("QA export", case, "exit", result.returncode)
    sys.exit(result.returncode)
finally:
    project.write_bytes(original)
    preset.write_bytes(original_preset)
