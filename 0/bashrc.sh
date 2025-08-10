### ______  MOJE _____
sshd
PS1='\[\033[0;93m\]DELAVEC\[\033[0;91m\]@\[\033[0;93m\]IPIPIP\[\033[00m\]:\[\033[01;32m\]\w\[\033[00m\]$ '

if [[ -n "$STY" ]]; then
  PS1="\[\e[01;31m\][${PS1}\e[01;31m\]]\[\e[0m\]"
else
  # se izvese ko ni v screen
  alias ss='~/start.sh'
  alias xx='screen -ls | grep -o "[0-9]\+\." | awk "{print }" | xargs -I {} screen -X -S {} quit;if (screen -list | grep -q -i "ccminer\|Update"); then killall ccminer;killall screen;fi'
  alias xc='screen screen -X -S CCminer quit'
  alias xu='screen screen -X -S Update quit'
  alias sl='screen -ls | sed -E "s/CCminer/\x1b[32m&\x1b[0m/g; s/Update/\x1b[36m&\x1b[0m/g" | tail -n +2 | head -n -1'
  alias rr='screen -d -r CCminer'
  alias ru='screen -d -r Update'
  alias pop='~/posodobi.sh'
  alias uu='yes | pkg update ; yes | pkg upgrade ; pkg install -y wget net-tools nano screen jq bc'
  alias ch='~/curr_hash.sh'
  alias sb='source .bashrc'
  alias nb='nano .bashrc'
  alias cj='nano config.json'
  alias load='~/load.sh'
  alias inf='~/inf.sh'
  alias ll='ls -alF'
  alias XX='xx'
  alias SL='sl'
  alias RR='rr'
  alias RU='ru'
  alias CH='ch'
  alias UU='uu'
  alias n='nano'

  echo "Screens:"
  screen -ls | sed -E "s/CCminer/\x1b[32m&\x1b[0m/g; s/Update/\x1b[36m&\x1b[0m/g" | tail -n +2 | head -n -1
  # kontrola in prikaz hasha
  bash ./curr_hash.sh
fi
