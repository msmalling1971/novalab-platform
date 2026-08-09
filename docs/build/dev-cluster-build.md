# NovaLab K3s Development Cluster Manual Build Record

## Purpose

This document records the current manual build of the NovaLab development Kubernetes platform. It is both a reproducible engineering record and a runbook explaining the decisions, validation, temporary controls, and remaining work.

This record began with the first K3s server/control-plane node, `k3s-dev-cp-01`, and now reflects the verified three-node environment at the end of the current build session. It does not represent completion of the full Sprint 1 platform described in `docs/sprints/dev-platform-sprint-01.md`.

## Current State at This Checkpoint

| Area | State |
| --- | --- |
| Cluster nodes | Three nodes; all validated as `Ready` |
| Control plane | One server/control-plane node; **not highly available** |
| K3s/Kubernetes version observed | `v1.36.3+k3s1` |
| K9s | Installed and validated, version `v0.51.0` |
| Helm | Installed, version `v3.21.3` |
| Worker nodes | Two workers joined; both validated as `Ready` |
| MetalLB | Installed through Helm and externally validated |
| Headlamp | Installed through the official Helm chart and browser-validated |
| NGINX Ingress, cert-manager, FluxCD, Prometheus, Grafana | Planned, not installed |
| OPNsense VLAN 70 rule | **TEMPORARY BUILD CONFIGURATION** |

## Design Context

The cluster is a development platform for learning, platform engineering, workload migration testing, and eventual Genesis development. The initial build is manual by design: the underlying operating, networking, and Kubernetes requirements should be understood before they are encoded in Terraform or GitOps automation.

The current repository remains the future desired-state source of truth. Manual changes are acceptable during learning and troubleshooting, but persistent platform configuration should ultimately be represented in Git after FluxCD is bootstrapped.

## Host and Virtual Machine

| Property | Value |
| --- | --- |
| Hostname | `k3s-dev-cp-01` |
| Role | First K3s server/control-plane node |
| Virtualization | Proxmox VM |
| Guest operating system | Ubuntu Server 24.04 LTS |
| vCPU | 4 |
| Memory | 8 GB |
| Virtual disk | 64 GB |
| Node address | `192.168.70.10/24` |

The Ubuntu root filesystem was expanded through LVM to consume the available volume-group capacity. This prevents the guest from retaining a small installer-created root logical volume while usable virtual-disk capacity remains unallocated.

The exact LVM commands used during this build were not captured and are therefore **TBD** for a future command-level rebuild procedure.

## Current Cluster Topology and Failure Domains

| Proxmox host | Kubernetes node | Address | Current Kubernetes role | Readiness |
| --- | --- | --- | --- | --- |
| `pve-nuc1` | `k3s-dev-cp-01` | `192.168.70.10` | `control-plane` | `Ready` |
| `pve-nuc2` | `k3s-dev-worker-01` | `192.168.70.20` | worker | `Ready` |
| `pve-bee1` | `k3s-dev-worker-02` | `192.168.70.30` | worker | `Ready` |

The Kubernetes node VMs are deliberately distributed across separate Proxmox hosts. This establishes physical failure-domain separation: loss of one physical host or hypervisor does not remove every Kubernetes node.

Physical placement and application availability solve different problems. Proxmox placement protects against physical or hypervisor failure. Kubernetes scheduling controls, topology-spread constraints, pod anti-affinity, and appropriate replica counts will eventually protect application replicas from being co-located within the same failure domain. Physical distribution alone does not guarantee workload high availability.

### Current High-Availability Boundary

The cluster has worker-node distribution across physical failure domains, but it **does not yet have a highly available Kubernetes control plane**. The only current server/control-plane node is:

```text
pve-nuc1 -> k3s-dev-cp-01
```

Loss of `pve-nuc1` or `k3s-dev-cp-01` would therefore remove the current Kubernetes control-plane endpoint even though worker capacity exists on the other Proxmox hosts.

## Network Design

### Development Network

| Property | Value |
| --- | --- |
| Network name | NovaLab-Dev |
| VLAN | 70 |
| Subnet | `192.168.70.0/24` |
| Gateway | `192.168.70.1` |
| First control-plane node | `192.168.70.10/24` |
| DNS used during build | `192.168.50.1` |
| DHCP | No scope currently configured on VLAN 70 |

