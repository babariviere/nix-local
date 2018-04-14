{pythonPackages, fetchFromGitHub}:

with pythonPackages;
buildPythonApplication rec {
  name = "mdv";
  version = "0.2";

  src = fetchFromGitHub {
    owner = "axiros";
    repo = "terminal_markdown_viewer";
    rev = "v${version}";
    sha256 = "1fsaszsmmmd9f2nblcw9g2v769pbp76b38cbviabryhrv1igpkr7";
  };

  propagatedBuildInputs = [
    markdown docopt pyyaml pygments
  ];
}
