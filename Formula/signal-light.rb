class SignalLight < Formula
  desc "Local signal-light runtime for AI agent status display"
  homepage "https://github.com/starlight36/vibecoding-signal-light"
  version "0.1.1"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/starlight36/vibecoding-signal-light/releases/download/v0.1.1/signal-light-v0.1.1-macos-aarch64.tar.gz"
      sha256 "4365a2738919415908d65a1e48b534a695fe5e06cd6886f121f5b8d89cfee3c9"
    else
      url "https://github.com/starlight36/vibecoding-signal-light/releases/download/v0.1.1/signal-light-v0.1.1-macos-x86_64.tar.gz"
      sha256 "5e7d878a409cad87743d886d3caf333d8c51595df216c827c9104bd5e70e5890"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/starlight36/vibecoding-signal-light/releases/download/v0.1.1/signal-light-v0.1.1-linux-arm64.tar.gz"
      sha256 "60653a4cc84e6d553f109dedaeaba3ea869ae47cf2f531c612b8c7186220545a"
    else
      url "https://github.com/starlight36/vibecoding-signal-light/releases/download/v0.1.1/signal-light-v0.1.1-linux-amd64.tar.gz"
      sha256 "0c12873d9094271802b2e29f9e2f17404e5352b8ae4c44db92ddc94c902ac3b9"
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
