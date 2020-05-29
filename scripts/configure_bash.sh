FILE=$HOME/.bashrc
cp ./bash_prompt_color.sh $HOME/.bash_color
cat <<EOM >>$FILE
# Personal additions to configure environment
#--- Aliases
alias ipy='ipython --pylab'
alias jpyn='jupyter notebook'
# Make prompt pretty
source $HOME/.bash_color
# For git prompt and shell completion
source /usr/share/bash-completion/completions/git
source /usr/share/git/git-prompt.sh
EOM
