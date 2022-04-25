# Upgrades

## Upgrading from 0.1.x to 0.2.x

### Solr image now built and deployable

The solr service previously was only usable for local development, but in some cases this may need to be deployed, so the service has a build step now.

This means if enabled, then by default, it will publish the docker image to the remote registry and the helm chart by default deploy to the Kubernetes environment.

The `services.solr.image` attribute is now being used for the built image tag, so the source image is now defined in `services.solr.build.image`, which, if your project has changed, will need to be reflected.
