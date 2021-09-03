# BagelTracker

## Crontab Daily
```
@daily cd "/home/bandtracker/deployed_application/bagel_tracker/"; MIX_ENV=prod mix run -e UpdateSiteData.start_data_update
```

## To buid the image
```
docker build -t bagel-tracker .
```

## To deploy the image
- See [Ditial Ocean's Doc](https://docs.digitalocean.com/products/container-registry/quickstart/#push-to-your-registry) on deployment.

The basic idea is to do push to docker like:

```docker push registry.digitalocean.com/<my-registry>/<my-image>```

In our case:

Tag the image we just build:
```docker tag bagel-tracker:latest registry.digitalocean.com/docker-apps/bagel-tracker:latest```

Then push
```docker push registry.digitalocean.com/docker-apps/bagel-tracker:latest```