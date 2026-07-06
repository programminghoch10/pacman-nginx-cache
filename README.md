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

## Use

Add
```
CacheServer = http://localhost:8080/$repo/os/$arch
```
to your `/etc/pacman.conf`
after every repository you want to be cached.
