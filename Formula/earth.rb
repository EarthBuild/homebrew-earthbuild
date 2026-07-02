class Earth < Formula
  desc "Build automation tool for the container era"
  homepage "https://earthbuild.dev"
  version "0.8.17"
  license "MPL-2.0"

  on_macos do
    on_arm do
      url "https://github.com/EarthBuild/earthbuild/releases/download/v0.8.17/earth-darwin-arm64"
      sha256 "2e0a5e7b5623e2bfdab3e0be6bbbcb772f1d2ad6562132fbc3c9ce5564a939c1"
    end
    on_intel do
      url "https://github.com/EarthBuild/earthbuild/releases/download/v0.8.17/earth-darwin-amd64"
      sha256 "4ba8af21431b276edfacf8730e9372da1842ead0bc9bf0f6a014896afca97c96"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/EarthBuild/earthbuild/releases/download/v0.8.17/earth-linux-arm64"
      sha256 "bdc776167083e1bc4ec01379e88c6ae6372f52e4ea034e931865ff4ba030df63"
    end
    on_intel do
      url "https://github.com/EarthBuild/earthbuild/releases/download/v0.8.17/earth-linux-amd64"
      sha256 "85b7f31020be220493c1ef89fe4e976985a72e54dd12b7dfcf17544c8d4fd880"
    end
  end

  def install
    binary_name = if OS.mac?
      Hardware::CPU.arm? ? "earth-darwin-arm64" : "earth-darwin-amd64"
    else
      Hardware::CPU.arm? ? "earth-linux-arm64" : "earth-linux-amd64"
    end

    chmod 0755, binary_name
    bin.install binary_name => "earth"
    bin.install_symlink "earth" => "earthly"

    generate_completions_from_executable(bin/"earth", "bootstrap", "--source", shells: [:bash, :zsh])
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
    (testpath / "Earthfile").write <<~EOS
      VERSION 0.8
      mytesttarget:
      \tRUN echo Homebrew
    EOS
    output = shell_output("#{bin}/earth ls")
    assert_match "+mytesttarget", output
  end
end
