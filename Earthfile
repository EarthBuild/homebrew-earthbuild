VERSION 0.8
FROM debian
ENV NONINTERACTIVE=1
ENV HOMEBREW_NO_AUTO_UPDATE=1
ENV PATH="/home/linuxbrew/.linuxbrew/bin:/home/linuxbrew/.linuxbrew/sbin:${PATH}"
WORKDIR /home/linuxbrew/earthbuild-tap
RUN apt-get update && apt-get install -y curl git ca-certificates procps sudo build-essential
RUN useradd -m -s /bin/bash linuxbrew && \
    echo 'linuxbrew ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers && \
    chown -R linuxbrew:linuxbrew /home/linuxbrew
USER linuxbrew
RUN git config --global --add safe.directory /home/linuxbrew/earthbuild-tap && \
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)" && \
    /home/linuxbrew/.linuxbrew/bin/brew developer on

src:
    COPY --dir .git Formula .
    RUN brew tap EarthBuild/tap . && brew trust EarthBuild/tap

# check verifies the quality of the formula
check:
    BUILD +lint
    BUILD +test

# lint checks for Homebrew code quality
lint:
    BUILD +info
    BUILD +readall
    BUILD +audit
    BUILD +style
    BUILD +fetch
    BUILD +livecheck

# audit checks for Homebrew coding style violations
audit:
    FROM +src
    RUN brew audit --strict --online --except=specs --signing --debug --audit-debug EarthBuild/tap/earth

# style checks for conformance to Homebrew style guidelines
style:
    FROM +src
    RUN brew style --verbose --debug EarthBuild/tap/earth

# info checks that the formula parses correctly
info:
    FROM +src
    RUN brew info EarthBuild/tap/earth

# readall checks that all formulae in the tap can be successfully parsed
readall:
    FROM +src
    RUN brew readall EarthBuild/tap

# fetch verifies source URLs and sha256 checksums
fetch:
    FROM +src
    RUN brew fetch --build-from-source EarthBuild/tap/earth

# livecheck checks if there is a newer version available upstream
livecheck:
    FROM +src
    RUN brew livecheck EarthBuild/tap/earth

# test runs all tests
test:
    BUILD +test-install-bin
    BUILD +test-install-src
    BUILD +test-formula

# test-formula runs the built-in 'test do' block defined in the formula
test-formula:
    FROM +src
    RUN brew install --head --build-from-source --debug EarthBuild/tap/earth
    RUN brew test --verbose --debug EarthBuild/tap/earth

test-install-bin:
    FROM +src
    ENV HOMEBREW_DEVELOPER=1
    COPY +bottle-linux/earth--*.bottle.tar.gz ./bottles/
    RUN arch="$(uname -m)"; \
        if [ "$arch" = "aarch64" ]; then \
            bottle_file=$(ls ./bottles/earth--*.arm64_linux.bottle.tar.gz); \
        else \
            bottle_file=$(ls ./bottles/earth--*.x86_64_linux.bottle.tar.gz); \
        fi; \
        brew install --verbose "$bottle_file"
    RUN earth --version

test-install-src:
    FROM +src
    RUN brew install --head --build-from-source --debug EarthBuild/tap/earth

# bottle-linux builds a linux bottle for the host arch
bottle-linux:
    FROM +src
    RUN brew install --build-bottle EarthBuild/tap/earth
    RUN brew bottle --no-rebuild --json EarthBuild/tap/earth
    SAVE ARTIFACT earth--*.bottle.tar.gz AS LOCAL ./bottles/
    SAVE ARTIFACT earth--*.bottle.json AS LOCAL ./bottles/

# bottle-linux-all builds linux bottles for both amd64 and arm64
bottle-linux-all:
    BUILD --platform=linux/amd64 --platform=linux/arm64 +bottle-linux

# bottle-mac builds a macos bottle natively
bottle-mac:
    LOCALLY
    RUN mkdir -p bottles/
    RUN brew install --build-bottle EarthBuild/tap/earth
    RUN brew bottle --no-rebuild --json EarthBuild/tap/earth
    RUN mv earth--*.bottle.* bottles/

publish:
    FROM +src
    ARG GITHUB_REF
    ARG GITHUB_SHA
    ARG --required GIT_USER_EMAIL
    ARG --required GIT_USER_NAME

    # Copy the bottles built by the workflow
    COPY ./bottles ./bottles

    # Upload bottles to GHCR and update the formula bottle block
    RUN --secret HOMEBREW_GITHUB_PACKAGES_TOKEN=GITHUB_TOKEN \
        git config --global user.email "$GIT_USER_EMAIL" && \
        git config --global user.name "$GIT_USER_NAME" && \
        cd ./bottles && \
        brew pr-upload --debug --verbose

    # Merge into main and delete release branch
    # RUN --secret GITHUB_TOKEN=GITHUB_TOKEN \
    #     set -e && \
    #     GITHUB_REPOSITORY=$(git remote get-url origin | sed -E 's|.*github.com[:/]([^/]+/[^/.]+)(\.git)?|\1|') && \
    #     SHA=$(git rev-parse HEAD) && \
    #     git remote set-url origin https://x-access-token:$GITHUB_TOKEN@github.com/"$GITHUB_REPOSITORY" && \
    #     git fetch -a && \
    #     git checkout main && \
    #     git reset --hard origin/main && \
    #     git merge "$SHA" && \
    #     git push origin main && \
    #     git push origin --delete "$GITHUB_REF"
