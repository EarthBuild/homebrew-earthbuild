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

# lint checks for Homebrew code quality
lint:
    BUILD +audit
    BUILD +style

# audit checks for Homebrew coding style violations
audit:
    FROM +src
    RUN brew audit --except=specs --signing --debug --audit-debug EarthBuild/tap/earth

# style checks for conformance to Homebrew style guidelines
style:
    FROM +src
    RUN brew style --verbose --debug EarthBuild/tap/earth

test-install-bin:
    FROM +src
    RUN brew install --debug EarthBuild/tap/earth

test-install-src:
    FROM +src
    RUN brew install --head --build-from-source --debug EarthBuild/tap/earth

# bottle-arm64-linux builds an arm64 linux bottle and outputs the SHA
bottle-arm64-linux:
    FROM --platform=linux/arm64 +src
    RUN brew install --build-bottle EarthBuild/tap/earth
    RUN brew bottle --no-rebuild --json EarthBuild/tap/earth
    SAVE ARTIFACT earth--*.bottle.tar.gz AS LOCAL ./bottles/
    SAVE ARTIFACT earth--*.bottle.json AS LOCAL ./bottles/

# bottle-x86-linux builds an x86_64 linux bottle and outputs the SHA
bottle-x86-linux:
    FROM --platform=linux/amd64 +src
    RUN brew install --build-bottle EarthBuild/tap/earth
    RUN brew bottle --no-rebuild --json EarthBuild/tap/earth
    SAVE ARTIFACT earth--*.bottle.tar.gz AS LOCAL ./bottles/
    SAVE ARTIFACT earth--*.bottle.json AS LOCAL ./bottles/

# bottle-linux builds both linux bottles
bottle-linux:
    BUILD +bottle-arm64-linux
    BUILD +bottle-x86-linux
