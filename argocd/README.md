# ArgoCD CLI Command Summary

ArgoCD is a declarative, GitOps continuous delivery tool for Kubernetes. The `argocd` CLI provides commands to manage applications, projects, and clusters. Below is a summary of key commands:

## Installation
- **Install CLI**: Download from the [official releases](https://github.com/argoproj/argo-cd/releases) or use a package manager like Homebrew (`brew install argocd`).

## Authentication
- **Login**: Log in to an ArgoCD server.
  ```
  argocd login <SERVER> --username <USERNAME> --password <PASSWORD>
  ```
  Example: `argocd login argocd.example.com --username admin --password secret`

- **Logout**: Log out from the current session.
  ```
  argocd logout <SERVER>
  ```

## Application Management
- **List Applications**: Display all applications.
  ```
  argocd app list
  ```

- **Create Application**: Create a new application from a Git repository.
  ```
  argocd app create <APPNAME> --repo <REPO_URL> --path <PATH> --dest-server <SERVER> --dest-namespace <NAMESPACE>
  ```
  Example: `argocd app create guestbook --repo https://github.com/argoproj/argocd-example-apps.git --path guestbook --dest-server https://kubernetes.default.svc --dest-namespace default`

- **Sync Application**: Synchronize an application to its desired state.
  ```
  argocd app sync <APPNAME>
  ```

- **Get Application Details**: View details of a specific application.
  ```
  argocd app get <APPNAME>
  ```

- **Delete Application**: Remove an application.
  ```
  argocd app delete <APPNAME>
  ```

## Project Management
- **List Projects**: Show all projects.
  ```
  argocd proj list
  ```

- **Create Project**: Create a new project.
  ```
  argocd proj create <PROJECT> -d <DEST_SERVER>,<NAMESPACE> -s <SOURCE_REPO>
  ```
  Example: `argocd proj create dev -d https://kubernetes.default.svc,default -s https://github.com/myorg/*`

## Cluster Management
- **Add Cluster**: Add a Kubernetes cluster to ArgoCD.
  ```
  argocd cluster add <CONTEXT>
  ```
  Example: `argocd cluster add my-cluster-context`

- **List Clusters**: Display all managed clusters.
  ```
  argocd cluster list
  ```

## Miscellaneous
- **Version**: Check the CLI and server version.
  ```
  argocd version
  ```

- **Help**: Get help for any command.
  ```
  argocd --help
  argocd <COMMAND> --help
  ```

## Notes
- Replace placeholders (e.g., `<APPNAME>`, `<REPO_URL>`) with actual values.
- Some commands support additional flags (e.g., `--insecure`, `--dry-run`). Check `argocd <COMMAND> --help` for details.
- Ensure you’re authenticated before running commands that interact with the server.

For more detailed documentation, visit the [official ArgoCD docs](https://argo-cd.readthedocs.io/en/stable/).
