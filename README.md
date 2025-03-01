# 📄 pdfsandwich-docker

A lightweight Docker image for **pdfsandwich**, a powerful OCR tool that adds searchable text layers to PDFs.

## 🚀 Features
- 🖥 **OCR Processing**: Converts scanned PDFs into searchable documents.
- 🌍 **Multilingual Support**: Supports multiple languages, including **Portuguese**.
- 🔄 **CLI-Friendly**: Designed for command-line usage with simple Docker execution.
- 📂 **Volume Mapping**: Process PDFs while keeping them in your local file system.

## 🛠 Installation & Usage

### Using Docker Directly
Run `pdfsandwich` inside the container:

```sh
docker run --rm -v "$(pwd):/data" alisio/pdfsandwich-docker input.pdf
```

### Using an Alias (Recommended)
For easier usage, create an alias:

```sh
alias pdfsandwich='docker run --rm -v "$(pwd):/data" alisio/pdfsandwich-docker'
```

Then, simply run:

```sh
pdfsandwich input.pdf
```

## 🏗 Building Locally
If you prefer to build the image yourself, clone this repository and run:

```sh
git clone https://github.com/alisio/pdfsandwich-docker.git
cd pdfsandwich-docker
docker build -t pdfsandwich-docker .
```

Then, use it as follows:

```sh
docker run --rm -v "$(pwd):/data" pdfsandwich-docker input.pdf
```

## 🛠 Multi-Architecture Support
This image supports **x86_64 (AMD64)** and **ARM64 (Apple Silicon)** architectures.

## 🔄 CI/CD Automation
This repository includes a **GitHub Actions** workflow that:
- Builds the image for multiple architectures
- Pushes the image to [DockerHub](https://hub.docker.com/r/alisio/pdfsandwich-docker)
- Triggers on pushes to the `main` branch

To set up automated publishing, make sure you add the following **GitHub Secrets**:
- `DOCKER_USERNAME` → Your DockerHub username
- `DOCKER_PASSWORD` → A DockerHub **Access Token** (not your password)

## 🔗 Repository & Contributions
- **DockerHub**: [hub.docker.com/r/alisio/pdfsandwich-docker](https://hub.docker.com/r/alisio/pdfsandwich-docker)
- **GitHub**: [github.com/alisio/pdfsandwich-docker](https://github.com/alisio/pdfsandwich-docker)

🚀 **Contributions are welcome!** Feel free to open an issue or a pull request.
