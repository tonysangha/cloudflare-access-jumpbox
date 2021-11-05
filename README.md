# Cloudflare Access Jumpbox

The following guide provides a breakdown on how to create a Linux (Debian) Virtual Machine (VM) hosted on Google Cloud Platform using [Terraform](https://www.terraform.io/), and remote access secured using [Cloudflare Access](https://blog.cloudflare.com/introducing-cloudflare-access/). 

The VM is configured with no inbound connectivity, secured using Google's VPC firewall. The authroized user has inbound connectivity to the VM using Cloudflare Access. This allows authenticated users to access the Jumpbox without needing to remember the IP address, uploading public ssh keys, or requiring a terminal. All access to the VM in this example is controlled via the use of a One Time Pin that is sent to users who have an email address in a designated domain. Access can also intergrate with other [SSO providers](https://developers.cloudflare.com/cloudflare-one/identity/idp-integration).

![ssh_console_browser_snippet.png](./img/ssh_console_browser_snippet.png)

The following diagram depicts the logical overview of the setup:

![cloudflare-access-overview.png](./img/cloudflare-access-overview.png)

## Requirements

To run the Terraform Plan, you need to ensure the following have been setup prior:

- Terraform installed locally
- gCloud authentication 
- Cloudflare API token and Zone setup
