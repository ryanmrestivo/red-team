
# Index:
# 1. Information & Description:
# 2. Setup & Instructions:
# 3. Parameters:
# 4. Functions:
# 5. Main:
# 6. Footer:

# -------------------------------------------------------------------------------
# Information & Description:

# Clean-up log file for:
# /home/pi/DynDNS/DynDNS-NameSilo-RottenEggs.py
# e.g.
# /home/pi/DynDNS/DynDNS-NameSilo-RottenEggs.log

# /Information & Description
# -------------------------------------------------------------------------------
# Setup & Instructions:

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

# To copy this script to Raspberry Pi via PuTTY:
#pscp "%UserProfile%\Documents\Flash Drive updates\Pi-Hole DNS server\DynDNS-NameSilo-RottenEggs-LogCleanup.sh" pi@my.pi:/home/pi/DynDNS/DynDNS-NameSilo-RottenEggs-LogCleanup.sh

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

# Make script executable:
# Note that to make a file executable, you must set the eXecutable bit, and for a shell script, the Readable bit must also be set:
#cd /home/pi/DynDNS/
#ls -l
#chmod a+rx DynDNS-NameSilo-RottenEggs-LogCleanup.sh
#ls -l

# Permissions breakdown:
# drwxrwxrwx
# | |  |  |
# | |  |  others
# | |  group
# | user
# is directory?

# u  =  owner of the file (user)
# g  =  groups owner  (group)
# o  =  anyone else on the system (other)
# a  =  all

# + =  add permission
# - =  remove permission

# r  = read permission
# w  = write permission
# x  = execute permission

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

# To run this script: 
#/home/pi/DynDNS/DynDNS-NameSilo-RottenEggs-LogCleanup.sh
#cd /home/pi/DynDNS/
#./DynDNS-NameSilo-RottenEggs-LogCleanup.sh

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

# Schedule script to run automatically once every 2 weeks:
#crontab -l
#crontab -e
#0 0 */14 * * /home/pi/DynDNS/DynDNS-NameSilo-RottenEggs-LogCleanup.sh
#crontab -l

# Schedule script to run automatically once every month:
#crontab -l
#crontab -e
#0 0 1 */1 * /home/pi/DynDNS/DynDNS-NameSilo-RottenEggs-LogCleanup.sh
#crontab -l

# m h  dom mon dow   command

# * * * * *  command to execute
# - - - - -
# ¦ ¦ ¦ ¦ ¦
# ¦ ¦ ¦ ¦ ¦
# ¦ ¦ ¦ ¦ +----- day of week (0 - 7) (0 to 6 are Sunday to Saturday, or use names; 7 is Sunday, the same as 0)
# ¦ ¦ ¦ +---------- month (1 - 12)
# ¦ ¦ +--------------- day of month (1 - 31)
# ¦ +-------------------- hour (0 - 23)
# +------------------------- min (0 - 59)

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

# /Setup & Instructions
# -------------------------------------------------------------------------------
# Parameters:

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

DIR_TO_BACKUP=/
DIR_TO_BACKUP=/disk/data01

BACKUP_DESTINATION=/disk/backup01

BACKUP_DRIVE_NAME=root
BACKUP_DRIVE_NAME=data01

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

BACKUP_DEST_LATEST=$BACKUP_DESTINATION/$BACKUP_DRIVE_NAME/backup_latest

BACKUP_DEST_ARCHIVE=$BACKUP_DESTINATION/$BACKUP_DRIVE_NAME/backup_archive

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

ARCHIVE_NAME="FULLBACKUP"
ARCHIVE_NAME="ROOTBACKUP"
ARCHIVE_NAME="DATABACKUP"

# Get today's date & time in YYYYmmdd-HHMM e.g. 20190804-2343
TODAY=`/bin/date +%Y%m%d-%H%M`
#FILENAME="FULLBACKUP-${TODAY}"
FILENAME="${ARCHIVE_NAME}_${TODAY}"

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

# /Parameters
# -------------------------------------------------------------------------------
# Functions:

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

