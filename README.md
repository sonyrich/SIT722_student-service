# Student Service

A containerized Node.js/Express microservice deployed to Azure App Service with
a **blue-green, zero-downtime CI/CD pipeline**. The pipeline provisions
infrastructure with Terraform, validates each release in a staging slot, blocks
unsafe production swaps, and sends Discord deployment alerts.

Built for SIT722 Cloud Software Deployment, 10.3HD.

## Architecture

```text
Push to main
     │
     ▼
00 · Terraform ──────► Provision or update Azure infrastructure
     │
     ▼
01 · CI ─────────────► Test → Build image → Push to Azure Container Registry
     │
     ▼
02 · Deploy Staging ─► Update staging slot (green)
     │
     ▼
03 · Smoke Test ─────► Request staging /health
     │           └──► Failure: Discord alert; production swap is blocked
     ▼ Success
04 · Deploy Production ► Swap staging ↔ production; Discord success alert
```

| Blue-green role | Azure deployment slot | Purpose |
|---|---|---|
| Blue | `production` | Live application serving user traffic |
| Green | `staging` | Candidate release, tested before production promotion |

A new container image is deployed to the staging slot first. The production
slot remains unchanged until the staging health check returns HTTP 200. A
failed smoke test stops the pipeline before the slot swap, leaving the known
good production version online.

## Technology

- **Application:** Node.js 24, Express, `node:sqlite`
- **Container:** Docker (`node:24-slim`)
- **Cloud:** Azure Container Registry and Linux Azure App Service on a
  Standard S1 plan with deployment slots
- **Infrastructure as code:** Terraform
- **Automation:** GitHub Actions
- **Registry authentication:** System-assigned managed identities with the
  Azure `AcrPull` role; no ACR password is stored in the repository
- **Notifications:** Discord webhook

## Repository Layout

```text
src/                        Node.js application (MVC)
tests/                      Automated tests
terraform/                  Azure infrastructure configuration
.github/workflows/
  00-terraform.yml          Provision/update Azure infrastructure
  01-ci.yml                 Test, build, and push the image
  02-deploy-staging.yml     Deploy image to the staging slot
  03-staging-test.yml       Smoke test and failure alert
  04-deploy-production.yml  Slot swap and success alert
Dockerfile                  Container build definition
```

## GitHub Configuration

Before running the pipeline, configure the repository at:

**Repository → Settings → Secrets and variables → Actions**

The pipeline uses two **repository secrets** and four **repository variables**.
Secrets are encrypted and masked in workflow logs; variables are appropriate
for non-sensitive resource names.

### Add Azure credentials

The `AZURE_CREDENTIALS` secret lets GitHub Actions authenticate to Azure for
Terraform, ACR image pushes, staging deployment, and production slot swaps.

1. Sign in to Azure CLI with the subscription used for this project:

   ```bash
   az login
   az account set --subscription "subscription-Id"
   ```

2. Create a service principal, or use an existing project service principal,
   with sufficient access. For this demo, Contributor at subscription scope is
   sufficient for the deployed resources:

   ```bash
   az ad sp create-for-rbac \
     --name "student-service-github-actions" \
     --role Contributor \
     --scopes "/subscriptions/subscription-Id" \
     --sdk-auth
   ```

3. Copy the complete JSON output. Do **not** commit it, save it in source
   files, or paste it into an issue/PR.

4. In GitHub, choose **New repository secret** and enter:

   | Field | Value |
   |---|---|
   | Name | `AZURE_CREDENTIALS` |
   | Secret | The complete JSON output from the previous command |

5. If the service principal already exists, regenerate or retrieve credentials
   according to your Azure tenant policy, then replace the secret value. The
   JSON used by the workflows must contain `clientId`, `clientSecret`,
   `subscriptionId`, and `tenantId`.

### Add Discord webhook

`DISCORD_WEBHOOK` enables the failure alert in workflow 03 and the production
success alert in workflow 04.

1. In Discord, open the server and channel where deployment notifications
   should appear.
2. Open **Edit Channel → Integrations → Webhooks → New Webhook**.
3. Give it a clear name, such as `Student Service Deploy Bot`, and select the
   intended notification channel.
4. Click **Copy Webhook URL**.
5. In GitHub, choose **New repository secret** and enter:

   | Field | Value |
   |---|---|
   | Name | `DISCORD_WEBHOOK` |
   | Secret | The copied Discord webhook URL |

Treat the URL like a password: anyone who has it can post messages to that
Discord channel.

### Add repository variables

Select the **Variables** tab, then select **New repository variable** for each
entry below:

| Name | Value | Purpose |
|---|---|---|
| `ACR_NAME` | `sonyrichstudentacr` | Azure Container Registry name |
| `APP_NAME` | `app-student-service-sony` | Azure App Service name |
| `RESOURCE_GROUP` | `sonyng-hd-rg` | Azure resource group |
| `IMAGE_NAME` | `student-service` | Docker repository name within ACR |

For a cloned deployment, replace these names with globally unique Azure names
and update `terraform/terraform.tfvars` to match. The names in GitHub
variables must match the Terraform configuration.

## Provision and Deploy

### 1. Provision infrastructure

Run **00 - Terraform** from the GitHub Actions tab, or push a change under
`terraform/`. It validates, plans, and applies the Terraform configuration.

The Terraform workflow is intended to use an Azure Blob remote backend so that
state is shared between local and CI runs. This makes repeated applies
idempotent: a later run updates only differences instead of attempting to
recreate existing resources.

### 2. Run the application pipeline

Push a commit to `main`, or manually run **01 - CI**. A successful run starts
the chained deployment sequence:

```text
01 - CI → 02 - Deploy to Staging → 03 - Staging Smoke Test → 04 - Deploy Production
```

If staging `/health` does not return HTTP 200, workflow 03 fails, posts a
Discord failure notification, and workflow 04 does not run.

## Local Development

```bash
npm install
npm test
npm start
```

The service listens on port 3000 by default.

```bash
curl http://localhost:3000/health
```

Build and run the container locally:

```bash
docker build -t student-service .
docker run -p 3000:3000 student-service
```

## Verify Zero Downtime

During workflow 04, poll the production health endpoint from a separate
terminal. HTTP 200 responses should continue throughout the slot swap.

```bash
while true; do
  curl -s -o /dev/null -w "%{http_code} %{time_total}s\n" \
    https://app-student-service-sony.azurewebsites.net/health
  sleep 1
done
```

## Design Decisions

- **Standard S1 App Service plan:** Basic plans do not support deployment
  slots.
- **Managed identity and `AcrPull`:** App Service authenticates to ACR without
  registry passwords in Terraform, GitHub, or application settings.
- **Staging smoke-test gate:** An unhealthy release cannot be swapped into
  production.
- **Direct Azure CLI staging deployment:** `az webapp config container set`
  is used instead of `azure/webapps-deploy` after the action's deployment
  status polling proved unreliable against stale Kudu deployment records.
