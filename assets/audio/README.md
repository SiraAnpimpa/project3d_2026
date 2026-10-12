# Game audio provenance

The game now uses supplied recordings from `Asset/game_sounds/` for UI, shooting, harvest/crafting pickup, grass/stone footsteps, three zombie voices and day/night ambience. Original MP3s are preserved. Short derived cues, exact crop windows and source hashes are documented in [supplied/README.md](supplied/README.md) and [supplied/mapping.json](supplied/mapping.json).

Procedural WAVs in this directory were generated within the project by `tools/generate_demo_audio.py`, without external samples. Reload, player hurt, unlock, melee swing/hit and rescue rotor continue to use these cues because the supplied set has no corresponding recordings. The synthetic wind, shot, click, harvest and craft files are retained as historical source assets; ordinary runtime now uses the mapped recordings for those events.

Playback uses six effect voices, a separate footstep player, three positional zombie voices and two compressed ambience loops with crossfade. Two global UI voices survive scene changes. Gameplay audio suspends during pause; UI clicks remain available and all audio follows the existing Master-volume control. Recordings have no included creator/license metadata; no public license is inferred.