update_all_software()
{
  yum check-update
  sudo yum update
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

# https://www.shellscript.sh/functions.html

add_a_user()
{
  USER=$1
  PASSWORD=$2
  shift; shift;
  # Having shifted twice, the rest is now comments ...
  COMMENTS=$@
  echo "Adding user $USER ..."
  echo useradd -c "$COMMENTS" $USER
  echo passwd $USER $PASSWORD
  echo "Added user $USER ($COMMENTS) with pass $PASSWORD"
}

adduser()
{
  USER=$1
  PASSWORD=$2
  shift; shift;
  # Having shifted twice, the rest is now comments ...
  COMMENTS=$@
  useradd -c "${COMMENTS}" $USER
  if [ "$?" -ne "0" ]; then
    echo "Useradd failed"
    return 1
  fi
  passwd $USER $PASSWORD
  if [ "$?" -ne "0" ]; then
    echo "Setting password failed"
    return 2
  fi
  echo "Added user $USER ($COMMENTS) with pass $PASSWORD"
}

#adduser bob letmein Bob Holness from Blockbusters
#ADDUSER_RETURN_CODE=$?
#if [ "$ADDUSER_RETURN_CODE" -eq "1" ]; then
#  echo "Something went wrong with useradd"
#elif [ "$ADDUSER_RETURN_CODE" -eq "2" ]; then 
#  echo "Something went wrong with passwd"
#else
#  echo "Bob Holness added to the system."
#fi

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

# https://www.shellscript.sh/functions.html

factorial()
{
  if [ "$1" -gt "1" ]; then
    i=`expr $1 - 1`
    j=`factorial $i`
    k=`expr $1 \* $j`
    echo $k
  else
    echo 1
  fi
}

#while :
#do
#  echo "Enter a number:"
#  read x
#  factorial $x
#done    

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

# /Functions
# -------------------------------------------------------------------------------
# Main:

# -------------------------------------------------------------------------------
# ===============================================================================
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

# Index of Main:
#===============================================================================
# 1: Cycle BACKUP_ARCHIVE packages
# 2: Compress BACKUP_DESTINATION into time-stamped package and transfer to BACKUP_ARCHIVE
# 3: Copy DIR_TO_BACKUP to BACKUP_DESTINATION
#===============================================================================

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

# https://www.shellscript.sh/

DIR_TO_CREATE=$BACKUP_DEST_LATEST
[[ ! -e $DIR_TO_CREATE ]] && sudo mkdir -p $DIR_TO_CREATE

DIR_TO_CREATE=$BACKUP_DEST_ARCHIVE
[[ ! -e $DIR_TO_CREATE ]] && sudo mkdir -p $DIR_TO_CREATE

#===============================================================================
# 1: Cycle BACKUP_ARCHIVE packages
#===============================================================================


# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

#===============================================================================
# 2: Compress BACKUP_DESTINATION into time-stamped package and transfer to BACKUP_ARCHIVE
#===============================================================================



# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

#===============================================================================
# 3: Copy DIR_TO_BACKUP to BACKUP_DESTINATION
#===============================================================================

SWITCH_OPTIONS="-aAXv --delete-after"
SWITCH_OPTIONS="-avzhe"
SWITCH_OPTIONS="-avzhe"
SWITCH_OPTIONS="-auvzhe"

# Backup to local drive Options:
SWITCH_OPTIONS="-avAEXh --delete"

# -a, --archive               archive mode; equals -rlptgoD (no -H,-A,-X)
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# -r, --recursive             recurse into directories
# -l, --links                 copy symlinks as symlinks
# -p, --perms                 preserve permissions
# -t, --times                 preserve modification times
# -g, --group                 preserve group
# -o, --owner                 preserve owner (super-user only)
# -D                          same as --devices --specials
#     --devices               preserve device files (super-user only)
#     --specials              preserve special files

# -A, --acls                  preserve ACLs (implies --perms)
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# -p, --perms                 preserve permissions

# -E, --executability         preserve the file's executability

# -X, --xattrs                preserve extended attributes

# -v, --verbose               increase verbosity

#     --del                   an alias for --delete-during
#     --delete                delete extraneous files from destination dirs
#     --delete-before         receiver deletes before transfer, not during
#     --delete-during         receiver deletes during the transfer
#     --delete-delay          find deletions during, delete after
#     --delete-after          receiver deletes after transfer, not during
#     --delete-excluded       also delete excluded files from destination dirs

# -z, --compress              compress file data during the transfer

# -h, --human-readable        output numbers in a human-readable format

# -e, --rsh=COMMAND           specify the remote shell to use

# -u, --update                skip files that are newer on the receiver

# -b, --backup                make backups (see --suffix & --backup-dir)
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
#     --backup-dir=DIR        make backups into hierarchy based in DIR
#     --suffix=SUFFIX         set backup suffix (default ~ w/o --backup-dir)

echo "$SWITCH_OPTIONS"

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

SWITCH_EXCLUDE=" --exclude={"/dev/*","/proc/*","/sys/*","/tmp/*","/run/*","/mnt/*","/media/*","/lost+found"}"

echo "$SWITCH_EXCLUDE"

#     --exclude=PATTERN       exclude files matching PATTERN
#     --exclude-from=FILE     read exclude patterns from FILE

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

SWITCH_DRY_RUN=" --dry-run"

echo "$SWITCH_DRY_RUN"

# -n, --dry-run               perform a trial run with no changes made

# -------------------------------------------------------------------------------

rsync --help # help command

#rsync  version 3.1.2  protocol version 31
#Copyright (C) 1996-2015 by Andrew Tridgell, Wayne Davison, and others.
#Web site: http://rsync.samba.org/
#Capabilities:
#    64-bit files, 64-bit inums, 64-bit timestamps, 64-bit long ints,
#    socketpairs, hardlinks, symlinks, IPv6, batchfiles, inplace,
#    append, ACLs, xattrs, iconv, symtimes, prealloc
#
#rsync comes with ABSOLUTELY NO WARRANTY.  This is free software, and you
#are welcome to redistribute it under certain conditions.  See the GNU
#General Public Licence for details.
#
#rsync is a file transfer program capable of efficient remote update
#via a fast differencing algorithm.
#
#Usage: rsync [OPTION]... SRC [SRC]... DEST
#  or   rsync [OPTION]... SRC [SRC]... [USER@]HOST:DEST
#  or   rsync [OPTION]... SRC [SRC]... [USER@]HOST::DEST
#  or   rsync [OPTION]... SRC [SRC]... rsync://[USER@]HOST[:PORT]/DEST
#  or   rsync [OPTION]... [USER@]HOST:SRC [DEST]
#  or   rsync [OPTION]... [USER@]HOST::SRC [DEST]
#  or   rsync [OPTION]... rsync://[USER@]HOST[:PORT]/SRC [DEST]
#The ':' usages connect via remote shell, while '::' & 'rsync://' usages connect
#to an rsync daemon, and require SRC or DEST to start with a module name.
#
#Options
# -v, --verbose               increase verbosity
#     --info=FLAGS            fine-grained informational verbosity
#     --debug=FLAGS           fine-grained debug verbosity
#     --msgs2stderr           special output handling for debugging
# -q, --quiet                 suppress non-error messages
#     --no-motd               suppress daemon-mode MOTD (see manpage caveat)
# -c, --checksum              skip based on checksum, not mod-time & size
# -a, --archive               archive mode; equals -rlptgoD (no -H,-A,-X)
#     --no-OPTION             turn off an implied OPTION (e.g. --no-D)
# -r, --recursive             recurse into directories
# -R, --relative              use relative path names
#     --no-implied-dirs       don't send implied dirs with --relative
# -b, --backup                make backups (see --suffix & --backup-dir)
#     --backup-dir=DIR        make backups into hierarchy based in DIR
#     --suffix=SUFFIX         set backup suffix (default ~ w/o --backup-dir)
# -u, --update                skip files that are newer on the receiver
#     --inplace               update destination files in-place (SEE MAN PAGE)
#     --append                append data onto shorter files
#     --append-verify         like --append, but with old data in file checksum
# -d, --dirs                  transfer directories without recursing
# -l, --links                 copy symlinks as symlinks
# -L, --copy-links            transform symlink into referent file/dir
#     --copy-unsafe-links     only "unsafe" symlinks are transformed
#     --safe-links            ignore symlinks that point outside the source tree
#     --munge-links           munge symlinks to make them safer (but unusable)
# -k, --copy-dirlinks         transform symlink to a dir into referent dir
# -K, --keep-dirlinks         treat symlinked dir on receiver as dir
# -H, --hard-links            preserve hard links
# -p, --perms                 preserve permissions
# -E, --executability         preserve the file's executability
#     --chmod=CHMOD           affect file and/or directory permissions
# -A, --acls                  preserve ACLs (implies --perms)
# -X, --xattrs                preserve extended attributes
# -o, --owner                 preserve owner (super-user only)
# -g, --group                 preserve group
#     --devices               preserve device files (super-user only)
#     --copy-devices          copy device contents as regular file
#     --specials              preserve special files
# -D                          same as --devices --specials
# -t, --times                 preserve modification times
# -O, --omit-dir-times        omit directories from --times
# -J, --omit-link-times       omit symlinks from --times
#     --super                 receiver attempts super-user activities
#     --fake-super            store/recover privileged attrs using xattrs
# -S, --sparse                handle sparse files efficiently
#     --preallocate           allocate dest files before writing them
# -n, --dry-run               perform a trial run with no changes made
# -W, --whole-file            copy files whole (without delta-xfer algorithm)
# -x, --one-file-system       don't cross filesystem boundaries
# -B, --block-size=SIZE       force a fixed checksum block-size
# -e, --rsh=COMMAND           specify the remote shell to use
#     --rsync-path=PROGRAM    specify the rsync to run on the remote machine
#     --existing              skip creating new files on receiver
#     --ignore-existing       skip updating files that already exist on receiver
#     --remove-source-files   sender removes synchronized files (non-dirs)
#     --del                   an alias for --delete-during
#     --delete                delete extraneous files from destination dirs
#     --delete-before         receiver deletes before transfer, not during
#     --delete-during         receiver deletes during the transfer
#     --delete-delay          find deletions during, delete after
#     --delete-after          receiver deletes after transfer, not during
#     --delete-excluded       also delete excluded files from destination dirs
#     --ignore-missing-args   ignore missing source args without error
#     --delete-missing-args   delete missing source args from destination
#     --ignore-errors         delete even if there are I/O errors
#     --force                 force deletion of directories even if not empty
#     --max-delete=NUM        don't delete more than NUM files
#     --max-size=SIZE         don't transfer any file larger than SIZE
#     --min-size=SIZE         don't transfer any file smaller than SIZE
#     --partial               keep partially transferred files
#     --partial-dir=DIR       put a partially transferred file into DIR
#     --delay-updates         put all updated files into place at transfer's end
# -m, --prune-empty-dirs      prune empty directory chains from the file-list
#     --numeric-ids           don't map uid/gid values by user/group name
#     --usermap=STRING        custom username mapping
#     --groupmap=STRING       custom groupname mapping
#     --chown=USER:GROUP      simple username/groupname mapping
#     --timeout=SECONDS       set I/O timeout in seconds
#     --contimeout=SECONDS    set daemon connection timeout in seconds
# -I, --ignore-times          don't skip files that match in size and mod-time
# -M, --remote-option=OPTION  send OPTION to the remote side only
#     --size-only             skip files that match in size
#     --modify-window=NUM     compare mod-times with reduced accuracy
# -T, --temp-dir=DIR          create temporary files in directory DIR
# -y, --fuzzy                 find similar file for basis if no dest file
#     --compare-dest=DIR      also compare destination files relative to DIR
#     --copy-dest=DIR         ... and include copies of unchanged files
#     --link-dest=DIR         hardlink to files in DIR when unchanged
# -z, --compress              compress file data during the transfer
#     --compress-level=NUM    explicitly set compression level
#     --skip-compress=LIST    skip compressing files with a suffix in LIST
# -C, --cvs-exclude           auto-ignore files the same way CVS does
# -f, --filter=RULE           add a file-filtering RULE
# -F                          same as --filter='dir-merge /.rsync-filter'
#                             repeated: --filter='- .rsync-filter'
#     --exclude=PATTERN       exclude files matching PATTERN
#     --exclude-from=FILE     read exclude patterns from FILE
#     --include=PATTERN       don't exclude files matching PATTERN
#     --include-from=FILE     read include patterns from FILE
#     --files-from=FILE       read list of source-file names from FILE
# -0, --from0                 all *-from/filter files are delimited by 0s
# -s, --protect-args          no space-splitting; only wildcard special-chars
#     --address=ADDRESS       bind address for outgoing socket to daemon
#     --port=PORT             specify double-colon alternate port number
#     --sockopts=OPTIONS      specify custom TCP options
#     --blocking-io           use blocking I/O for the remote shell
#     --stats                 give some file-transfer stats
# -8, --8-bit-output          leave high-bit chars unescaped in output
# -h, --human-readable        output numbers in a human-readable format
#     --progress              show progress during transfer
# -P                          same as --partial --progress
# -i, --itemize-changes       output a change-summary for all updates
#     --out-format=FORMAT     output updates using the specified FORMAT
#     --log-file=FILE         log what we're doing to the specified FILE
#     --log-file-format=FMT   log updates using the specified FMT
#     --password-file=FILE    read daemon-access password from FILE
#     --list-only             list the files instead of copying them
#     --bwlimit=RATE          limit socket I/O bandwidth
#     --outbuf=N|L|B          set output buffering to None, Line, or Block
#     --write-batch=FILE      write a batched update to FILE
#     --only-write-batch=FILE like --write-batch but w/o updating destination
#     --read-batch=FILE       read a batched update from FILE
#     --protocol=NUM          force an older protocol version to be used
#     --iconv=CONVERT_SPEC    request charset conversion of filenames
#     --checksum-seed=NUM     set block/file checksum seed (advanced)
# -4, --ipv4                  prefer IPv4
# -6, --ipv6                  prefer IPv6
#     --version               print version number
#(-h) --help                  show this help (-h is --help only if used alone)
#
#Use "rsync --daemon --help" to see the daemon-mode command-line options.
#Please see the rsync(1) and rsyncd.conf(5) man pages for full documentation.
#See http://rsync.samba.org/ for updates, bug reports, and answers

# -------------------------------------------------------------------------------

RSYNC_OPTIONS=$SWITCH_OPTIONS
RSYNC_OPTIONS+=$SWITCH_DRY_RUN
RSYNC_OPTIONS+=$SWITCH_EXCLUDE

echo "rsync $RSYNC_OPTIONS"

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

rsync $RSYNC_OPTIONS $DIR_TO_BACKUP $BACKUP_DEST_LATEST

# -------------------------------------------------------------------------------

RSYNC_OPTIONS=$SWITCH_OPTIONS
#RSYNC_OPTIONS+=$SWITCH_DRY_RUN
RSYNC_OPTIONS+=$SWITCH_EXCLUDE

echo "rsync $RSYNC_OPTIONS"

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

rsync $RSYNC_OPTIONS $DIR_TO_BACKUP $BACKUP_DEST_LATEST




# ===============================================================================
# ===============================================================================

#https://serverfault.com/questions/120431/how-to-backup-a-full-centos-server

rsync -aAXv --delete-after --exclude={"/dev/*","/proc/*","/sys/*","/tmp/*","/run/*","/mnt/*","/media/*","/lost+found"} / user@server:backup-folder

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

#https://www.centos.org/forums/viewtopic.php?t=61787

rsync --dry-run -avzhe ssh /dir-to-be-copied/* root@<target_server>:/backupdir/

# Worked fine. Then tried it as the real deal:

rsync -avzhe ssh /dir-to-be-copied/* root@<target_server>:/backupdir/

# Also worked fine.

# Then used crontab -e to set up the following, for a nightly transfer:

1 2 * * * rsync -auvzhe ssh /dir-to-be-copied/* root@<target_server>:/backupdir/



# -------------------------------------------------------------------------------


#https://serverfault.com/questions/120431/how-to-backup-a-full-centos-server

# The best tool to use for this is probably dump, which is a standard linux tool and will give you the whole filesystem. I would do something like this:

/sbin/dump -0uan -f - / | gzip -2 | ssh -c blowfish user@backupserver.example.com dd of=/backup/server-full-backup-`date '+%d-%B-%Y'`.dump.gz

# This will do a file system dump of / (make sure you don't need to dump any other mounts!), compress it with gzip and ssh it to a remote server (backupserver.example.com), storing it in /backup/. If you later need to browse the backup you use restore:

restore -i

# Another option, if you don't have access to dump is to use tar and do something like

tar -zcvpf /backup/full-backup-`date '+%d-%B-%Y'`.tar.gz --directory / --exclude=mnt --exclude=proc --exclude=tmp .

# But tar does not handle changes in the file system as well.



# -------------------------------------------------------------------------------


#https://www.eandbsoftware.org/how-to-do-a-full-backup-using-the-tar-command-in-linux-centosredhatdebianubuntu/

# Get today's date & time in YYYYmmdd-HHMM e.g. 20190804-2343
TODAY=`/bin/date +%Y%m%d-%H%M`

FILENAME="FULLBACKUP-${TODAY}"

tar -cvpf /backups/${FILENAME}.tar --directory=/ --exclude=proc --exclude=sys --exclude=dev/pts --exclude=backups .

exit 0


#    The c option creates the backup file.
#    The v option gives a more verbose output while the command is running. This option can also be safely eliminated.
#    The p option preserves the file and directory permissions.
#    The f option needs to go last because it allows you to specify the name and location of the backup file which follows next in the command (in our case this is the /backups/fullbackup.tar file).
#    The --directory option tells tar to switch to the root of the file system before starting the backup.
#    We --exclude certain directories from the backup because the contents of the directories are dynamically created by the OS. We also want to exclude the directory that contains are backup file.
#    Many tar references on the Web will give an exclude example as:
#    --exclude=/proc





# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# ===============================================================================
# -------------------------------------------------------------------------------

# /Main
# -------------------------------------------------------------------------------
# Footer:

echo "End of script."
echo $'\n'
exit 0

# /Footer
# -------------------------------------------------------------------------------

