VERSION 0.8
FROM homebrew/brew:4.6.20
ENV HOMEBREW_NO_AUTO_UPDATE=1
WORKDIR /home/linuxbrew/earthbuild-tap
RUN brew developer on

src:
    COPY --dir Formula .
    RUN \
        git config --global init.defaultBranch main && \
        git init && \
        git config user.email "local@local" && \
        git config user.name "local" && \
        git add . && \
        git commit -m "local snapshot"
    RUN brew tap EarthBuild/tap .

# check verifies the quality of the formula
check:
    BUILD +lint
    BUILD +test

# lint checks for Homebrew code quality
lint:
    BUILD +info
    BUILD +audit
    BUILD +style

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
