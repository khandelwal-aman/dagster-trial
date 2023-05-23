# Canopy Pipeline Template

## Development

#### Requirements

- [Python 3.11+](https://www.python.org) - Runtime
- [Poetry](https://python-poetry.org) - Dependency management
- [AWS CLI v2](https://docs.aws.amazon.com/cli/latest/userguide/install-cliv2.html) - AWS CodeArtifact & ECR
- [GNU Make](https://www.gnu.org/software/make/) - _Usually pre-installed in major Linux Distributions_

#### Initializing the template for a new project

1. [Create a new repository using this template](https://github.com/Mesitis/canopy-pipeline-template/generate)
2. Ensure your repository name is under 30 characters (alphanumeric and hyphen seperated)
3. Clone the newly created repository locally
4. Run `make init-template` to initialize the template
5. Push your changes to the remote repository
6. Add your new repository as an _additional_ source on the [canopy-pipeline-modules](https://ap-southeast-1.console.aws.amazon.com/codesuite/codebuild/projects/canopy-pipeline-modules/edit/source?region=ap-southeast-1) codebuild project. (AWS Primary Account - ap-southeast-1 region) 
7. In [`canopy-pipeline`](https://github.com/Mesitis/canopy-pipeline/tree/main/deployment/environments) repository, edit the appropriate environments' `terragrunt.hcl` file to include the new project as code server in the input, commit & push. Example:
    
   ```hcl
   inputs = {
     #
     # ... other existing inputs
     #
    
     # Add additional code servers in (name = project-name) format
     dagster_code_servers   = {
       "some-name" = "project-name"
     }
    }
   ```

#### Setup

> Before proceeding, ensure you have AWS CLI Configured correctly with the right credentials.

```bash
# Install dependencies and perform first-time setup
make setup
```

#### Run tests

```bash
make test
```
