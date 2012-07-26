${HOME}/scripts/wallpaper.pl "$@"
DISPLAY=:0.1 fbsetbg -a $(cat ~/.wallpapers/current)
