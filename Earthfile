VERSION 0.8
FROM homebrew/brew:4.6.20
ENV HOMEBREW_NO_AUTO_UPDATE=1
WORKDIR /home/linuxbrew/earthbuild-tap
RUN brew developer on

src:
    COPY --dir .git Formula .
    RUN brew tap EarthBuild/tap .

# lint verify the formula for code quality
lint:
    BUILD +audit
    BUILD +style

# audit the formula
audit:
    FROM +src
    RUN brew audit --new --signing --debug --audit-debug EarthBuild/tap/earth

# style check the formula
style:
    FROM +src
    RUN brew style --verbose --debug EarthBuild/tap/earth
