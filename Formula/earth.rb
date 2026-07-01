class Earth < Formula
  desc "Build automation tool for the container era"
  homepage "https://earthbuild.dev"
  url "https://github.com/EarthBuild/earthbuild.git",
      tag:      "v0.8.17",
      revision: "6babd00c58685413912e5e92bd22bb5c7ee993e8"
  license "MPL-2.0"
  head "https://github.com/EarthBuild/earthbuild.git", branch: "main"

  bottle do
    sha256 cellar: :any_skip_relocation, arm64_tahoe: "b1a590e3413b2461acf6c5eff91b6a92785198bfb043cf30794f24eba19e925e"
    sha256 cellar: :any_skip_relocation, arm64_linux: "5abd858ae7b281e0b9f29301243af80cd80e4562c01cd7e8480bc7aab37a9d78"
  end

  depends_on "go" => :build

  def install
    ENV["CGO_ENABLED"] = "0"
    ldflags = %W[
      -s -w
      -X main.DefaultBuildkitdImage=docker.io/earthbuild/buildkitd:v0.8.17
      -X main.Version=v#{version}
      -X main.GitSha=#{Utils.git_head}
      -X main.BuiltBy=homebrew-earthbuild
    ]
    tags = "dfrunmount dfrunsecurity dfsecrets dfssh dfrunnetwork dfheredoc forceposix"
    system "go", "build", "-tags", tags, "-trimpath", "-ldflags", ldflags.join(" "), "-o", "earth", "./cmd/earthly"
    bin.install "earth"
    bin.install_symlink "earth" => "earthly"

    generate_completions_from_executable(bin/"earth", "bootstrap", "--source", shells: [:bash, :zsh])
  end

  def caveats
    <<~EOS
      EarthBuild requires a container runtime to function.
      If you don"t have one, you can install Docker or Podman:
        brew install --cask docker
        OR
        brew install podman
    EOS
  end

  test do
    (testpath / "Earthfile").write <<~EOS
      VERSION 0.8
      mytesttarget:
      \tRUN echo Homebrew
    EOS
    output = shell_output("#{bin}/earth ls")
    assert_match "+mytesttarget", output
  end
end
