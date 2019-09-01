# 2019 September 1
#
# The author disclaims copyright to this source code.  In place of
# a legal notice, here is a blessing:
#
#    May you do good and not evil.
#    May you find forgiveness for yourself and forgive others.
#    May you share freely, never taking more than you give.

FROM node:lts

ARG BUILD_DATE=none
ARG VCS_REF=none
ARG IMAGE_VERSION=1.0.0
ARG IMAGE_NAME=lsimons/devcontainer

ARG COMPOSE_VERSION=1.24.1
ARG PS_VERSION=6.2.2
ARG PS_PACKAGE=powershell_${PS_VERSION}-1.debian.9_amd64.deb
ARG PS_PACKAGE_URL=https://github.com/PowerShell/PowerShell/releases/download/v${PS_VERSION}/${PS_PACKAGE}

# Avoid warnings by switching to noninteractive
ENV DEBIAN_FRONTEND=noninteractive \
    # set a fixed location for the Module analysis cache
    PSModuleAnalysisCachePath=/var/cache/microsoft/powershell/PSModuleAnalysisCache/ModuleAnalysisCache

# Download the PowerShell package and save it
ADD ${PS_PACKAGE_URL} /tmp/powershell.deb

RUN \
    #
    # Ensure latest package index
    apt-get update \
    #
    # Install apt-utils early to avoid warning messages
    && apt-get -y install apt-utils \
    #
    # Ensure UTF-8 support
    && apt-get -y install locales \
    && sed --in-place '/en_US.UTF-8/s/^#//' /etc/locale.gen \
    && locale-gen

# Define ENVs for Localization/Globalization
ENV DOTNET_SYSTEM_GLOBALIZATION_INVARIANT=false \
    LC_ALL=en_US.UTF-8 \
    LANG=en_US.UTF-8 \
    LANGUAGE=en_US:en

RUN \
    #
    # Upgrade all the things
    apt-get dist-upgrade -y \
    #
    # Install tools needed for build as well as common libraries
    && apt-get -y install \
        apt-transport-https \
        ca-certificates \
        curl \
        dbus \
        dialog \
        dnsutils \
        dpkg \
        fakeroot \
        file \
        ftp \
        git \
        gnupg2 \
        gnupg-agent \
        gss-ntlmssp \
        iproute2 \
        iputils-ping \
        jq \
        less \
        libcurl3 \
        libgconf-2-4 \
        libgtk-3-0 \
        libsecret-1-dev \
        libunwind8 \
        libxkbfile-dev \
        libxss1 \
        lsb-release 2>&1 \
        netcat \
        openssh-client \
        pkg-config \
        procps \
        python \
        python-pip \
        python3 \
        python3-pip \
        rpm \
        rsync \
        shellcheck \
        software-properties-common \
        sudo \
        telnet \
        time \
        tzdata \
        unzip \
        wget \
        xorriso \
        xvfb \
        xz-utils \
        zip \
        zsync \
    #
    # Set up Microsoft/Azure apt repos
    && curl -fsSL https://packages.microsoft.com/keys/microsoft.asc | (OUT=$(apt-key add - 2>&1) || echo $OUT) \
    && add-apt-repository "deb [arch=amd64] https://packages.microsoft.com/repos/azure-cli/ $(lsb_release -cs) main" \
    && add-apt-repository "deb [arch=amd64] https://packages.microsoft.com/repos/microsoft-debian-$(lsb_release -cs)-prod $(lsb_release -cs) main" \
    #
    # Set up Docker CE apt repo
    && curl -fsSL https://download.docker.com/linux/$(lsb_release -is | tr '[:upper:]' '[:lower:]')/gpg | (OUT=$(apt-key add - 2>&1) || echo $OUT) \
    && add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/$(lsb_release -is | tr '[:upper:]' '[:lower:]') $(lsb_release -cs) stable" \
    #
    # Set up Kubernetes apt repo
    && curl -fsSL https://packages.cloud.google.com/apt/doc/apt-key.gpg | (OUT=$(apt-key add - 2>&1) || echo $OUT) \
    && add-apt-repository "deb http://apt.kubernetes.io/ kubernetes-xenial main" \
    #
    # Apt update for the new repos
    && apt-get update \
    #
    # Install Azure Functions, .NET Core, and Azure CLI
    && apt-get install -y azure-cli dotnet-sdk-2.1 azure-functions-core-tools \
    && az extension add -n azure-devops \
    #
    # Install Docker CE CLI, Docker Compose, kubectl, Helm
    && apt-get install -y docker-ce-cli \
    && curl -fsSL "https://github.com/docker/compose/releases/download/${COMPOSE_VERSION}/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose \
    && chmod +x /usr/local/bin/docker-compose \
    && apt-get install -y kubectl \
    && curl -fsSL "https://git.io/get_helm.sh" | bash \
    && helm init --client-only \
    #
    # Install powershell
    && apt-get install -y /tmp/powershell.deb \
    #
    # Install Az powershell library
    && pwsh -NoLogo -NoProfile -NonInteractive -Command " \
        \$ErrorActionPreference = 'Stop' ; \
        \$ProgressPreference = 'SilentlyContinue' ; \
        Set-PSRepository -Name PSGallery -InstallationPolicy Trusted ; \
        Install-Module -AcceptLicense -Name Az" >/dev/null \
    #
    # Initialize powershell module cache
    && pwsh -NoLogo -NoProfile -NonInteractive -Command " \
          \$ErrorActionPreference = 'Stop' ; \
          \$ProgressPreference = 'SilentlyContinue' ; \
          while(!(Test-Path -Path \$env:PSModuleAnalysisCachePath)) {  \
            Write-Host "'Waiting for $env:PSModuleAnalysisCachePath'" ; \
            Start-Sleep -Seconds 6 ; \
          }" >/dev/null \
    #
    # Install some node libraries globally
    && npm install -g eslint tslint typescript \
    #
    # Clean up
    && apt-get autoremove -y \
    && apt-get clean -y \
    && rm -rf /var/lib/apt/lists/* \
    && rm /tmp/powershell.deb

# Switch back to dialog for any ad-hoc use of apt-get
ENV DEBIAN_FRONTEND=

LABEL maintainer="Leo Simons <mail at leosimons dot com>" \
      readme.md="https://github.com/lsimons/devcontainer-tsazure/blob/master/README.md" \
      description="VSCode devcontainer with azure, node, typescript, azure functions." \
      org.label-schema.name="${IMAGE_NAME}" \
      org.label-schema.version="${IMAGE_VERSION}" \
      org.label-schema.build-date="${BUILD_DATE}" \
      org.label-schema.url="https://github.com/lsimons/devcontainer-tsazure/blob/master/README.md" \
      org.label-schema.vcs-url="https://github.com/lsimons/devcontainer-tsazure" \
      org.label-schema.vcs-ref="${VCS_REF}" \
      org.label-schema.schema-version="1.0"
