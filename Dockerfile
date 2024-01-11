# Start from the code-server Debian base image
FROM codercom/code-server:4.9.0

USER root

# Install dependencies for Podman
RUN apt-get update && apt-get install -y software-properties-common uidmap

# Add the Podman repository
RUN . /etc/os-release && \
    sh -c "echo 'deb http://download.opensuse.org/repositories/devel:/kubic:/libcontainers:/stable/Debian_$VERSION_ID/ /' > /etc/apt/sources.list.d/devel:kubic:libcontainers:stable.list" && \
    wget -nv https://download.opensuse.org/repositories/devel:kubic:libcontainers:stable/Debian_$VERSION_ID/Release.key -O Release.key && \
    apt-key add - < Release.key && \
    apt-get update

# Install Podman
RUN apt-get -y install podman

# Switch back to the coder user
USER coder

# Apply VS Code settings
COPY deploy-container/settings.json .local/share/code-server/User/settings.json

# Use bash shell
ENV SHELL=/bin/bash

# Install unzip + rclone (support for remote filesystem)
RUN sudo apt-get update && sudo apt-get install unzip -y
RUN curl https://rclone.org/install.sh | sudo bash

# Copy rclone tasks to /tmp, to potentially be used
COPY deploy-container/rclone-tasks.json /tmp/rclone-tasks.json

# Fix permissions for code-server
RUN sudo chown -R coder:coder /home/coder/.local

# You can add custom software and dependencies for your environment below
# -----------

# Install NodeJS
RUN sudo curl -fsSL https://deb.nodesource.com/setup_21.x | sudo bash -
RUN sudo apt-get install -y nodejs

# Port
ENV PORT=8080

# Use our custom entrypoint script first
COPY deploy-container/entrypoint.sh /usr/bin/deploy-container-entrypoint.sh
ENTRYPOINT ["/usr/bin/deploy-container-entrypoint.sh"]
