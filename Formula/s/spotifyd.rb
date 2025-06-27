class Spotifyd < Formula
  desc "Spotify daemon"
  homepage "https://spotifyd.rs/"
  url "https://github.com/Spotifyd/spotifyd/archive/refs/tags/v0.4.1.tar.gz"
  sha256 "fdbf93c51232d85a0ef29813a02f3c23aacf733444eacf898729593e8837bcfc"
  license "GPL-3.0-only"
  head "https://github.com/Spotifyd/spotifyd.git", branch: "master"

  livecheck do
    url :stable
    regex(/^v?(\d+(?:\.\d+)+)$/i)
  end

  no_autobump! because: :requires_manual_review

  bottle do
    rebuild 1
    sha256 cellar: :any,                 arm64_sequoia:  "dd6598774377cc653a1e34568c6afff11509e3fac350dc0084532ad1eaad97ec"
    sha256 cellar: :any,                 arm64_sonoma:   "a2305bcd95c814f04cf6bef9d9c01a2cd1b6ab1c3f0c9e2dc1cb6ee85f468556"
    sha256 cellar: :any,                 arm64_ventura:  "3237a0154b6fddbf87eaea3b4460c8a992b72217899637d479a31f2bcd7ba53e"
    sha256 cellar: :any,                 arm64_monterey: "25689c32e31f1b2990ffb54fe34ba61856951b8c81d09bea1a4cc4d02d8c6fd9"
    sha256 cellar: :any,                 sonoma:         "7f9e21a27e9b6af17a131d62c23758ba6e7649c9a8ef38bd51b63d7e76dbcbff"
    sha256 cellar: :any,                 ventura:        "af948d2987f9c1f31f7217981ab42a62356b51c6793dc4091005795a917845fb"
    sha256 cellar: :any,                 monterey:       "00d7a5bfb6a4b4cb59e52b6d154e7268b576ed255df3ac199eceed6e7f84ff26"
    sha256 cellar: :any_skip_relocation, arm64_linux:    "09f476e955bcf684bc49ff03e92a67d8b49b59ce54f5a38869dd54af83292492"
    sha256 cellar: :any_skip_relocation, x86_64_linux:   "4baab23fe6181c526b89960d0fb9db63bafea067a4ac9c6f5ac6af658267eea9"
  end

  depends_on "pkgconf" => :build
  depends_on "rust" => :build
  depends_on "dbus"
  depends_on "portaudio"

  def install
    ENV["COREAUDIO_SDK_PATH"] = MacOS.sdk_path_if_needed if OS.mac?

    system "cargo", "install", "--no-default-features",
                               "--features", "portaudio_backend",
                               *std_cargo_args
  end

  service do
    run [opt_bin/"spotifyd", "--no-daemon", "--backend", "portaudio"]
    keep_alive true
  end

  test do
    args = ["--no-daemon", "--verbose"]
    Open3.popen2e(bin/"spotifyd", *args) do |_, stdout_and_stderr, wait_thread|
      sleep 5
      Process.kill "TERM", wait_thread.pid
      output = stdout_and_stderr.read
      assert_match "Starting zeroconf server to advertise on local network", output
      refute_match "ERROR", output
    end
  end
end
