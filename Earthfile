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
    SAVE ARTIFACT Formula
    SAVE ARTIFACT .git

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
    RUN brew fetch EarthBuild/tap/earth

# livecheck checks if there is a newer version available upstream
livecheck:
    FROM +src
    RUN brew livecheck EarthBuild/tap/earth

# test runs all tests
test:
    BUILD +test-install
    BUILD +test-formula

# test-install installs the pre-compiled binary
test-install:
    FROM +src
    RUN brew install EarthBuild/tap/earth
    RUN earth --version

# test-formula runs the built-in 'test do' block defined in the formula
test-formula:
    FROM +src
    RUN brew install EarthBuild/tap/earth
    RUN brew test --verbose --debug EarthBuild/tap/earth
