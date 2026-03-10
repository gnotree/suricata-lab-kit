![CI](https://github.com/cyberiancherubim/suricata-lab-kit/actions/workflows/ci.yml/badge.svg)
![CodeQL](https://github.com/cyberiancherubim/suricata-lab-kit/actions/workflows/codeql.yml/badge.svg)
![License](https://img.shields.io/github/license/cyberiancherubim/suricata-lab-kit)
![Last commit](https://img.shields.io/github/last-commit/cyberiancherubim/suricata-lab-kit)
![Stars](https://img.shields.io/github/stars/cyberiancherubim/suricata-lab-kit)
![Issues](https://img.shields.io/github/issues/cyberiancherubim/suricata-lab-kit)

# suricata-lab-kit

Suricata lab kit; deploy scripts; ruleset management; validated configs; training datasets.

## Features

- Automated Suricata installation scripts for RHEL/CentOS systems
- Pre-validated Suricata configuration files
- CI/CD integration with GitHub Actions
- Security analysis with CodeQL
- Configuration validation tools

## Quick Installation (RHEL 10)

For a quick, automated installation on RHEL 10, run:

```bash
curl -sSL https://raw.githubusercontent.com/cyberiancherubim/suricata-lab-kit/main/scripts/rhel_install.sh | sudo bash
```

Or clone the repository and run locally:

```bash
git clone https://github.com/cyberiancherubim/suricata-lab-kit.git
cd suricata-lab-kit
sudo ./scripts/rhel_install.sh
```

## Manual Installation

1. Clone this repository
2. Review the configuration files in `configs/`
3. Run the validation script: `./scripts/10_validate_suricata.sh`

## Repository Structure

- `configs/` - Validated Suricata configuration files
- `scripts/` - Installation and validation scripts
- `.github/workflows/` - CI/CD workflows

## License

See [LICENSE](LICENSE) for details.
