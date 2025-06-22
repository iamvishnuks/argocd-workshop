## Setup the clusters and argocd

### Prerequisites
- Ensure you have `make` installed on your system.
- yq is required for YAML processing. You can install it via Homebrew on macOS:
  ```bash
  brew install yq
  ```
  Or on Linux, you can use:
  ```bash
  sudo apt-get install yq
  ```
- Ensure you have `kubectl` installed.
- Ensure you have kubectl ctx plugin installed:
  ```bash
  kubectl krew install ctx
  ```

Run the following commands to set up the clusters and argocd:

```bash
make all
```
