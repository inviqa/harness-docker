# Upgrades

## Upgrading from 0.3.x to 0.4.x

### Attributes moved

* `elasticsearch.host` -> `searchengine.host`
* `elasticsearch.port` -> `searchengine.port`

### New searchengine configuration and environment variables

In order to allow more options for search engines than elasticsearch, a new attribute structure was created mirroring how database attributes were done.

```yaml
searchengine:
  platform: ~ # elasticsearch or opensearch or ~
  platform_version: # depends on platform, 8 for elasticsearch, 2 for opensearch
  host: # defaults to platform
  port: 9200
```

Therefore the old elasticsearch attributes have been replaced with them, and so workspace attributes altering them should change too.

### elasticsearch updated to version 8

So that new projects use the latest version where possible, elasticsearch has been updated to 8

Now that the searchengine.platform_version attribute is available, you can switch between major versions with workspace configuration:

```yaml
attribute('searchengine.platform_version'): 7
```

If a security fix is needed for the major version though then the tag will also need updating.

### console build environment deprecated

The `services.console.build.environment` attribute is deprecated and may be obsoleted in a future release.

It is recommended instead to use `services.console.build.args` instead, which work similarly for image builds, but the variables are not available at runtime anymore. If they are needed at runtime then also declare them in `services.console.environment`.

It should be noted however, the build arguments are still contained within the image metadata so this still wouldn't remove secrets declared this way.

## Upgrading from 0.2.x to 0.3.x

### Attributes moved

The following attributes were moved to a new key:

* `elasticsearch.image` -> `services.elasticsearch.repository`
* `elasticsearch.tag` -> `services.elasticsearch.tag`
* `pipeline.publish.chart.git.ssh_credential_id` -> `pipeline.clusters.*.git.ssh_credential_id`
* `pipeline.publish.chart.git.ssh_private_key` -> `pipeline.clusters.*.git.ssh_private_key`
* `pipeline.publish.chart.git.repository` -> `pipeline.clusters.*.git.repository`

### Major updates of mongodb and postgres due to EOL

Both mongodb 4.4 and postgres 9.6 are end-of-life (EOL), and so receiving no security updates.

They have been upgraded to supported major versions in this harness (mongodb 5.0 and postgres 15)

The upgrade process for these are not automated, and so you will need to manage these updates.

If you are only using them for local development, then it may be as easy as dumping their data stores and restoring after upgrade, however if you have these in Kubernetes clusters, then you may need to plan a non-destructive upgrade.

* mongodb
  * See MongoDB's release notes for upgrading, [standalone upgrade](https://www.mongodb.com/docs/v7.0/release-notes/5.0-upgrade-standalone/)
* postgres
  * We recommend a database dump and restore. Whilst pg_upgrade can be used to upgrade from 9.6 to 15, it needs the 9.6 binaries in the same container as 15 to do so.

You can postpone their upgrade, to be instead done in a separate step, by setting in your workspace.yml:

mongodb:
```
attribute('services.mongodb.image'): mongo:4.4
```

postgres:
```
attribute('database.platform_version'): '9.6' # if database.platform is set to `postgres`
attribute('services.postgres.image'): postgres:9.6
```

For mongodb, please consider upgrading further than 5.0 if you can, so that you don't need to do this process often. We've only set to 5.0 as getting to 7.0 would require successive upgrades of 5.0, 6.0, and 7.0. These will be targetted in future harness minor releases.

### `docker-compose` command now `docker compose`

In line with the preferred way to run Docker Compose v2, the harness will now use the binary from it's Docker plugin architecture.

This means all `docker-compose` commands are replaced with `docker compose`. For Docker Desktop users there is no difference, however Linux users may need to [install the Compose plugin](https://docs.docker.com/compose/install/linux/).

If you really would like to continue using the old command, you can set in your `~/.config/my127/workspace/config.yml`:

```yaml
attribute('docker.compose.bin'): docker-compose
```

### `ws app publish chart <cluster> <branch> <commit message>` and `pipeline.clusters`

Some projects need to deploy to multiple Kubernetes clusters, so multiple cluster repositories need to be defined.

As due to this, the process for adding the first cluster repository has changed:

```diff
 pipeline:
+  clusters:
+    mycluster:
+      git:
+        ssh_credential_id: ...
+        repository: ...
   publish:
     chart:
       enabled: true
+      default_cluster: mycluster
-      git:
-        ssh_credential_id: ...
-        repository: ....
```

Additional clusters can be added to pipeline.clusters, however currently still you need to define Jenkinsfile stages for these to fit in your deployment pipeline.

The `ws app publish chart` command has now an additional first argument of the cluster name, in order to publish to the specified cluster.

### Kubernetes persistence enabled by default

Since it makes more sense for persistence to be enabled for environments, and previously backend service persistence was also enabled by default, persistence of application volumes is now also enabled by default.

Both application and backend services have two enabled flags now, `persistence.enabled` for a global toggle, and `persistence.*.enabled` for an individual toggle.

Since it's unlikely that the Kubernetes cluster you would be releasing to would support ReadWriteMany for it's default storageclass, you will need to define the PersistentVolumeClaim's storageClass, which may be, for example `nfs`. Not providing a storageClass or selector would fail to obtain a PersistentVolume for the claim, and so the Pod would never start.

```diff
 persistence:
   app-data:
+    storageClass: nfs
```

Previously `persistence.enabled` was only used for application volumes, but now includes backend service volumes, so if you do need to disable application volume persistence without disabling service volume persistence, you need to individually disable the application persistence:

```diff
 persistence:
-  enabled: false 
   app-data:
+    enabled: false
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
