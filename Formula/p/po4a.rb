require "language/perl"

class Po4a < Formula
  include Language::Perl::Shebang

  desc "Documentation translation maintenance tool"
  homepage "https://po4a.org"
  url "https://github.com/mquinson/po4a/archive/refs/tags/v0.70.tar.gz"
  sha256 "e5001d0cb900bfb700d09abb7e994b823d5c05b72c0b221781bff88cbb537f3b"
  license "GPL-2.0-or-later"
  head "https://github.com/mquinson/po4a.git", branch: "master"

  bottle do
    sha256 cellar: :any,                 arm64_sonoma:   "753cd58cd335f98500d339124b9b2450836b90b1c6103c443c68afcee5431124"
    sha256 cellar: :any,                 arm64_ventura:  "f41454c413eee73a9aadacdc0c28d3a2c72c2a115f3c15bcb901aafb9a352cfb"
    sha256 cellar: :any,                 arm64_monterey: "4b55c5e0421f37dd40f5e729dd52e63dc4558fdda7d2a976c974442ee7146b92"
    sha256 cellar: :any,                 sonoma:         "30981a63cd8f32008e133721cd49563af0f8e0d053e00023a7f2d85deceb592d"
    sha256 cellar: :any,                 ventura:        "67e604417389d05067285da3afc1d99c577e5e1378a2eadd3539195a3e15c100"
    sha256 cellar: :any,                 monterey:       "012a5578e2899e3af8c9a57b9b537d1f17dc96af6cb86c91fb99a308de517930"
    sha256 cellar: :any_skip_relocation, x86_64_linux:   "70d5af935d7467916c35632972159b434b472cb7ad8a074012a9d9945d776b6b"
  end

  depends_on "docbook-xsl" => :build
  depends_on "gettext"
  depends_on "perl"

  uses_from_macos "libxslt"

  resource "Locale::gettext" do
    url "https://cpan.metacpan.org/authors/id/P/PV/PVANDRY/Locale-gettext-1.07.tar.gz"
    sha256 "909d47954697e7c04218f972915b787bd1244d75e3bd01620bc167d5bbc49c15"
  end

  resource "Module::Build" do
    url "https://cpan.metacpan.org/authors/id/L/LE/LEONT/Module-Build-0.4234.tar.gz"
    sha256 "66aeac6127418be5e471ead3744648c766bd01482825c5b66652675f2bc86a8f"
  end

  resource "Pod::Parser" do
    url "https://cpan.metacpan.org/authors/id/M/MA/MAREKR/Pod-Parser-1.67.tar.gz"
    sha256 "5deccbf55d750ce65588cd211c1a03fa1ef3aaa15d1ac2b8d85383a42c1427ea"
  end

  resource "SGMLS" do
    url "https://cpan.metacpan.org/authors/id/R/RA/RAAB/SGMLSpm-1.1.tar.gz"
    sha256 "550c9245291c8df2242f7e88f7921a0f636c7eec92c644418e7d89cfea70b2bd"
  end

  resource "TermReadKey" do
    url "https://cpan.metacpan.org/authors/id/J/JS/JSTOWE/TermReadKey-2.38.tar.gz"
    sha256 "5a645878dc570ac33661581fbb090ff24ebce17d43ea53fd22e105a856a47290"
  end

  resource "Text::WrapI18N" do
    url "https://cpan.metacpan.org/authors/id/K/KU/KUBOTA/Text-WrapI18N-0.06.tar.gz"
    sha256 "4bd29a17f0c2c792d12c1005b3c276f2ab0fae39c00859ae1741d7941846a488"
  end

  resource "Unicode::GCString" do
    url "https://cpan.metacpan.org/authors/id/N/NE/NEZUMI/Unicode-LineBreak-2019.001.tar.gz"
    sha256 "486762e4cacddcc77b13989f979a029f84630b8175e7fef17989e157d4b6318a"
  end

  resource "YAML::Tiny" do
    url "https://cpan.metacpan.org/authors/id/E/ET/ETHER/YAML-Tiny-1.74.tar.gz"
    sha256 "7b38ca9f5d3ce24230a6b8bdc1f47f5b2db348e7f7f9666c26f5955636e33d6c"
  end

  resource "ExtUtils::CChecker" do
    url "https://cpan.metacpan.org/authors/id/P/PE/PEVANS/ExtUtils-CChecker-0.11.tar.gz"
    sha256 "117736677e37fc611f5b76374d7f952e1970eb80e1f6ad5150d516e7ae531bf5"
  end

  resource "XS::Parse::Keyword::Builder" do
    url "https://cpan.metacpan.org/authors/id/P/PE/PEVANS/XS-Parse-Keyword-0.39.tar.gz"
    sha256 "b4e775becc8a5d9b52cb5d569b9d3230eea451c134735845e77f89fa6a6c23d8"
  end

  resource "Syntax::Keyword::Try" do
    url "https://cpan.metacpan.org/authors/id/P/PE/PEVANS/Syntax-Keyword-Try-0.29.tar.gz"
    sha256 "cc320719d3608daa9514743a43dac2be99cb8ccd989b1fefa285290cb1d59d8f"
  end

  def install
    ENV.prepend_create_path "PERL5LIB", libexec/"lib/perl5"
    ENV.prepend_path "PERL5LIB", libexec/"lib"

    resources.each do |r|
      r.stage do
        if File.exist?("Makefile.PL")
          system "perl", "Makefile.PL", "INSTALL_BASE=#{libexec}", "NO_MYMETA=1"
          system "make", "install"
        else
          system "perl", "Build.PL", "--install_base", libexec
          system "./Build"
          system "./Build", "install"
        end
      end
    end

    ENV["XML_CATALOG_FILES"] = "#{etc}/xml/catalog"

    system "perl", "Build.PL", "--install_base", libexec
    system "./Build"
    system "./Build", "install"

    shell_scripts = %w[po4a-display-man po4a-display-pod]

    %w[msguntypot po4a po4a-display-man po4a-display-pod
       po4a-gettextize po4a-translate po4a-normalize po4a-updatepo].each do |cmd|
      rewrite_shebang detected_perl_shebang, libexec/"bin"/cmd unless shell_scripts.include? cmd

      (bin/cmd).write_env_script(libexec/"bin"/cmd, PERL5LIB: ENV["PERL5LIB"])
    end

    man1.install Dir[libexec/"man/man1/{msguntypot.1p.gz,po4a*}"]
    man3.install Dir[libexec/"man/man3/Locale::Po4a::*"]
    man7.install Dir[libexec/"man/man7/*"]
  end

  test do
    # LaTeX

    (testpath/"en.tex").write <<~EOS
      \\documentclass[a4paper]{article}
      \\begin{document}
      Hello from Homebrew!
      \\end{document}
    EOS

    system bin/"po4a-updatepo", "-f", "latex", "-m", "en.tex", "-p", "latex.pot"
    assert_match "Hello from Homebrew!", (testpath/"latex.pot").read

    # Markdown

    (testpath/"en.md").write("Hello from Homebrew!")
    system bin/"po4a-updatepo", "-f", "text", "-m", "en.md", "-p", "text.pot"
    assert_match "Hello from Homebrew!", (testpath/"text.pot").read
  end
end