Because VLAN 70 has no DHCP scope, the node uses a static address. OPNsense owns Layer 3 for the VLAN and exposes `192.168.70.1/24` on its NovaLab-Dev interface.

### Address Allocation Convention

The following scheme remains the current working allocation convention rather than a formally managed IPAM policy. The MetalLB range is now implemented; other unused ranges remain proposed or reserved until formally adopted.

| Range | Proposed use | Status |
| --- | --- | --- |
| `.1` | Gateway | In use |
| `.10-.19` | K3s control-plane nodes | Proposed convention; `.10` is in use |
| `.20-.49` | K3s worker/platform nodes | Convention in use; `.20` and `.30` assigned |
| `.50-.99` | Other static infrastructure and services | Proposed convention |
| `.100-.199` | Possible future DHCP | Reserved/proposed |
| `.200-.219` | MetalLB address pool | Implemented as `novalab-dev-pool` |
| `.220-.254` | Future use | Reserved/proposed |

Address allocations should eventually be captured in NetBox rather than relying on manually maintained address knowledge.

## Physical and VLAN Path

```text
                         Existing management network
                         192.168.50.0/24
                         native/untagged VLAN 1
                                  |
                                  | Proxmox management remains untagged
                                  v
+-------------------+      +----------------------+      +------------------+
| k3s-dev-cp-01     |      | Proxmox on NUC1      |      | NUC1 physical NIC|
| VM 103            |----->| vmbr0, VLAN-aware    |----->| trunk uplink     |
| Ubuntu: no VLAN   |      | VM NIC tagged VLAN 70|      +--------+---------+
| tagging           |      +----------------------+               |
+-------------------+                                               |
                                                                    v
                                                        +----------------------+
                                                        | UniFi Pro Max 48    |
                                                        | Port 47 to NUC1:    |
                                                        | native VLAN 1,      |
                                                        | tagged VLANs allowed|
                                                        +----------+-----------+
                                                                   |
                                                       tagged VLAN 70 workload
                                                                   |
                                                                   v
                                                        +----------------------+
                                                        | Gigamon G-TAP A-TX  |
                                                        | path                 |
                                                        +----------+-----------+
                                                                   |
                                                                   v
                                                        +----------------------+
                                                        | UniFi port 43 toward|
                                                        | OPNsense: native    |
                                                        | VLAN 1; VLAN 70     |
                                                        | permitted tagged    |
                                                        +----------+-----------+
                                                                   |
                                                                   v
                                                        +----------------------+
                                                        | OPNsense            |
                                                        | L3 gateway VLAN 70  |
                                                        | 192.168.70.1/24     |
                                                        +----------------------+
```

UniFi defines NovaLab-Dev as VLAN 70 with a third-party gateway because OPNsense, rather than UniFi, performs Layer 3 routing. Proxmox `vmbr0` is VLAN-aware. VM 103 is attached to `vmbr0` with VLAN tag 70, so Proxmox tags the VM's workload traffic; Ubuntu itself has an ordinary untagged guest interface and does not create a VLAN subinterface.

This design currently shares the NUC1 physical uplink between native VLAN 1 management traffic and tagged VLAN 70 workload traffic. A future design should consider dedicated physical management NICs for Proxmox.

## OPNsense Firewall and Troubleshooting

The newly created OPNsense VLAN 70 interface initially had no pass rules. The node could resolve the gateway with ARP, but ICMP to the gateway failed.

That combination was diagnostically important:

- Successful ARP proved that the VM, Proxmox bridge/tagging, physical path, switch configuration, and OPNsense VLAN interface could exchange Layer 2 traffic.
- Failed ICMP indicated that the problem was above Layer 2. With the VLAN path proven, OPNsense policy became the relevant boundary.
- Adding a pass rule restored Layer 3 traffic and confirmed the diagnosis.

### Temporary Build Rule

> **TEMPORARY BUILD CONFIGURATION:** This broad rule exists to support initial platform construction and traffic discovery. It is not the intended steady-state security policy.

```text
Interface:   NovaLabDev
Direction:   in
IP version:  IPv4
Protocol:    any
Source:      NovaLabDev net
Destination: any
```

After platform traffic requirements are understood, replace this rule with deliberate least-privilege policy covering only required DNS, NTP, Internet egress, management, storage, and inter-VLAN communication.

## Node Network Configuration and Validation

The implementation was validated progressively rather than treating Internet reachability as a single test. The following results were observed successfully:

