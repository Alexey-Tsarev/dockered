# MPD
I am using Debian 13 with mpd installed.

I found the following bug, mpd hangs:
```
mpd -V
Music Player Daemon 0.24.4 (0.24.4)

journalctl -u mpd
May 08 13:19:47 hostname mpd[90582]: client: [192.168.1.2:43284] process command "currentsong"
May 08 13:19:47 hostname mpd[90582]: client: [192.168.1.2:43284] command returned 0
May 08 13:19:47 hostname mpd[90582]: client: [192.168.1.2:43284] process command "commands"
May 08 13:19:47 hostname mpd[90582]: client: [192.168.1.2:43284] command returned 0
May 08 13:19:47 hostname mpd[90582]: client: [192.168.1.2:43284] process command "readpicture \"http://192.168.1.1:8123/api/tts_proxy/T1ov3eonJScvXxHV-x6QSQ.mp3\" \"0\""
May 08 13:41:04 hostname systemd[1]: Stopping mpd.service - Music Player Daemon...
May 08 13:42:34 hostname systemd[1]: mpd.service: State 'stop-sigterm' timed out. Killing.
May 08 13:42:34 hostname systemd[1]: mpd.service: Killing process 90582 (mpd) with signal SIGKILL.
May 08 13:42:34 hostname systemd[1]: mpd.service: Main process exited, code=killed, status=9/KILL
May 08 13:42:34 hostname systemd[1]: mpd.service: Failed with result 'timeout'.
May 08 13:42:34 hostname systemd[1]: Stopped mpd.service - Music Player Daemon.
```

Home Assistant runs the `readpicture` method.

I made this Docker image and I got no problem:
```
docker exec mpd mpd -V
Music Player Daemon 0.24.10 (0.24.10)

journalctl CONTAINER_NAME=mpd
May 08 15:23:39 hostname mpd[1308]: 2026-05-08T15:23:39 client: [192.168.1.2:52344] client connected
May 08 15:23:39 hostname mpd[1308]: 2026-05-08T15:23:39 client: [192.168.1.2:52344] process command "status"
May 08 15:23:39 hostname mpd[1308]: 2026-05-08T15:23:39 client: [192.168.1.2:52344] command returned 0
May 08 15:23:39 hostname mpd[1308]: 2026-05-08T15:23:39 client: [192.168.1.2:52344] process command "currentsong"
May 08 15:23:39 hostname mpd[1308]: 2026-05-08T15:23:39 client: [192.168.1.2:52344] command returned 0
May 08 15:23:39 hostname mpd[1308]: 2026-05-08T15:23:39 client: [192.168.1.2:52344] disconnected
May 08 15:23:48 hostname mpd[1308]: 2026-05-08T15:23:48 client: [127.0.0.1:38254] client connected
May 08 15:23:48 hostname mpd[1308]: 2026-05-08T15:23:48 client: [127.0.0.1:38254] process command "readpicture \"http://www.richardfarrar.com/audio/21%20-%20ID3%20Image%20-%20All%20Images.mp3\" \"0\""
May 08 15:23:50 hostname mpd[1308]: 2026-05-08T15:23:50 client: [127.0.0.1:38254] command returned 0
May 08 15:23:50 hostname mpd[1308]: 2026-05-08T15:23:50 client: [127.0.0.1:38254] malformed command ""
May 08 15:23:50 hostname mpd[1308]: 2026-05-08T15:23:50 client: [127.0.0.1:38254] disconnected
May 08 15:23:50 hostname mpd[1308]: 2026-05-08T15:23:50 client: [192.168.1.2:51296] client connected
May 08 15:23:50 hostname mpd[1308]: 2026-05-08T15:23:50 client: [192.168.1.2:51296] process command "status"
May 08 15:23:50 hostname mpd[1308]: 2026-05-08T15:23:50 client: [192.168.1.2:51296] command returned 0
May 08 15:23:50 hostname mpd[1308]: 2026-05-08T15:23:50 client: [192.168.1.2:51296] process command "currentsong"
May 08 15:23:50 hostname mpd[1308]: 2026-05-08T15:23:50 client: [192.168.1.2:51296] command returned 0
```

`mpd_local.conf` example:
```
log_level       "verbose"

bind_to_address "127.0.0.1"
bind_to_address "192.168.1.1"

port            "6600"

audio_output {
  type          "alsa"
  name          "USB Audio DAC"
  device        "hw:CARD=MicroII,DEV=0"
  mixer_type    "software"
}
```
