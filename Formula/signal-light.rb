class SignalLight < Formula
  desc "Local signal-light runtime for AI agent status display"
  homepage "https://github.com/starlight36/vibecoding-signal-light"
  version "0.1.4"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/starlight36/vibecoding-signal-light/releases/download/v0.1.4/signal-light-v0.1.4-macos-aarch64.tar.gz"
      sha256 "3163cac26e4edd76419658f34f59a016569da9fd7ea08b8eeb2fb1aad29740b3"
    else
      url "https://github.com/starlight36/vibecoding-signal-light/releases/download/v0.1.4/signal-light-v0.1.4-macos-x86_64.tar.gz"
      sha256 "f04d38fc0457c2e241ecd70c1b23f7dc43b837c0c6e242040c3329512d0fa57a"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/starlight36/vibecoding-signal-light/releases/download/v0.1.4/signal-light-v0.1.4-linux-arm64.tar.gz"
      sha256 "7b216953afd6a257c44fe74958cd6c81b59bea1d9010a42b4a8d4f305bb2e9f4"
    else
      url "https://github.com/starlight36/vibecoding-signal-light/releases/download/v0.1.4/signal-light-v0.1.4-linux-amd64.tar.gz"
      sha256 "6c7fa27c3670332564127a7a20ba08900568d373865d2a79501abca117db8e81"
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
