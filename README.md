# Flarum on Podman

This the instructions to run [flarum](https://flarum.org/) on podman.
These have been inspired from flarum Pull Request #61, using circa
the same procedure.

I'm using the volume mount flag `:Z` assuming there's selinux to fix
and that containers are not shared (being in the same pod).

This was tested on Fedora 31, with podman 1.6.2.

Start by cloning this repository and **cd into that**:

    $ git clone https://github.com/akiross/flarum-podman
    $ cd flarum-podman

Now clone the flarum repo

    $ git clone https://github.com/flarum/flarum

Install flarum dependencies

    $ podman run --rm -it -v "./flarum/:/app:Z" composer install

The `flarum` directory will be used as `/var/www`, but it needs
to have the proper owner (`www-data`, which has uid `82` in alpine).
Change the permissions:

    $ podman unshare chown -R 82:82 flarum

Build the php container for flarum

    $ podman build -t flarum-fpm -f Dockerfile ./flarum

Create the pod, in this case port 8080 is used for testing:

    $ podman pod create -n flarum -p 8080:80

Prepare a directory for the db, also changing the owner
(user `mysql` has uid `999`)

    $ mkdir db
    $ podman unshare chown 999:999 db

Start mariadb as database (**change passwords!**)

    $ podman run --pod flarum -d \
                 -e MYSQL_ROOT_PASSWORD=rootpass \
                 -e MYSQL_DATABASE=flarum \
                 -e MYSQL_USER=flarum \
                 -e MYSQL_PASSWORD=flarumpass \
                 -v "./db/:/var/lib/mysql:Z" \
                 mariadb:10.4

Start flarum-fpm that we created earlier

    $ podman run --pod flarum -d \
                 -v "./flarum:/var/www:Z" \
                 flarum-fpm

Start nginx server

    $ podman run --pod flarum -d \
                 -v "./flarum:/var/www:Z" \
                 -v "./nginx/flarum.conf:/etc/nginx/conf.d/default.conf:Z" \
                 -v "./flarum/.nginx.conf:/etc/nginx/conf.d/.nginx.conf:Z" \
                 nginx:alpine

Running on a non-standard port, a manual fix in `flarum/config.php` is needed.
Change the `url` parameter to include the port `8080` that we exposed above.

After this, just connect to your host at the port `8080` to begin the
installation procedure.
