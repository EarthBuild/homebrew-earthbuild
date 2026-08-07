class Earth < Formula
  desc "Build automation tool for the container era"
  homepage "https://github.com/EarthBuild/earthbuild"
  version "0.8.18"
  license "MPL-2.0"

  on_macos do
    on_arm do
      url "https://github.com/EarthBuild/earthbuild/releases/download/v#{version}/earth-darwin-arm64"
      sha256 "261d3052e2de0fead72dbac2bdf0918285439a7cd78683833903b05e634ad163"
    end
    on_intel do
      url "https://github.com/EarthBuild/earthbuild/releases/download/v#{version}/earth-darwin-amd64"
      sha256 "507ca4435aa998c295ae68de956b77726df18ebb8a0e08bd97bb8544721664e2"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/EarthBuild/earthbuild/releases/download/v#{version}/earth-linux-arm64"
      sha256 "ea8aa6d2da74eb72256b249b2f6b2d87991480b716f45436da069c737517efcf"
    end
    on_intel do
      url "https://github.com/EarthBuild/earthbuild/releases/download/v#{version}/earth-linux-amd64"
      sha256 "ffca1ea1df2ce7b129b3424249b8cb7b4f62627fe2679a862021000f1a15054a"
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
