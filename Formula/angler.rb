class Angler < Formula
  include Language::Python::Virtualenv

  desc "A tool to generate typescript openapi for microservices gateways with multiple definitions"
  homepage "https://github.com/Deitsch/angler"
  url "https://github.com/Deitsch/angler/archive/refs/tags/v0.0.3.tar.gz"
  sha256 "ec7960cac599a6a1b6a11ed4e885fb8c11be53662b6f9340abba33380fc3fa47"
  license "MIT"
  revision 1
  head "https://github.com/Deitsch/angler.git", branch: "main"

  depends_on "openapi-generator"
  depends_on "python@3.10"

  def install
    xy = Language::Python.major_minor_version "python3"
    site_packages = "lib/python#{xy}/site-packages"
    angler_package = libexec/site_packages/"angler"  # Location of angler in site-packages

    # Copy each file to the install directory
    %w[angler anglerEnums.py anglerGen.py anglerHelperFunctions.py anglerOpenAPIfix.py version].each do |file|
      angler_package.install file
    end

    # Modify import path to allow for angler to be used as a library
    (angler_package/"__init__.py").write <<~EOS
      import sys
      sys.path.append("#{angler_package}")
    EOS

    # Symlink angler to /usr/local/bin
    bin.install_symlink angler_package/"angler"

    # Allow angler to be imported from /usr/local/bin/python
    pth_contents = "import site; site.addsitedir('#{libexec/site_packages}')\n"
    (prefix/site_packages/"homebrew-angler.pth").write pth_contents
  end

  test do
    # Basic CLT help test
    assert_equal shell_output("#{bin}/angler --help").lines.third, "A swagger gen for microservices\n"

    # Library test
    system Formula["python@3.10"].opt_bin/"python3", "-c", <<~EOS
      from angler.anglerHelperFunctions import __extractPath
      assert __extractPath("http://localhost:8002/swagger/") == "//localhost"
    EOS
  end
end
