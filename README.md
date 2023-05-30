# Requirements

Kubernetes cluster with GPU support using CDI. I'm using the GPU operator to
deploy everything except the driver that is deployed manually. Helm values:
```
cdi:
  enabled: true
  default: true

driver:
  enabled: false
```

# Deploy the pod on the cluster

I deploy a simple pod on the cluster using this yaml:

```yaml
kind: Pod
metadata:
  name: dind
spec:
  containers:
  - name: dind
    image: ethyling/dind-debug:latest
    imagePullPolicy: Always
    args: [ "/bin/bash", "-c", "--", "while true; do sleep 30; done;" ]
    resources:
      limits:
        nvidia.com/gpu: 1
    securityContext:
      privileged: true
```

Deploy the pod and try to run `nvidia-smi` and `docker`:

```sh
kubectl apply -f pod.yaml
kubectl exec -it dind -- /bin/bash
nvidia-smi
docker ps
```

# Container without GPU

```sh
$ docker run --rm -it busybox
```

No error should be reported

# Container with GPU

```sh
$ docker run --rm -it -e NVIDIA_VISIBLE_DEVICES=all busybox
```

This error should be reported:
```sh
docker: Error response from daemon: failed to create task for container: failed to create shim task: OCI runtime create failed: runc create failed: unable to start container process: error during container init: error running hook #0: error running hook: exit status 1, stdout: , stderr: Auto-detected mode as 'legacy'
nvidia-container-cli: mount error: mount operation failed: /home/user/.local/share/docker/vfs/dir/d5bc60ca960ba7eb06e28387a27a2241c485caca79d1e0c153c6112ad3a01efa/run/.ro3619560490/nvidia-persistenced/socket: operation not permitted: unknown.
```
