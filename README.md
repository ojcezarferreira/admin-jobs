# Loco Jobs Admin
![title](media/screenshot.png)

Loco Jobs Admin provides simple and efficient background processing for the [Loco](http://github.com/loco-rs/loco) framework.
It supports background queues for both Postgres and SQLite databases.

# Setup

## Build the Docker Image
### 1. After cloning the project, you can build the Docker image using the following command:
```sh
docker build -t loco-job-admin .
```

### 2. Once the image is built, run the container and access the admin interface at `http://127.0.0.1:8080/`:
```sh
docker run -it -p 8080:5150 -e LOCO_ENV=development loco-job-admin
```

### 3. Configure the Database Connection
To configure the database connection, set the appropriate Docker environment variables:

* `WORKER_KIND`: Choose between Postgres or Sqlite.
* `CONNECTION_STRING`: Provide the worker's database connection string.


Example:
```sh
docker run -it -p 8080:5150 -e WORKER_KIND=Postgres -e CONNECTION_STRING="postgres://user:password@localhost/dbname" loco-job-admin
```
## Container development

Requires Docker with Compose v2.22 or newer, Bash, GNU coreutils, util-linux
(`ss` and `flock`), and standard text tools. No host Rust installation is needed.

```sh
bash scripts/dev/environment.sh setup
bash scripts/dev/environment.sh run
bash scripts/dev/environment.sh stop
bash scripts/dev/environment.sh teardown
```

Setup builds with Cargo.lock and saves a checkout-specific project name and
loopback port in `.env`. Run prints the local URL, waits for the home page to
respond successfully, and watches source, assets, and configuration for rebuilds.
Stop terminates services. Teardown removes containers and network, preserving
the data volume. The bundled SQLite sample seeds the volume only when missing;
no external database, migrations, account secrets, or mail service is required.
Keep `.env` and `.private/` local. An existing unrelated `.env` is preserved and
reported as a conflict. A reserved port conflict fails startup; stop the process
using that port before retrying. The existing production Dockerfile remains
available separately.
