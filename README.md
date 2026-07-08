# pacman-nginx-cache
Docker Pacman Caching container 

* only using nginx
* support for multiple repositories
* only requires mirrorlists to be mounted

## Build

```sh
docker build \
    --pull=newer \
    --tag=pacman-nginx-cache \
    .
```

## Run

```sh
docker run \
    --interactive \
    --tty \
    --rm \
    --replace \
    --name pacman-nginx-cache \
    --publish 8080:80 \
    --mount type=bind,src=/etc/pacman.conf,dst=/etc/pacman.conf,ro \
    --mount type=bind,src=/etc/pacman.d,dst=/etc/pacman.d,ro \
    --mount type=volume,src=pacman-nginx-cache,dst=/var/www/cache \
    localhost/pacman-nginx-cache
```

Following environment variables can be used to control caching behaviour:

Name | Description | Default
-|-|-
`CACHE_TIMEOUT` | How long packages should be retained in the cache | `365d`
`CACHE_MAX_SIZE` | Maximum size of the cache on disk | `32G`
`CACHE_MIN_FREE` | Minimum ensured free space on disk | `4G`

## Use

Add
```
CacheServer = http://localhost:8080/$repo/os/$arch
```
to your `/etc/pacman.conf`
after every repository you want to be cached.
