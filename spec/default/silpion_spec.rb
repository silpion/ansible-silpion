require 'spec_helper'

#describe file('/etc/passwd') do
#end

%w(
  acl
  at
  bash-completion
  conntrack
  curl
  debconf-utils
  debsums
  dnsutils
  dstat
  git
  htop
  iptables
  libcap2-bin
  lsb-release
  lsof
  man-db
  moreutils
  ncdu
  netcat-openbsd
  ngrep
  numactl
  patch
  psmisc
  pv
  rsync
  screen
  socat
  ssldump
  strace
  sysfsutils
  tcpdump
  time
  tmux
  tree
  vim
  zerofree
).each do |pkg|
  describe package(pkg) do
    it { should be_installed }
  end
end
