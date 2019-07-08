#!/usr/bin/env bash

[[ ${#} -eq 1 ]] || exit 1

case "$1" in
    previous)
        dbus-send \
            --print-reply \
            --dest=org.mpris.MediaPlayer2.spotify \
            /org/mpris/MediaPlayer2 \
            org.mpris.MediaPlayer2.Player.Previous \
                || rhythmbox-client --previous
        ;;
    next)
        dbus-send \
            --print-reply \
            --dest=org.mpris.MediaPlayer2.spotify \
            /org/mpris/MediaPlayer2 \
            org.mpris.MediaPlayer2.Player.Next \
                || rhythmbox-client --next
        ;;
    play-pause)
        dbus-send \
            --print-reply \
            --dest=org.mpris.MediaPlayer2.spotify \
            /org/mpris/MediaPlayer2 \
            org.mpris.MediaPlayer2.Player.PlayPause \
                || rhythmbox-client --play-pause
        ;;
    *)
        echo "wrong argument"
        ;;
esac
