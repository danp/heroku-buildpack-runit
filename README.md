# heroku-buildpack-runit

A buildpack to run mulitple processes within a dyno via [runit](http://smarden.org/runit/).

## Why?

Imagine you want to run nginx in your `web` dynos, binding to `$PORT`, and fronting unicorn. You want them to run individually as if they were specified directly in the `Procfile` (including output to the log stream) without worrying about daemonizing.

## Usage

You'll probably use this in conjunction with [multiple buildpacks](https://devcenter.heroku.com/articles/using-multiple-buildpacks-for-an-app).

For every process type (eg `web`) you want to run mulitple processes in, add an entry like this to your `Procfile`:

```
web: bin/runsvdir-dyno
```

Then, create a `Procfile.web` file (where `web` matches the process type in `Procfile`). It might look like this:

```
nginx: bin/nginx-runner -p $PORT ...
unicorn: bundle exec unicorn -c config/unicorn.rb ...
```

Now, when running a `web` dyno, both the `nginx` and `unicorn` processes will run under runit.

If any process specified in `Procfile.web` crashes, the entire dyno will be restarted.

## Build downloads

The runit package is cached in Heroku's build cache and checked against its pinned
SHA-256 before every use. Missing or invalid cache entries are downloaded from
`mirrors.edge.kernel.org`, falling back to `archive.ubuntu.com` if the download or
checksum verification fails. Each source has a 10-second connection timeout, a
30-second transfer timeout, and one retry. Only verified downloads enter the cache;
the build fails if neither source provides a valid package.

## Testing

Run the compile and supervisor lifecycle regression tests directly:

```sh
test/compile
test/runsvdir-dyno
```

The compile test uses stub downloads and extraction with real checksum checks.
The supervisor test uses a temporary Procfile and a stub `runsvdir`. Neither needs
network access, a Heroku app, or an installed copy of runit.

GitHub Actions runs both tests and `shellcheck bin/* test/*` on pushes and pull
requests.
