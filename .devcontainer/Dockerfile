# Multi-stage build for optimized image
FROM eclipse-temurin:21-jdk-alpine AS base

# Build arguments
ARG TERRAFORM_VERSION=1.7.5
ARG GRADLE_VERSION=8.5
ARG CLAUDE_CODE_VERSION=latest
ARG TZ=Asia/Seoul

# Environment setup
ENV TZ=$TZ \
    JAVA_HOME=/opt/java/openjdk \
    DEVCONTAINER=true \
    SHELL=/bin/zsh

# Install essential packages
RUN apk add --no-cache \
    bash curl wget git sudo openssh-client tar gzip zip unzip \
    python3 py3-pip nodejs npm \
    mysql-client postgresql-client redis \
    iptables ip6tables ipset iproute2 bind-tools \
    jq yq vim nano zsh shadow \
    build-base linux-headers

# Create non-root user
RUN addgroup -g 1000 developer && \
    adduser -D -u 1000 -G developer -s /bin/zsh developer && \
    echo "developer ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/developer && \
    chmod 0440 /etc/sudoers.d/developer

# Install Gradle
RUN wget -q https://services.gradle.org/distributions/gradle-${GRADLE_VERSION}-bin.zip && \
    unzip -q gradle-${GRADLE_VERSION}-bin.zip -d /opt && \
    rm gradle-${GRADLE_VERSION}-bin.zip
ENV GRADLE_HOME=/opt/gradle-${GRADLE_VERSION}
ENV PATH=$PATH:$GRADLE_HOME/bin

# Install Terraform
RUN wget -q https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip && \
    unzip -q terraform_${TERRAFORM_VERSION}_linux_amd64.zip -d /usr/local/bin && \
    rm terraform_${TERRAFORM_VERSION}_linux_amd64.zip && \
    chmod +x /usr/local/bin/terraform

# Install AWS CLI v2
RUN pip3 install --no-cache-dir --break-system-packages \
    awscli \
    boto3 \
    terraform-compliance \
    checkov

# Install Spring Boot CLI (optional - skip if download fails)
RUN echo "Installing Spring Boot CLI..." && \
    (wget -q --timeout=30 https://repo1.maven.org/maven2/org/springframework/boot/spring-boot-cli/3.3.5/spring-boot-cli-3.3.5-bin.tar.gz -O spring-boot-cli.tar.gz && \
     mkdir -p /opt/spring && \
     tar -xzf spring-boot-cli.tar.gz -C /opt/spring --strip-components=1 && \
     rm spring-boot-cli.tar.gz && \
     ln -sf /opt/spring/bin/spring /usr/local/bin/spring && \
     chmod +x /usr/local/bin/spring && \
     echo "✅ Spring Boot CLI installed successfully") || \
    echo "⚠️ Spring Boot CLI installation skipped - will use Gradle instead"

# Install additional development tools
RUN npm install -g @anthropic-ai/claude-code@${CLAUDE_CODE_VERSION} \
    prettier \
    eslint \
    typescript

# Create necessary directories
RUN mkdir -p /workspace /home/developer/.claude /home/developer/.config \
    /home/developer/.gradle /home/developer/.m2 /home/developer/.terraform.d && \
    chown -R developer:developer /workspace /home/developer

# Copy configuration scripts
COPY --chown=developer:developer init-firewall.sh /usr/local/bin/
COPY --chown=developer:developer setup-dev-env.sh /usr/local/bin/
COPY --chown=developer:developer scripts/*.sh /usr/local/bin/

# Make scripts executable
RUN chmod +x /usr/local/bin/*.sh && \
    echo "developer ALL=(root) NOPASSWD: /usr/local/bin/init-firewall.sh" > /etc/sudoers.d/developer-firewall && \
    chmod 0440 /etc/sudoers.d/developer-firewall

# Switch to developer user
USER developer
WORKDIR /workspace

# Install Oh My Zsh and plugins
RUN sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended && \
    git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions && \
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting && \
    sed -i 's/plugins=(git)/plugins=(git zsh-autosuggestions zsh-syntax-highlighting docker terraform aws gradle spring)/' ~/.zshrc

# Add useful aliases
RUN echo 'alias ll="ls -la"' >> ~/.zshrc && \
    echo 'alias gs="git status"' >> ~/.zshrc && \
    echo 'alias gp="git pull"' >> ~/.zshrc && \
    echo 'alias tf="terraform"' >> ~/.zshrc && \
    echo 'alias gradle="gradle --no-daemon"' >> ~/.zshrc && \
    echo 'alias claude-help="/usr/local/bin/start-claude.sh"' >> ~/.zshrc

# Set environment variables
ENV PATH=$PATH:/usr/local/bin:/opt/gradle-${GRADLE_VERSION}/bin:/opt/spring-3.3.5/bin

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD curl -f http://localhost:8080/actuator/health || exit 1

# Default command
CMD ["/bin/zsh"]