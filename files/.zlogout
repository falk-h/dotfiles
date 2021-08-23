# Don't source /etc/zlogout.
# This disables clearing the screen when exiting an SSH session, as
# /etc/zlogouut contains `clear` on Fedora.
setopt noglobalrcs