| Validation | Observed result | Engineering significance |
| --- | --- | --- |
| Static address | `192.168.70.10/24` assigned | Guest addressing was applied |
| Default route | Gateway through `192.168.70.1` | Off-subnet path was present |
| ARP | OPNsense `192.168.70.1` resolved | Layer 2 and VLAN transport worked |
| Gateway ICMP | `192.168.70.1` reachable after firewall rule | Layer 3 policy allowed traffic |
| Internet by IP | `1.1.1.1` reachable | Routing/NAT/egress worked independently of DNS |
| DNS and Internet | `google.com` resolved and was reachable | DNS and egress both worked |
| Time | NTP synchronized | Time-dependent cluster operations have a valid clock basis |
| Identity | Hostname was `k3s-dev-cp-01` | Node identity matched the design |

The exact Ubuntu network configuration file and command transcript were not captured in this checkpoint. They are **TBD** rather than reconstructed from assumptions.

## K3s Installation

K3s was installed as the first server/control-plane node and explicitly bound to the node's NovaLab-Dev address:

```text
--node-ip 192.168.70.10
```

The bundled implementations below were deliberately disabled:

```text
--disable traefik
--disable servicelb
```

Traefik was disabled because NGINX Ingress is planned as the platform-managed ingress implementation. ServiceLB was disabled because MetalLB is planned as the platform-managed `LoadBalancer` implementation. Disabling both avoids overlapping implementations and preserves deliberate ownership of platform components.

The complete installer command and environment-variable form used at the console were not recorded and are **TBD**. The flags above are the explicitly recorded configuration and should be preserved in any rebuild.

### K3s Validation

The following post-installation state was observed:

- The K3s systemd service was active and running.
- The node reported `Ready`.
- The node role reported `control-plane`.
- The Kubernetes internal IP reported `192.168.70.10`.
- The K3s/Kubernetes version reported `v1.36.3+k3s1`.

### Worker Nodes

Two K3s worker nodes were subsequently joined to the cluster:

| Node | Node IP | Proxmox host | Validation |
| --- | --- | --- | --- |
| `k3s-dev-worker-01` | `192.168.70.20` | `pve-nuc2` | `Ready` |
| `k3s-dev-worker-02` | `192.168.70.30` | `pve-bee1` | `Ready` |

The exact K3s agent join commands, token-handling procedure, VM sizing, and node-specific operating-system configuration were not captured in the current repository documentation and remain **TBD**. No procedure is inferred here.

## Physical Network Versus Pod Network

Kubernetes maintains an internal Pod network that is distinct from the physical/node network:

```text
NovaLab VLAN 70 node network:  k3s-dev-cp-01 -> 192.168.70.10
Kubernetes Pod network:        initial Pods  -> 10.42.x.x
```

The node address is routable on NovaLab-Dev according to the VLAN's network policy. The observed `10.42.x.x` addresses belong to Kubernetes' internal Pod networking. They are not additional NovaLab VLAN 70 addresses and should not be placed in the VLAN 70 allocation table.

Initial healthy system workloads observed after installation were:

- CoreDNS
- local-path-provisioner
- metrics-server

The healthy metrics-server workload reflects the K3s-provided initial system component at this checkpoint. The repository's `platform/metrics-server/` area remains planned for approved desired-state configuration and validation notes; this document does not claim that a separate Helm-managed metrics-server release was installed.

## Administrative Tooling

### User kubeconfig

A user kubeconfig was created at:

```text
~/.kube/config
```

The normal Linux user was configured to use it through:

```bash
export KUBECONFIG="$HOME/.kube/config"
```

This allows `kubectl` and related tools to operate without requiring `sudo`. The exact file-copy and ownership commands used during the build were not captured and remain **TBD**.

### K9s

An Ubuntu Snap installation was attempted first. The Snap package was stale or nonfunctional in this environment, so it was removed. K9s was then installed from the upstream binary release into:

```text
/usr/local/bin/k9s
```

K9s version `v0.51.0` was installed and validated. It connected successfully to the cluster, and all namespaces and initial system Pods were visible.

This is a useful infrastructure-tooling lesson: package availability does not establish that a package source is current or suitable. For operational tools, an upstream current supported release may be preferable when a distribution channel is stale or broken.

### Helm

Helm was installed through the official Helm installation mechanism into:

```text
/usr/local/bin/helm
```

The observed version was `v3.21.3`.

