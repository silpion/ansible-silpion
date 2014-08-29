require 'spec_helper'


describe file('/etc/shadow') do
  its(:content) { should match /\$6\$\$424Wd1I7Zf08UNjZ87zCI7CqSLDPJsmYixRJnsyXsavYUWpikshjobn8rbFAWU6cx\/CzBkuaSteiZKhQj\/0ia0/ }
end


describe file('/etc/apt/apt.conf.d/proxy.conf') do
  it { should be_file }
  its(:content) { should match 'Acquire::http::Proxy "http://apt-proxy.office.silpion.de:9999";' }
end


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


describe file('/etc/alternatives/editor') do
  it { should be_linked_to '/usr/bin/vim.basic' }
end
