ZSH=/usr/share/oh-my-zsh/
ZSH_THEME="miloshadzic" # agnoster, miloshadzic
CASE_SENSITIVE="true"
HYPHEN_INSENSITIVE="true"
DISABLE_AUTO_UPDATE="true"
ENABLE_CORRECTION="true"
COMPLETION_WAITING_DOTS="true"
plugins=(archlinux git encode64 gradle nyan repo sudo systemd urltools web-search)
#DISABLE_UNTRACKED_FILES_DIRTY="true"
ZSH_CACHE_DIR=$HOME/.oh-my-zsh-cache
if [[ ! -d $ZSH_CACHE_DIR ]]; then
  mkdir $ZSH_CACHE_DIR
fi
source $ZSH/oh-my-zsh.sh


#Customization
export TERM=xterm-color #Tell applications we support color
export CLICOLOR=1 #Tell applications we support color


#Aliases
alias java7='sudo archlinux-java set java-7-openjdk' #Change to jre7
alias java8='sudo archlinux-java set java-8-openjdk' # Change to jre8
alias update='sudo pacman -Syu && yaourt -Syua && sudo freshclam && sudo pglcmd update' #Update all official/unofficial packages, update ClamAV database, update IP blocklists


#Global settings
export EDITOR=nano #Nano > Vi(m)
export WINEDEBUG=-all #Disable debug logging for performance reasons
export WINEPREFIX=~/.wine #Store Wine stuff here
export USE_CCACHE=1 #Enable ccache