# Moodle Installer for Ubuntu

A Bash installation script for setting up Moodle with Apache, PHP, MariaDB, and Moodle data storage on Ubuntu servers.

## ✨ Features

- 🐧 Supports Ubuntu 20.04 and 22.04, as indicated by the original script.
- 🌐 Installs and enables Apache HTTP Server.
- 🐘 Installs PHP and commonly required extensions.
- 🗄️ Installs and configures MariaDB.
- 🎓 Downloads Moodle from its official GitHub repository.
- 🔐 Creates the Moodle database and database user.
- 📁 Prepares the Moodle application and data directories.

## 📋 Requirements

- Ubuntu server compatible with the selected Moodle release.
- Root access or a user with `sudo` privileges.
- Internet connectivity.
- Sufficient disk space, memory, and CPU resources.
- A hostname or server IP address for accessing Moodle.

## 🚀 Installation

### 1. Update system packages

```bash
sudo apt update
sudo apt upgrade -y
sudo apt install -y curl git
```

### 2. Download the installation script

**Standard installation:**

```bash
wget -O install.sh https://raw.githubusercontent.com/redhatmurali/Moodle-install/main/install.sh
```

**Installation with SSL-related setup:**

```bash
wget -O INSTALLWITHSSL.SH https://raw.githubusercontent.com/redhatmurali/Moodle-install/main/INSTALLWITHSSL.SH
```

### 3. Review the script

Before running the installer, inspect its contents:

```bash
less install.sh
```

### 4. Run the installer

```bash
chmod +x install.sh
sudo bash install.sh
```

For the SSL-related script, run:

```bash
chmod +x INSTALLWITHSSL.SH
sudo bash INSTALLWITHSSL.SH
```

Follow the prompts displayed by the installer.

## 🗄️ Database Configuration

The original installation script creates a MariaDB database named `moodle` and a database user named `moodleuser`.

**Security recommendation:** Generate a unique, strong database password before installation. Do not use the example password embedded in the original script, and do not publish database credentials in GitHub.

## 🌐 Access Moodle

After installation, open a browser and navigate to your server's configured URL.

Without HTTPS:

```text
http://YOUR_SERVER_IP/
```

If the installer configures a hostname and SSL, use the corresponding HTTPS URL.

## 🔒 Security Recommendations

- Configure HTTPS before exposing Moodle publicly.
- Use a unique database password.
- Keep Ubuntu, PHP, MariaDB, and Moodle updated.
- Configure firewall rules to allow only required services.
- Store Moodle's data directory outside the publicly accessible web root.
- Back up the database, Moodle data directory, and configuration.
- Verify that the PHP version and extensions meet the requirements of your chosen Moodle release.

## ⚠️ Compatibility Note

The original script references Ubuntu 20.04/22.04 and clones Moodle from GitHub. Compatibility depends on the Moodle branch and its PHP/database requirements.

Ubuntu 20.04 is no longer under standard security maintenance. For a new deployment, use a currently supported Ubuntu LTS release and a Moodle version compatible with it.

## 🔗 Repository

[View Moodle-install on GitHub](https://github.com/redhatmurali/Moodle-install)

## 📄 License

Add a `LICENSE` file if you intend to distribute this project for reuse.
