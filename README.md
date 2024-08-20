# Setup Certificate and Proxy Script

This script automates the process of installing a proxy certificate and configuring proxy settings on Linux systems. It is designed to work with both Ubuntu and RHEL-based distributions (including CentOS and Fedora).

## Features

- **Certificate Installation**: 
  - The script installs a proxy certificate by saving the provided certificate content to a `.crt` file and placing it in the appropriate directory based on the operating system.
  - It updates the system's certificate store to ensure the new certificate is recognized.

- **Proxy Configuration**: 
  - The script allows the user to input proxy settings, including the proxy URL and additional `no_proxy` domains.
  - Automatically includes the machine's IP address, network segment (assuming a `/24` subnet), `localhost`, and `127.0.0.1` in the `no_proxy` configuration.
  - The proxy settings are applied to the current session and can be optionally persisted for future sessions.

- **System Update**: 
  - After configuring the certificate and proxy, the script updates the system's package list and installs available upgrades.

## Usage

1. **Save the script**: Save the script to a file with a `.sh` extension (e.g., `setup_certificate_and_proxy.sh`).

2. **Make the script executable** (optional):
   ```bash
   chmod +x setup_certificate_and_proxy.sh

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.   
