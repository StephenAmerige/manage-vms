########################################################################
#
# 00-help-tags.zsh
#
# Explain the zsh directory tagging system.
#
########################################################################


########################################################################
# :help:tags
#
# Explain how persistent directory tags are created, used, listed,
# changed, and removed.
########################################################################

function :help:tags
{
   print -P -- "%BDirectory Tags%b"
   print

   print -P -- "%BSynopsis%b"
   print

   print -lP -- \
      "   %F{25}%Btag name%b%f" \
      "   %F{25}%Btag name directory%b%f" \
      "   %F{25}%Btag%b%f" \
      "   %F{25}%Brmtag name%b%f" \
      "   %F{25}%B~name%b%f"

   print

   :help-wrap-indent 3 \
      "Directory tags provide short, persistent names for frequently used" \
      "directories. A tag is implemented as a %Bzsh named directory%b and" \
      "may be used anywhere that a pathname is accepted."
   print

   print -P -- "%BCreating tags%b"
   print

   :help-command "tag name"
   :help-wrap-indent 6 \
      "Associate %Bname%b with the current working directory."
   print

   :help-command "tag name directory"
   :help-wrap-indent 6 \
      "Associate %Bname%b with the specified directory."
   print

   print -P -- "%BExamples%b"
   print

   :help-example "cd /project/github.com/orgname/projname"
   :help-example "tag myproj"
   print

   :help-example 'tag src $HOME/src'
   print

   :help-wrap-indent 3 \
      "Once a tag has been created, prefix its name with %B~%b to use the" \
      "corresponding directory."
   print

   :help-example "cd ~dash"
   :help-example "ls ~src"
   :help-example "vim ~src/project/README.md"
   print

   print -P -- "%BUsing tags%b"
   print

   :help-wrap-indent 3 \
      "A tag may be used as the beginning of a longer pathname. For example," \
      "if %B~src%b represents /home/user/src, then %B~src/project%b represents" \
      "/home/user/src/project."
   print

   :help-wrap-indent 3 \
      "Because tags are %Bzsh named directories%b, zsh may also use the tag" \
      "when displaying the current directory. The shell prompt therefore may" \
      "show %B~src/project%b instead of the complete pathname."
   print

   print -P -- "%BListing tags%b"
   print

   :help-command "tag"
   :help-wrap-indent 6 \
      "Show all persistent directory tags stored in" \
      "%B\$HOME/.zshrc.d/a0-tags.zsh%b."
   print

   print -P -- "%BChanging a tag%b"
   print

   :help-wrap-indent 3 \
      "Creating a tag whose name already exists changes that tag to refer to" \
      "the new directory."
   print

   :help-example "tag src /new/location"
   print

   print -P -- "%BRemoving tags%b"
   print

   :help-command "rmtag name"
   :help-wrap-indent 6 \
      "Remove the named tag."
   print

   print -P -- "%BPersistence%b"
   print

   :help-wrap-indent 3 \
      "Tags are persistent across shell sessions. Their definitions are stored" \
      "in %B\$HOME/.zshrc.d/a0-tags.zsh%b and are recreated when the zsh" \
      "startup files are sourced."
}
