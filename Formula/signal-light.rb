class SignalLight < Formula
  desc "Local signal-light runtime for AI agent status display"
  homepage "https://github.com/starlight36/vibecoding-signal-light"
  version "0.1.3"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/starlight36/vibecoding-signal-light/releases/download/v0.1.3/signal-light-v0.1.3-macos-aarch64.tar.gz"
      sha256 "8641482a966d50b13ea56b52d1ed64d23ca286802b551436776006d5e911edc5"
    else
      url "https://github.com/starlight36/vibecoding-signal-light/releases/download/v0.1.3/signal-light-v0.1.3-macos-x86_64.tar.gz"
      sha256 "87b15a1bbd507f369a9c35c56a8a221255272e5c28a6dfda740ed9415bdd95d1"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/starlight36/vibecoding-signal-light/releases/download/v0.1.3/signal-light-v0.1.3-linux-arm64.tar.gz"
      sha256 "e09c37b6310fa171093c274bbee848a394faf67b830f72b376ac0e74e1627daa"
    else
      url "https://github.com/starlight36/vibecoding-signal-light/releases/download/v0.1.3/signal-light-v0.1.3-linux-amd64.tar.gz"
      sha256 "f952ec66eda367cc3e4ddec254161baf33ad561009cbc28bced686b887b20680"
    end
  end

  def install
    package_dir = if (buildpath/"bin/signal-light-native").exist?
      buildpath
    else
      package_name = Dir["signal-light-v#{version}-*"].first
      odie "Cannot find unpacked signal-light release package" if package_name.nil?
      buildpath/package_name
    end

    cd package_dir do
      libexec.install "bin", "scripts"
      libexec.install "README.md"
      libexec.install "RELEASE.txt"
      libexec.install "docs"
    end

    bin.write_exec_script libexec/"scripts/signal-light"
    (bin/"signal-light-install-hooks").write <<~SH
      #!/bin/bash
      exec "#{libexec}/scripts/install-hooks" "$@"
    SH
    (bin/"codex-signal-hook").write <<~SH
      #!/bin/bash
      exec "#{libexec}/scripts/codex-signal-hook" "$@"
    SH
    (bin/"claude-code-signal-hook").write <<~SH
      #!/bin/bash
      exec "#{libexec}/scripts/claude-code-signal-hook" "$@"
    SH
  end

  def caveats
    <<~EOS
      Install or repair Codex and Claude Code hooks with:
        signal-light-install-hooks --all -y

      Preview without hardware:
        signal-light play working --dry-run
    EOS
  end

  test do
    assert_match "Signal language:", shell_output("#{bin}/signal-light list")
    assert_match "green=", shell_output("#{bin}/signal-light play working --dry-run")
  end
end