Helm's basic object model is:

```text
Repository -> Chart -> Release
```

- A **repository** is a published catalog and distribution location for charts.
- A **chart** is a versioned package of Kubernetes templates and defaults.
- A **release** is a named installation of a chart in a cluster, with its selected values and revision history.

At the initial checkpoint, no Helm repositories or releases existed. Since then, MetalLB and Headlamp have been installed through Helm. The exact repository URLs, Helm release names, chart versions, and installation commands were not provided for this update and remain **TBD**.

### MetalLB

MetalLB is installed through Helm in the `metallb-system` namespace. The implemented Layer 2 configuration is:

| Resource | Verified value |
| --- | --- |
| Address pool resource | `novalab-dev-pool` |
| Address range | `192.168.70.200-192.168.70.219` |
| Layer 2 advertisement | `novalab-dev-l2` |

MetalLB speaker/FRR DaemonSet components were observed automatically deploying to newly joined worker nodes. This is expected DaemonSet behavior: eligible nodes receive the per-node components needed to participate in service address advertisement.

An nginx test Deployment and `LoadBalancer` Service received `192.168.70.200`. The service was successfully reached at `192.168.70.200:80` from an external Windows workstation across OPNsense and VLAN routing.

```text
Windows client -> OPNsense -> VLAN 70 -> MetalLB VIP
               -> Kubernetes Service -> nginx Pod
```

This validates the complete external service path rather than only in-cluster reachability. The test Deployment/Service names, manifests, and Helm chart version were not included in the available documentation and are **TBD**.

### Headlamp

Headlamp is installed from the official Headlamp Helm chart in the `headlamp` namespace. A custom `values.yaml` overrides the chart's default Service type from `ClusterIP` to `LoadBalancer`.

MetalLB assigned Headlamp VIP `192.168.70.201`. Headlamp was successfully reached from a Windows browser, and authentication was validated with a Headlamp Kubernetes ServiceAccount token. The Headlamp Pod was observed scheduled on `k3s-dev-worker-02`.

Headlamp currently provides GUI visibility into nodes, workloads, resource utilization, labels, conditions, events, and other Kubernetes resources. The exact chart version, Helm release name, custom `values.yaml` contents/path, and ServiceAccount/RBAC creation commands remain **TBD**.

## Operational Capacity Observation

Kubernetes and Headlamp currently report a worker-node ceiling of 110 Pods per node. This is a kubelet scheduling ceiling; it is not an estimate of how many useful workloads the underlying hardware can support.

Practical capacity depends on CPU, memory, storage, networking, workload resource requests and limits, platform overhead, and availability requirements. A node may exhaust one of those resources long before reaching 110 Pods.

Prometheus and Grafana, and potentially Goldilocks, OpenCost, or Kubecost, are future capacity-planning and right-sizing considerations. These tools are **not installed** at this checkpoint.

## Current and Planned Platform Stack

The stack is listed below with installed and planned state kept explicit.

| Component | Purpose | State at checkpoint |
| --- | --- | --- |
| K3s | Kubernetes distribution | Installed across one control-plane and two worker nodes |
| Helm | Kubernetes package manager | Installed; MetalLB and Headlamp installed through Helm |
| K9s | Terminal cluster interface | Installed and validated |
| Headlamp | Browser-based cluster management | Installed and browser-validated |
| MetalLB | Platform-managed `LoadBalancer` implementation | Installed and externally validated |
| NGINX Ingress | Platform-managed ingress implementation | Planned |
| cert-manager | Certificate lifecycle management | Planned |
| metrics-server | Resource metrics | Initial K3s system workload healthy; repository configuration remains planned |
| FluxCD | GitOps reconciliation | Planned |
| Prometheus | Metrics collection | Planned |
| Grafana | Metrics visualization | Planned |

## Rebuild Sequence

The verified sequence from this manual build is:

