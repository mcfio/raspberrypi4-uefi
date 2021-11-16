# Raspberry Pi4 UEFI Container

This repository creates the necessary Sidero configuration files to use [Raspberry Pi4's as Servers](https://www.sidero.dev/docs/v0.4/guides/rpi4-as-servers)

Each Pi4 boards serial and mac address are unique and require the "two-step boot process" as detailed in the guide. The resulting `serials/<serial #>/RPI_EFI.fd` files are specific to the boards in use.

## Manually create the contianer

```shell
docker buildx build --platform linux/arm64,linux/amd64 --tag=ghcr.io/mcfio/raspberrypi4-uefi:latest --push=true -f ./Dockerfile .
```

## Configure Sidero Controller Manager

It is necessary to patch the Sidero controller manager deployment.

### Create the necessary patch file

```yaml
spec:
  template:
    spec:
      volumes:
        - name: tftp-folder
          emptyDir: {}
      initContainers:
      - image: ghcr.io/mcfio/raspberrypi4-uefi:latest
        imagePullPolicy: Always
        name: tftp-folder-setup
        command:
          - cp
        args:
          - -rv
          - /tftp
          - /var/lib/sidero/
        volumeMounts:
          - mountPath: /var/lib/sidero/tftp
            name: tftp-folder
      containers:
      - name: manager
        volumeMounts:
          - mountPath: /var/lib/sidero/tftp
            name: tftp-folder
```

### Apply the patch to the sidero-controller-manager container

```shell
kubectl -n sidero-system patch deployments.apps sidero-controller-manager --patch "$(cat patch.yaml)"
```
