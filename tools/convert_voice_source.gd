extends SceneTree
# Development-only Ogg decoding using the existing Godot Vorbis decoder.
func _initialize() -> void:
	var args := OS.get_cmdline_user_args()
	if args.size()!=2 or not args[0].ends_with(".ogg") or not args[1].ends_with(".wav"):
		push_error("Expected original.ogg decoded.wav");quit(1);return
	var source := AudioStreamOggVorbis.load_from_file(args[0])
	if source==null:quit(1);return
	var playback := source.instantiate_playback()
	playback.start()
	var rate := int(AudioServer.get_mix_rate())
	var audio := PackedByteArray()
	var remaining := ceili((source.get_length()+.1)*rate)
	while remaining>0:
		var mixed := playback.mix_audio(1.0,mini(4096,remaining))
		if mixed.is_empty():break
		var start := audio.size();audio.resize(start+mixed.size()*2)
		for i: int in range(mixed.size()):audio.encode_s16(start+i*2,clampi(roundi((mixed[i].x+mixed[i].y)*.5*32767),-32768,32767))
		remaining-=mixed.size()
	playback.stop()
	var wav := AudioStreamWAV.new();wav.format=AudioStreamWAV.FORMAT_16_BITS;wav.stereo=false;wav.mix_rate=rate;wav.data=audio
	var result := wav.save_to_wav(args[1])
	print("Decoded original Ogg: ",rate," Hz, ",audio.size()/2," frames, result ",result)
	call_deferred("quit",0 if result==OK else 1)
