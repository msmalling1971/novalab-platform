# Development Cluster

This folder holds the desired state for the NovaLab development cluster.

- Environment: Development
- Kubernetes Distribution: K3s
- Purpose: Learning / Platform Engineering / Genesis Development
- Status: Planned

## Known Node Mapping

- NUC01 -> Control Plane
- NUC02 -> Worker
- Bee -> Optional / Deferred

## Unknown

- TODO: IP addresses
- TODO: hostnames
- TODO: storage class
- TODO: MetalLB pool
- TODO: ingress domain

## GitOps Rule

Git will become the authoritative desired state for the development cluster once FluxCD is bootstrapped.

Manual kubectl changes may be used during learning and troubleshooting, but persistent configuration should ultimately be represented in Git.

Implementation details remain intentionally unspecified until approved.
