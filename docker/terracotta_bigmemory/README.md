# Docker Sample Deployments - SoftwareAG webMethods Terracotta BigMemory

Requirements: 

1) Run all commands from this directory (due to volumes path mapping)
2) Make sure you save a *valid licenses* with expected name (for proper volume mapping in docker) in the "./licensing" directory:
   
 - for "Terracotta" (used for APIGateway clustering), and name the file as "./licensing/terracotta-license.key"

## Optional: Overwriting Docker Configs

If you need to overwrite certain docker deployment vars like TAG or REG, simply add them to your shell ENV variables...

ie. to use a different registry:

```bash
export REG=different.registry.com/library/ 
```

## Terracotta Standalone

Start stack:

```
docker-compose --env-file ./configs/docker.env -f terracotta_bigmemory_standalone/docker-compose.yml up -d
```

Cleanup:

```
docker-compose --env-file ./configs/docker.env -f terracotta_bigmemory_standalone/docker-compose.yml down
```

## Terracotta Standalone with Volume Persistence

Start stack:

```
docker-compose --env-file ./configs/docker.env -f terracotta_bigmemory_standalone_persistence/docker-compose.yml up -d
```

Cleanup:

```
docker-compose --env-file ./configs/docker.env -f terracotta_bigmemory_standalone_persistence/docker-compose.yml down --volumes
```

## Terracotta cluster

Start stack:

```
docker-compose --env-file ./configs/docker.env -f terracotta_bigmemory_cluster/docker-compose.yml up -d
```

Cleanup:

```
docker-compose --env-file ./configs/docker.env -f terracotta_bigmemory_cluster/docker-compose.yml down
```

## Terracotta cluster with Volume Persistence

Start stack:

```
docker-compose --env-file ./configs/docker.env -f terracotta_bigmemory_cluster_persistence/docker-compose.yml up -d
```

Cleanup:

```
docker-compose --env-file ./configs/docker.env -f terracotta_bigmemory_cluster_persistence/docker-compose.yml down --volumes
```