# NovaLab Development Platform Sprint 1

## Purpose

This sprint creates the first reusable NovaLab development Kubernetes platform for learning, experimentation, GitOps, workload migration testing, and eventual Genesis development.

## Scope

- K3s development cluster
- NUC01 control plane
- NUC02 worker
- Bee optional / deferred
- Headlamp
- K9s
- MetalLB
- Ingress
- cert-manager
- Metrics Server
- FluxCD
- Prometheus
- Grafana
- first test workload
- first real low-risk workload

## Out of Scope

- Production Genesis
- Production workload migration
- HA production design
- permanent storage architecture
- final security hardening
- production DNS redesign

## Approved Hardware Roles

| Node | Role | Status |
| --- | --- | --- |
| NUC01 | Control Plane | Approved |
| NUC02 | Worker | Approved |
| Bee | Optional Worker | Deferred / Optional |

## Design Principles

- Development must be safe to break
- Git should become the desired-state source of truth
- Learn visually and operationally
- Use both GUI and CLI
- No production dependency on this cluster
- Changes should be documented and reproducible
- Platform services should be introduced incrementally
- Prefer capability-driven choices over tool-driven choices

## Build Sequence

1. Phase 0 - Validate Hardware and Networking
2. Phase 1 - Prepare Operating Systems
3. Phase 2 - Install K3s Control Plane
4. Phase 3 - Join Worker Node
5. Phase 4 - Validate Cluster
6. Phase 5 - Install Headlamp
7. Phase 6 - Configure K9s access
8. Phase 7 - Install MetalLB
9. Phase 8 - Install Ingress
10. Phase 9 - Install cert-manager
11. Phase 10 - Validate Metrics Server
12. Phase 11 - Bootstrap FluxCD
13. Phase 12 - Deploy First Test Workload
14. Phase 13 - Add Prometheus and Grafana
15. Phase 14 - Select First Real Low-Risk Workload
16. Phase 15 - Document Lessons Learned

## Success Criteria

- Control plane Ready
- Worker Ready
- CoreDNS healthy
- Headlamp accessible
- K9s operational
- Service reachable through cluster networking
- Flux successfully reconciles Git state
- first workload deployed through GitOps
- metrics visible
- Grafana accessible
- sprint notes committed

## Open Decisions

- TODO: Determine node IP addresses.
- TODO: Determine final node hostnames.
- TODO: Decide whether Bee will participate.
- TODO: Define the MetalLB address pool.
- TODO: Define the ingress domain.
- TODO: Select a storage class.
- TODO: Select the first real workload.
- TODO: Choose the Flux repository path / bootstrap strategy.
- TODO: Choose a secrets management approach.
