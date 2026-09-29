class_name ShelterBed
extends Interactable

var rest: RestSystem


func bind(system: RestSystem) -> void:
	rest = system
	rest.waves.changed.connect(func() -> void: prompt_changed.emit())


func get_interaction_text(_actor: Node3D, key_hint: String) -> String:
	if rest == null: return "Rest unavailable"
	match rest.waves.state:
		NightWaveManager.State.CLEARED: return "[%s] Rest until morning" % key_hint
		NightWaveManager.State.ACTIVE: return "Cannot rest - zombies remaining: %d" % rest.waves.remaining_zombies
		NightWaveManager.State.RESTING: return "Resting..."
		_: return "Rest available after clearing the night"


func interact(actor: Node3D) -> String:
	return "Resting until morning..." if rest != null and rest.request_rest(actor) else "Rest requires a cleared night."
