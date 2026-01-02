class Earth < Formula
  desc 'Build automation tool for the container era'
  homepage 'https://github.com/earthbuild'
  url 'https://github.com/EarthBuild/earthbuild.git',
      tag: 'v0.8.17-rc-0',
      revision: '52f2da6dd7f3de24a60a76e00044ec560b0ea407'
  license 'MPL-2.0'
  head 'https://github.com/EarthBuild/earthbuild.git', branch: 'main'

  bottle do
    sha256 cellar: :any_skip_relocation,
           arm64_tahoe: '194e4b767c3d1a551453ceb3739345c84de89533768b352e3b339d116497a238'
    sha256 cellar: :any_skip_relocation,
           arm64_linux: 'f7f743e111f7791301299c304b27fa1d4eda0a48b150c6270374fb360ee29b5b'
    sha256 cellar: :any_skip_relocation,
           x86_64_linux: '8eba8b430051d74be92b403116c7e510225bcc3a94fb8fec7f836f2959dd4227'
  end

  depends_on 'go' => :build

  def install
    ENV['CGO_ENABLED'] = '0'
    ldflags = %W[
      -s -w
      -X main.DefaultBuildkitdImage=docker.io/earthbuild/buildkitd:v0.8.17-rc-0
      -X main.Version=v#{version}
      -X main.GitSha=#{Utils.git_head}
      -X main.BuiltBy=homebrew-earthbuild
    ]
    tags = 'dfrunmount dfrunsecurity dfsecrets dfssh dfrunnetwork dfheredoc forceposix'
    system 'go', 'build', '-tags', tags, *std_go_args(ldflags: ldflags, output: bin / 'earth'), './cmd/earthly'

    bin.install_symlink 'earthly' => 'earth'

    generate_completions_from_executable(bin / 'earth', 'bootstrap', '--source', shells: %i[bash zsh])
  end

  def caveats
    <<~EOS
      EarthBuild requires a container runtime to function.
      If you don't have one, you can install Docker or Podman:
        brew install --cask docker
        OR
        brew install podman
    EOS
  end

  test do
    (testpath / 'Earthfile').write <<~EOS
      VERSION 0.8
      mytesttarget:
      \tRUN echo Homebrew
    EOS
    output = shell_output("#{bin}/earth ls")
    assert_match '+mytesttarget', output
  end
end
