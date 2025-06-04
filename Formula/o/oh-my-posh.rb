class OhMyPosh < Formula
  desc "Prompt theme engine for any shell"
  homepage "https://ohmyposh.dev"
  url "https://github.com/JanDeDobbeleer/oh-my-posh/archive/refs/tags/v26.2.2.tar.gz"
  sha256 "967ef092e9c7403f768e867b7c89ccc8146bad7750bcac2816b1d4e79487eba9"
  license "MIT"
  head "https://github.com/JanDeDobbeleer/oh-my-posh.git", branch: "main"

  # There can be a notable gap between when a version is tagged and a
  # corresponding release is created, so we check the "latest" release instead
  # of the Git tags.
  livecheck do
    url :stable
    strategy :github_latest
  end

  bottle do
    sha256 cellar: :any_skip_relocation, arm64_sequoia: "35c86b4f5b020116f112c20ce31b805e20266496dfdd76a395b99e93fba2be84"
    sha256 cellar: :any_skip_relocation, arm64_sonoma:  "83c59d2d8bfb9ffc215cdc52989628ec8c59b162d278c76e1443a37393cc1355"
    sha256 cellar: :any_skip_relocation, arm64_ventura: "ba26cbed4194c269c176ab3f0d9c16e2d27c17397b5569d088b13943328670a4"
    sha256 cellar: :any_skip_relocation, sonoma:        "c6b1e8080d7fe39fe6d743e61fc3447f8e8f400b14e6619a2c860f8707db6224"
    sha256 cellar: :any_skip_relocation, ventura:       "744d7bc8fb36e557bf0af255589f38f8536dc46a6bba99e84247a7b6e12d914b"
    sha256 cellar: :any_skip_relocation, x86_64_linux:  "042050090907af51f2951493a3d3bf11cf42a499911f6d09dc5a0a150d7255ae"
  end

  depends_on "go" => :build

  def install
    ldflags = %W[
      -s -w
      -X github.com/jandedobbeleer/oh-my-posh/src/build.Version=#{version}
      -X github.com/jandedobbeleer/oh-my-posh/src/build.Date=#{time.iso8601}
    ]

    cd "src" do
      system "go", "build", *std_go_args(ldflags:)
    end

    prefix.install "themes"
    pkgshare.install_symlink prefix/"themes"
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/oh-my-posh version")
    output = shell_output("#{bin}/oh-my-posh init bash")
    assert_match(%r{.cache/oh-my-posh/init\.#{version}\.default\.\d+\.sh}, output)
  end
end
