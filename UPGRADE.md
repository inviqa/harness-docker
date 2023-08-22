# Upgrades

## Upgrading from 0.2.x to 0.3.x

### `docker-compose` command now `docker compose`

In line with the preferred way to run Docker Compose v2, the harness will now use the binary from it's Docker plugin architecture.

This means all `docker-compose` commands are replaced with `docker compose`. For Docker Desktop users there is no difference, however Linux users may need to [install the Compose plugin](https://docs.docker.com/compose/install/linux/).

If you really would like to continue using the old command, you can set in your `~/.config/my127/workspace/config.yml`:

```yaml
attribute('docker.compose.bin'): docker-compose
```

### Preview environments are now only created if the PR has a `publish-preview` label

In order to reduce waste in docker images and mess of cluster repositories, PRs will only be published (if preview enabled) when the PR has a `publish-preview` label.

It is possible to change back to the original process of publishing all PRs by switching back to `target_branch` setting, but not recommended.

## Upgrading from 0.1.x to 0.2.x

### Attributes and helm values keys moved

The following attributes were moved to a new key:

* `helm.feature.sealed_secrets` -> `pipeline.base.global.sealed_secrets.enabled`
* `pipeline.base.ingress` ->  `pipeline.base.ingresses.*` # ingresses aren't managed in this harness but the concept of multiple ingresses is required
* `pipeline.base.prometheus.podmonitoring` -> `pipeline.base.global.prometheus.podmonitoring`
* `pipeline.base.services.mysql.options` -> `pipeline.base.services.mysql.config.options`
* `replicas.varnish` -> `pipeline.base.services.varnish.replicas` # however the value has been removed, as the default is 1
* `services.mysql.options` -> `services.mysql.config.options`
* `persistence.solr` -> `persistence.solr-data`

As such, they have also been moved in the helm values to their respective global and services configuration maps.

### Solr image now built and deployable

The solr service previously was only usable for local development, but in some cases this may need to be deployed, so the service has a build step now.

This means if enabled, then by default, it will publish the docker image to the remote registry and the helm chart by default deploy to the Kubernetes environment.

The `services.solr.image` attribute is now being used for the built image tag, so the source image is now defined in `services.solr.build.image`, which, if your project has changed, will need to be reflected.
