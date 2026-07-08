# Dockered

The repository is for Docker images building.

## Services order
Each service contains comment with service name:
```
  # service name
  service_name: # Use this line as the sort_key
    <service specification, line 1>
    ...
    <service specification, line N>
  # End service name
```
Sort services by service_name (see sort_key) in `docker-compose.yml` files.


## Docker
`docker-compose.yml` mounts. Check folders mount syntax.
Check in project that in folders all mounts are with the trailing slash - "/":

```
    volumes:
      - /etc/timezone:/etc/timezone:ro
      - /etc/localtime:/etc/localtime:ro
      - /dev/snd/:/dev/snd/
      - /dev/v4l/:/dev/v4l/
      - /mnt/hdd/cam/:/opt/cam_streamer/store/
      - ${DOCKER_ROOT}/cam_streamer/:/opt/cam_streamer/cfg/
      - ${DOCKER_ROOT}/log/cam_streamer/:/opt/cam_streamer/log/
```

Maybe somewhere is pointed wrongly, no slash at the end of a folder, like:
```
    volumes:
      - /etc/timezone:/etc/timezone:ro
      - /etc/localtime:/etc/localtime:ro
      - /dev/snd:/dev/snd
      - /dev/v4l:/dev/v4l
      - /mnt/hdd/cam:/opt/cam_streamer/store
      - ${DOCKER_ROOT}/cam_streamer/:/opt/cam_streamer/cfg
      - ${DOCKER_ROOT}/log/cam_streamer:/opt/cam_streamer/log
```

Do not touch mounts which mount as a env var, like:
```
    volumes:
      - ${MEDIA1_SOURCE}:${MEDIA1_TARGET}
```
