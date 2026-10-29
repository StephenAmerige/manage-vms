# addtag <name> <dir>  - sets tag <name> to <dir> and updates $HOME/.zshrc.d/a0-tags.zsh
addtag()
{
   WriteTag=true
   if [[ $1 = -s ]]; then
      WriteTag=false
      shift
   fi

   eval export "$1"="$(readlink -f "${2:-.}")"

   if $WriteTag; then
      if [[ -f $HOME/.zshrc.d/a0-tags.zsh ]]; then
         sed -i "/^tag $1 /d" "$HOME/.zshrc.d/a0-tags.zsh"
      fi
      echo "tag -s $1 $2" >> "$HOME/.zshrc.d/a0-tags.zsh"
   fi
}

# tag <name>        - set <name> as the tag for the present working directory (PWD)
# tag <name> <dir>  - set <name> as the tag for the given directory (<dir>)
# tag               - show all tags
tag()
{
   TagOption=
   if [[ $1 = -s ]]; then
      TagOption="-s"
      shift
   fi
   case $# in
   0) if [[ ! -f $HOME/.zshrc.d/a0-tags.zsh ]]; then
         mkdir -p "$HOME"/.zshrc.d
         touch "$HOME"/.zshrc.d/a0-tags.zsh
      fi
      cat "$HOME"/.zshrc.d/a0-tags.zsh | expand -20;;
   1) addtag $TagOption "$1" "$PWD";;
   2) addtag $TagOption "$1" "$2";;
   esac
}

# rmtag <name>      - remove tag named <name> if it exists
rmtag()
{
   if [[ -n $1 ]]; then
      sed -i "/^tag $1 /d" "$HOME/.zshrc.d/a0-tags.zsh"
      unset $1
   fi
}
