# tofu-exploration

An example of using [opentofu]()'s latest 1.9 release features including;

- Encrypted State
- Provider iteration

The result of this will be a set of 2 local kind kubernetes clusters along with localized/encrypted state suitable for storing in git.

# Requirements

To use this project, you need to have the following requirements met:

1. **Mise**: Ensure you have [mise](https://mise.jdx.dev/) activated in your terminal. Mise is a tool that helps manage your development environment on a per-folder basis. This is incredibly useful for polyglot coding like this particular example. I find it to be less overhead than devcontainers. It does not replace virtual environments but can augment your use of them. It als replaces direnv for automatic loading of variables and secrets and more.

2. Docker/containerd

3. Linux/osx

**NOTE** Make sure to have mise activated before running the script to avoid any issues.

# Using

**configure.sh**: Run the `configure.sh` script to set up your environment. This script will configure necessary dependencies and settings for the project.

```sh
./configure.sh
# Use this for further tasks if not already in your profile
eval "$(mise activate bash)"
```

Run `task` at any time to see a list of additional tasks. For this example most tasks are at the root `Taskfile.yml` manifest.

To deploy run `task deploy:all`

To destroy run `task destroy`

## About

There are two branches so you can better diff the changes between the terraform version of this code vs. the updated tofu version.

**main** - terraform based deployment
**tofu** - tofu based deployment (go to this branch for tofu related notes and tasks)

# Tips

- This builds two kube clusters then drops private keys and kube config locally in ~~a .gitignore defined~~ the `./secrets` path. You can use this to your advantage and target that folder with sops to encrypt things per cluster with just a wee bit more work ;)

- You can use [OpenLens](https://github.com/MuhammedKalkan/OpenLens) to explore your local cluster by pointing it at the kube config file.

- Most everything can be configured in the `Taskfile.yml` file, including if you'd like to use tofu or terraform. Fun for testing some of the new tofu features out as shown here.

- If `task deploy:all` fails try `task deploy`. If that fails try removing the cluster `kind delete cluster -n cluster1`

# Terraform Version

This main branch version includes terraform manifests for deploying 2 kind clusters side by side. The state is stored for each component as separate terraform state files in the `./secrets` folder. This folder is then targeted with `sops` to encrypt contents within.

To run through the multiple terraform states I could have used workspaces perhaps but it was simpler to just target another file locally and use taskfile tricks to do multiple stacks in a row.

```bash
# Bring cluster1 and cluster2 up
task deploy:all

# Here you should review secrets and other state stuff in ./secrets. Don't commit this to git!

# Tear them down
task destroy:all
```
