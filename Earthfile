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

# lint verify the formula for code quality
lint:
    BUILD +audit
    BUILD +style

# audit checks for Homebrew coding style violations
audit:
    FROM +src
    RUN brew audit --new --signing --debug --audit-debug EarthBuild/tap/earth

# style checks for conformance to Homebrew style guidelines
style:
    FROM +src
    RUN brew style --verbose --debug EarthBuild/tap/earth
