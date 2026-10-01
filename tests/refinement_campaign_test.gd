extends "res://tests/phase_10_campaign_test.gd"

func new_game() -> void:
	set_meta("normal_play",true)
	await super.new_game()
