# Multi-cloud security tooling (Linux)

Scripts and resources for multi-cloud (AWS, Azure, GCP) security tooling running on Linux. There's also a script for getting similar results on a Mac.

This repository contains:

- Scripts for various environments to setup a multi-cloud security Linux testing machine with tooling
- Example snippets to demonstrate how to run most of the services
- An example of a recommended networking setup
- Scripts to generate a virtual machine and network
- Scripts to tear down cloud resources
- Some external resources that might be of interest when working with security and pentesting

You should create and use a relevant pentesting IAM profile when using these tools so results are realistic.

## Scripts support the following environments

- **Amazon Web Services** EC2 (RHEL Linux 2)
- **Azure** VM (Ubuntu 18.04)
- **Google Cloud Platform** Compute Engine (Debian GNU 9)
- **Mac OS X**

## Tooling

The script installs:

- **Utilities**: [jq](https://stedolan.github.io/jq/), [Docker](https://docs.docker.com/)
- [Brew](https://brew.sh) (Only for Mac)
- [Python 3](https://www.python.org/downloads/)
- [wafw00f](https://github.com/EnableSecurity/wafw00f)
- [Nikto](https://github.com/sullo/nikto)
- [ScoutSuite](https://github.com/nccgroup/ScoutSuite)
- [Metasploit](https://www.metasploit.com)
- [Photon](https://github.com/s0md3v/Photon)

### AWS-specific tooling

- **Utilities**: [AWS CLI v2](https://docs.aws.amazon.com/cli/latest/userguide/install-cliv2.html), [Awsume](https://github.com/trek10inc/awsume)
- [Prowler](https://github.com/toniblyx/prowler)
- [S3Scanner](https://github.com/sa7mon/S3Scanner)
- [pacu](https://github.com/RhinoSecurityLabs/pacu)
- [LambdaGuard](https://github.com/Skyscanner/LambdaGuard)

#### Prowler IAM role (AWS-only)

For Prowler to work, you should ideally create (and use) an IAM user based on the SecurityAuditor managed role. Read more at [Prowler: IAM policy](https://github.com/toniblyx/prowler#custom-iam-policy) or [Prowler: Bootstrap script](https://github.com/toniblyx/prowler#bootstrap-script).

## Another solution: Kali Linux

If you want to run an extra setup (or just don't like CLIs) here's how you can get Kali Linux going on VirtualBox:

- [VirtualBox](https://www.virtualbox.org/wiki/Downloads)
- [Kali Linux images for VMware, VirtualBox and Hyper-V](https://www.offensive-security.com/kali-linux-vm-vmware-virtualbox-image-download/)
- [How to install Kali Linux on VirtualBox](https://itsfoss.com/install-kali-linux-virtualbox/)

## Cloud pentesting compliance

Make sure to check how and when you need to make a pentesting request with any of the clouds. Usually you don't need to do that anymore, since at least the multi-cloud tools should just use the respective API to pull data and then analyze it.

Always ensure that you only attempt to affect your own projects, resources and infrastructure. Also make sure that people in your organization that need to be informed of these activities know about the pentesting.

### AWS

Excerpt of the linked resources:

_AWS customers are welcome to carry out security assessments or penetration tests against their AWS infrastructure without prior approval for 8 services [...] Customers are not permitted to conduct any security assessments of AWS infrastructure, or the AWS services themselves._

Those eight permitted services are:

- Amazon EC2 instances, NAT Gateways, and Elastic Load Balancers
- Amazon RDS
- Amazon CloudFront
- Amazon Aurora
- Amazon API Gateways
- AWS Lambda and Lambda Edge functions
- Amazon Lightsail resources
- Amazon Elastic Beanstalk environments

Prohibited activities are:

- DNS zone walking via Amazon Route 53 Hosted Zones
- Denial of Service (DoS), Distributed Denial of Service (DDoS), Simulated DoS, Simulated DDoS
- Port flooding
- Protocol flooding
- Request flooding (login request flooding, API request flooding)

In case of "Other Simulated Events" should be emailed to an email address viewable in the below resources.

#### Resources

- [https://aws.amazon.com/security/penetration-testing/](https://aws.amazon.com/security/penetration-testing/)
- [https://aws.amazon.com/premiumsupport/knowledge-center/penetration-testing/](https://aws.amazon.com/premiumsupport/knowledge-center/penetration-testing/)

### Azure

Excerpt of the linked resources:

**Acceptable testing includes**

- _Tests on your endpoints to uncover the Open Web Application Security Project (OWASP) top 10 vulnerabilities_
- _Fuzz testing of your endpoints_
- _Port scanning of your endpoints_

_One type of test that you can’t perform is any kind of Denial of Service (DoS) attack. This includes initiating a DoS attack itself, or performing related tests that might determine, demonstrate or simulate any type of DoS attack._

#### References

- [https://docs.microsoft.com/en-us/azure/security/azure-security-pen-testing](https://docs.microsoft.com/en-us/azure/security/azure-security-pen-testing)
- [https://www.microsoft.com/en-us/msrc/pentest-rules-of-engagement)](https://www.microsoft.com/en-us/msrc/pentest-rules-of-engagement)

### Google Cloud Platform

#### References

- [https://cloud.google.com/terms/aup](https://cloud.google.com/terms/aup)
- [https://cloud.google.com/terms/](https://cloud.google.com/terms/)

## Suggested network configuration

I will use an example for how to set up the suggested networking for AWS. The settings and concepts are essentially the same for GCP and Azure.

### AWS example

#### VPC

Create or host the machine in its own secure VPC.

Suggested name: `PentestingMachines-VPC`
Suggested CIDR: `192.168.0.0/24`

#### Subnets

Create one subnet per Availability Zone in your new VPC.

Suggested name: `PentestingMachines-Subnet1a`
Suggested CIDR: `192.168.100.0/27`

Suggested name: `PentestingMachines-Subnet1b`
Suggested CIDR: `192.168.100.32/27`

Suggested name: `PentestingMachines-Subnet1c`
Suggested CIDR: `192.168.100.64/27`

#### Security Groups

Create a Security Group. Get your IP from [http://whatismyip.host](http://whatismyip.host) or a similar service.

Suggested name: `PentestingMachines-SG`

Inbound Rules:

- HTTP, Protocol: TCP, Port Range: 80, Source: `0.0.0.0/0`
- HTTP, Protocol: TCP, Port Range: 80, Source: `::/0`
- SSH, Protocol: TCP, Port Range: 22, Source: `XXX.XXX.XXX.XXX/32`
- HTTPS, Protocol: TCP, Port Range: 443, Source: `0.0.0.0/0`
- HTTPS, Protocol: TCP, Port Range: 443, Source: `::/0`

Outbound Rules:

- All Traffic, Protocol: All, Port Range: All, `0.0.0.0/0`

#### Network Access Control List (NACL)

Create a new Network Access Control List. Associate your NACL explicitly with your subnets. Get your IP from [http://whatismyip.host](http://whatismyip.host) or a similar service.

Suggested name: `PentestingMachines-NACL`

Inbound rules:

- **Rule #100**: SSH (22), Port Range: 22, Source: `XXX.XXX.XXX.XXX/32`, ALLOW
- **Rule #200**: All ICMP - IPv4, Port Range: ALL, Source: `0.0.0.0/0`, ALLOW
- **Rule #300**: All TCP, Port Range: 0-65535, Source: `0.0.0.0/0`, ALLOW
- **Rule \***: All Traffic, Port Range: ALL, Source: `0.0.0.0/0`, DENY

Outbound rules:

- **Rule \***: All Traffic, Port Range: ALL, Source: `0.0.0.0/0`, DENY

#### Internet Gateway

Create a new Internet Gateway.

Suggested name: `PentestingMachines-IGW`

#### Route Table

If you need a new route table, then create one. Associate your new (above) subnets explicitly with this route table.

Add a new route for `0.0.0.0/0` to point to your new Internet Gateway, so regular internet traffic can work correctly.

Suggested name: `PenPentestingMachines-RT`

#### Elastic IP

Allocate a new Elastic IP. Allow it to be reassociated. Associate your instance with this IP.

#### Launch the machine

Ensure that it uses your new security group and VPC!
