{pkgs, ...}: with pkgs;
rec {

  terminalTools = [ tmux vim fish ];

  scmTools = [ git ];

  adminTools = terminalTools ++ scmTools;

}
