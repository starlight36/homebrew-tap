class SignalLight < Formula
  desc "Local signal-light runtime for AI agent status display"
  homepage "https://github.com/starlight36/vibecoding-signal-light"
  version "0.1.2"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/starlight36/vibecoding-signal-light/releases/download/v0.1.2/signal-light-v0.1.2-macos-aarch64.tar.gz"
      sha256 "e56489e76bdc1e1704fe27ed8d501cfbf8d1caa40ed17b84e24e4e3adb3a57e2"
    else
      url "https://github.com/starlight36/vibecoding-signal-light/releases/download/v0.1.2/signal-light-v0.1.2-macos-x86_64.tar.gz"
      sha256 "aba0496a5ac67e88fba3f5f2053bbc012aeaa907ed326db483a8928150dae6ed"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/starlight36/vibecoding-signal-light/releases/download/v0.1.2/signal-light-v0.1.2-linux-arm64.tar.gz"
      sha256 "9472cc56de3fc8d1121eaeeea8ee7b4afca8d98bf1eae7e010597134d31e2722"
    else
      url "https://github.com/starlight36/vibecoding-signal-light/releases/download/v0.1.2/signal-light-v0.1.2-linux-amd64.tar.gz"
      sha256 "55b08ba1eada8c7b51f96d5cab6c9e7682dfa5d78e7dbcdfb997b8833d5e6795"
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
