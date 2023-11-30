extends Node

var current_track:AudioStreamPlayer

func stop():
  if current_track:
    var tween = get_tree().create_tween()
    tween.tween_property(current_track, "volume_db", -80.0, 1.0)
    tween.tween_callback(current_track.stop)
    current_track = null

func play():
  current_track = $track_01
  var tween = get_tree().create_tween()
  current_track.volume_db = -80
  tween.tween_property(current_track, "volume_db", 0, 1.0)
  current_track.play()