1. Create the Ubuntu Server 24.04 LTS Proxmox VM with the recorded CPU, memory, and disk resources.
2. Expand the Ubuntu root filesystem through LVM to use the available VG capacity.
3. Attach VM 103 to VLAN-aware `vmbr0` with VLAN tag 70; do not configure guest VLAN tagging.
4. Configure hostname `k3s-dev-cp-01`, static address `192.168.70.10/24`, gateway `192.168.70.1`, and current DNS `192.168.50.1`.
5. Validate address, route, ARP, gateway ICMP, Internet-by-IP, DNS, NTP, and hostname in that order.
6. If ARP works but ICMP does not, inspect OPNsense interface policy before changing the VLAN path.
7. Apply the temporary NovaLabDev build rule only as documented and retain the follow-up to replace it.
8. Install the first K3s server with Traefik and ServiceLB disabled and node IP `192.168.70.10`.
9. Validate systemd state, node readiness and role, internal IP, version, and initial system workloads.
10. Create the normal-user kubeconfig and configure `KUBECONFIG`.
11. Install and validate current upstream K9s if the available Snap remains unsuitable.
12. Install Helm through its official mechanism; the initial checkpoint had no repositories or releases.
13. Join `k3s-dev-worker-01` and `k3s-dev-worker-02`, then validate all three nodes as `Ready`.
14. Install and configure MetalLB through Helm, then validate `192.168.70.200:80` end to end with an nginx `LoadBalancer` Service.
15. Install Headlamp through its official Helm chart with a `LoadBalancer` Service override.
16. Validate Headlamp at `192.168.70.201` from a Windows browser and authenticate with the Kubernetes ServiceAccount token.

Where this runbook marks exact commands or configuration files **TBD**, consult the live system or capture them during the next rebuild rather than inventing values.

## Temporary State and Technical Debt

- **Firewall:** Replace the temporary broad VLAN 70 pass rule with least-privilege rules for DNS, NTP, Internet egress, management, storage, and required inter-VLAN communication.
- **Address allocation:** Formally adopt the working subnet convention and record the implemented MetalLB pool `192.168.70.200-192.168.70.219` in authoritative IPAM.
- **Documentation fidelity:** Capture exact Ubuntu network, LVM, K3s server/agent installation, kubeconfig, K9s, Helm, MetalLB, and Headlamp commands and version details during the next reproducible build pass.
- **Physical separation:** Consider moving Proxmox management traffic to dedicated physical management NICs instead of sharing the current workload trunk.
- **IPAM:** Move authoritative address allocations into NetBox.

## Planned HA Control-Plane Phase — Not Yet Implemented

The next planned phase is to evaluate and, only after architecture validation, implement a three-member K3s HA control plane using embedded etcd:

```text
pve-nuc1 -> cp-01
pve-nuc2 -> cp-02
pve-bee1 -> cp-03
```

The intended mapping uses `k3s-dev-cp-01` as the existing `cp-01`; final hostnames and addresses for `cp-02` and `cp-03` are **TBD**. Existing workers are expected to remain on `pve-nuc2` and `pve-bee1` unless the architecture review determines otherwise.

> **PLANNED / PENDING ARCHITECTURE VALIDATION:** No additional control-plane members or embedded-etcd HA configuration have been implemented at this checkpoint.

Before implementation, the supported K3s migration or conversion procedure from the existing single-server control plane to a three-member embedded-etcd control plane must be reviewed and documented. That procedure is intentionally **TBD** here; it must not be inferred or invented.

The architecture review must also validate failure-domain behavior when a Proxmox host contains both a control-plane VM and a worker VM, along with quorum, recovery, backups, endpoint access, resource sizing, and maintenance implications.

## Next Work

1. Review and document the supported K3s conversion path from the existing single-server control plane to embedded-etcd HA.
2. Validate the proposed three-member control-plane architecture, naming, addressing, quorum, recovery, backup, endpoint, sizing, and failure-domain design.
3. Implement the HA control plane only after that review is approved.
4. Install NGINX Ingress.
5. Install cert-manager.
6. Implement FluxCD GitOps.
7. Add Prometheus and Grafana observability.
8. Evaluate future capacity/right-sizing tooling such as Goldilocks, OpenCost, or Kubecost; none is currently installed.
9. Replace the temporary VLAN 70 firewall rule with least-privilege policy.
10. Evaluate Terraform after the first manual platform build is understood.
11. When Terraform work begins, evaluate appropriate GUI or visual Terraform tooling after learning the underlying Terraform workflow.
12. Capture IPAM and address allocations in NetBox.

## Related Repository Documentation

- `docs/sprints/dev-platform-sprint-01.md` defines the broader sprint scope, sequence, and success criteria.
- `clusters/dev/README.md` describes the future development-cluster desired-state boundary and GitOps rule.
- `platform/` contains planned component-specific desired-state areas. Their implementation details remain intentionally unspecified until approved.
