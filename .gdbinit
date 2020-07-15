# Save command history between invocations
set history save on

# Unlimited history size
set history size unlimited

# Remove duplicates from command history (like zsh)
set history remove-duplicates 1

# Store history in ~
set history filename ~/.gdb_history

# Disable the built-in pager
set pagination off

# Nicer prompt (note the space after >)
set extended-prompt \[\e[1m\]> \[\e[0m\]

# Don't ask for confirmation on quit/run/return, etc.
set confirm off
