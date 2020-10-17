#!/bin/sh

if [ $PLAYER_EVENT == "change" ]; then
  artist=$(playerctl -p spotifyd metadata artist)
  title=$(playerctl -p spotifyd metadata title)
  album=$(playerctl -p spotifyd metadata album)

  notify-send -u low "Spotify" "$title\nby $artist\non $album"
fi
