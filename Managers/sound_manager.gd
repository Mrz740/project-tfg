extends Node

## Central audio autoload. Drop matching files into res://Audio/SFX and
## res://Audio/Music using the filenames below and they start playing
## automatically - no code changes needed. Missing files are skipped
## silently so the game runs fine before the assets are added.

const SFX_DIR := "res://Audio/SFX/"
const MUSIC_DIR := "res://Audio/Music/"
const SFX_POOL_SIZE := 8

const SFX_FILES := {
	"bomb_place": "bomb_place.wav",
	"explosion": "explosion.wav",
	"player_hurt": "player_hurt.wav",
	"powerup_pickup": "powerup_pickup.wav",
	"menu_move": "menu_move.wav",
	"menu_select": "menu_select.wav",
	"countdown_tick": "countdown_tick.wav",
}

const MUSIC_FILES := {
	"menu": "menu_theme.ogg",
	"gameplay": "gameplay_theme.ogg",
	"winner": "winner_theme.ogg",
}

## Per-sound volume offset in dB, relative to the SFX bus. Tweak here to
## balance individual sounds without touching the bus level.
const SFX_VOLUME_DB := {
	"explosion": -6.0,
	"player_hurt": 4.0,
}

var _sfx_streams: Dictionary = {}
var _music_streams: Dictionary = {}
var _sfx_players: Array[AudioStreamPlayer] = []
var _next_sfx_player: int = 0
var _music_player: AudioStreamPlayer
var _current_music: String = ""


func _ready() -> void:
	for i in range(SFX_POOL_SIZE):
		var p := AudioStreamPlayer.new()
		p.bus = "SFX"
		add_child(p)
		_sfx_players.append(p)

	_music_player = AudioStreamPlayer.new()
	_music_player.bus = "Music"
	add_child(_music_player)

	_load_streams(SFX_FILES, SFX_DIR, _sfx_streams)
	_load_streams(MUSIC_FILES, MUSIC_DIR, _music_streams)


func _load_streams(files: Dictionary, dir: String, target: Dictionary) -> void:
	for key in files.keys():
		var path := dir + String(files[key])
		if ResourceLoader.exists(path):
			target[key] = load(path)


func play_sfx(sound_name: String) -> void:
	var stream: AudioStream = _sfx_streams.get(sound_name)
	if stream == null:
		return
	var player := _sfx_players[_next_sfx_player]
	_next_sfx_player = (_next_sfx_player + 1) % _sfx_players.size()
	player.stream = stream
	player.volume_db = SFX_VOLUME_DB.get(sound_name, 0.0)
	player.play()


func play_music(track_name: String) -> void:
	if track_name == _current_music:
		return
	var stream: AudioStream = _music_streams.get(track_name)
	_current_music = track_name
	if stream == null:
		_music_player.stop()
		return
	_music_player.stream = stream
	_music_player.play()


func stop_music() -> void:
	_current_music = ""
	_music_player.stop()
