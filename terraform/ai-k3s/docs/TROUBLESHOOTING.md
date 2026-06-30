# Kubernetes Platform Foundation

# Troubleshooting

## SSH

Issue

Password authentication failed.

Resolution

Cloud-init disabled PasswordAuthentication.

Enable it inside:

/etc/ssh/sshd_config.d/60-cloudimg-settings.conf

Restart SSH.

---

## KUBECONFIG

Issue

kubectl returned permission denied.

Resolution

Copy:

/etc/rancher/k3s/k3s.yaml

to

~/.kube/config

Set ownership.

Export:

KUBECONFIG=$HOME/.kube/config

Persist inside ~/.bashrc.

---

## Serial Console

Issue

Cursor wrapping and editing problems.

Resolution

SSH into the VM whenever possible.

---

## Proxmox Console

Issue

Serial console behaved differently than expected.

Resolution

Use SSH for administration.
Keep serial console for recovery.

---

## Helm

Verify

helm version

---

## k9s

Verify

k9s

---

## Cluster

Verify

kubectl get nodes

kubectl get pods -A

kubectl top nodes

kubectl top pods -A
