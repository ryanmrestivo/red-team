
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

# You have to make your script executable before you can run it.
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

CURRENT_LOGFILE_PATH="/home/pi/DynDNS/DynDNS-NameSilo-RottenEggs.log"

#ARCHIVE_LOGFILE_PATH="/home/pi/DynDNS/DynDNS-NameSilo-RottenEggs-LastTwoWeeks.log"
ARCHIVE_LOGFILE_PATH="/home/pi/DynDNS/DynDNS-NameSilo-RottenEggs-LastMonth.log"

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
    echo "Useradd failed."
    return 1
  fi
  passwd $USER $PASSWORD
  if [ "$?" -ne "0" ]; then
    echo "Setting password failed."
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
# 1: Get physical drives on system and partiotions
# 2: Get total size and % used for each physical drive
# 3: Edit partitions
# 4: Format disks
# 5: Mount/Un-mount drives to filesystem
#===============================================================================

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

# https://www.binarytides.com/linux-command-check-disk-partitions/

#sudo fdisk -l
#sudo sfdisk -l -uM
#sudo cfdisk /dev/sda
#sudo cfdisk /dev/sdb
#sudo cfdisk /dev/sdc
#sudo parted -l
#df -h
#df -h | grep ^/dev
#df -h --output=source,fstype,size,used,avail,pcent,target -x tmpfs -x devtmpfs
#pydf
#lsblk
#sudo blkid
#hwinfo --block --short

#btrfs

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

#===============================================================================
# 1: Get physical drives on system and partiotions
#===============================================================================

lsblk -h # help command

lsblk

lsblk -f # Filesystem info

lsblk -p # print complate device path

lsblk -S # output info about SCSI devices

#lsblk --output NAME MAJ:MIN RM SIZE RO TYPE MOUNTPOINT
lsblk --output NAME,MAJ:MIN,RM,SIZE,RO,TYPE,MOUNTPOINT

#lsblk --output NAME MAJ:MIN RM SIZE RO TYPE FSTYPE MOUNTPOINT STATE
lsblk --output NAME,MAJ:MIN,RM,SIZE,RO,TYPE,FSTYPE,MOUNTPOINT,STATE

#NAME            MAJ:MIN RM  SIZE RO TYPE FSTYPE      MOUNTPOINT STATE
#sda               8:0    0  1.4T  0 disk                        running
#sdb               8:16   0  1.4T  0 disk                        running
#└─sdb1            8:17   0   16M  0 part
#sdc               8:32   0 74.5G  0 disk                        running
#├─sdc1            8:33   0  200M  0 part vfat        /boot/efi
#├─sdc2            8:34   0    1G  0 part xfs         /boot
#└─sdc3            8:35   0 73.3G  0 part LVM2_member
#  ├─centos-root 253:0    0 44.3G  0 lvm  xfs         /          running
#  ├─centos-swap 253:1    0  7.5G  0 lvm  swap        [SWAP]     running
#  └─centos-home 253:2    0 21.6G  0 lvm  xfs         /home      running
#sr0              11:0    1 1024M  0 rom                         running

#lsblk --output NAME MAJ:MIN RM SIZE TYPE MOUNTPOINT STATE
lsblk --output NAME,MAJ:MIN,RM,SIZE,TYPE,MOUNTPOINT,STATE

#NAME            MAJ:MIN RM  SIZE TYPE MOUNTPOINT STATE
#sda               8:0    0  1.4T disk            running
#sdb               8:16   0  1.4T disk            running
#└─sdb1            8:17   0   16M part
#sdc               8:32   0 74.5G disk            running
#├─sdc1            8:33   0  200M part /boot/efi
#├─sdc2            8:34   0    1G part /boot
#└─sdc3            8:35   0 73.3G part
#  ├─centos-root 253:0    0 44.3G lvm  /          running
#  ├─centos-swap 253:1    0  7.5G lvm  [SWAP]     running
#  └─centos-home 253:2    0 21.6G lvm  /home      running
#sr0              11:0    1 1024M rom             running

#lsblk --output NAME MAJ:MIN RM SIZE RO TYPE MOUNTPOINT
lsblk --output NAME,SIZE,TYPE,KNAME,LABEL,PARTLABEL,MOUNTPOINT

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

#===============================================================================
# 2: Get total size and % used for each physical drive
#===============================================================================

df --help # help command

df -h

df -h | grep ^/dev

df -h --output=source,fstype,size,used,avail,pcent,target -x tmpfs -x devtmpfs

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

#===============================================================================
# 3: Edit partitions
#===============================================================================

DEVICE_DISK=/dev/sda
DEVICE_DISK=/dev/sdb

# Edit partitions:

sudo cfdisk /dev/sda
sudo cfdisk /dev/sdb
sudo cfdisk /dev/sdc
sudo cfdisk $DEVICE_DISK

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

# Remove partitions:

#1. Make sure it's not mounted
lsblk

#2. Un-mount it if it is
sudo umount /dev/sdb
sudo umount $DEVICE_DISK

#3. Remove partition
parted -h # help command

#sudo parted -l

sudo parted /dev print devices

sudo parted /dev/sdb select
sudo parted $DEVICE_DISK select

sudo parted /dev/sdb print
sudo parted $DEVICE_DISK print

sudo parted /dev/sdb rm 1
sudo parted $DEVICE_DISK rm 1

#4. Confirm partition was deleted
sudo parted /dev/sdb print
sudo parted $DEVICE_DISK print
lsblk

#5. Update /etc/fstab
nano /etc/fstab

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

#===============================================================================
# 4: Format disks
#===============================================================================

#https://www.cyberciti.biz/faq/linux-disk-format/
#https://www.techwalla.com/articles/format-linux-disk

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

#0. Remove all partitions first

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

#1. List disks
sudo fdisk -l | grep '^Disk'
lsblk

#1a. Set vars
DEVICE_DISK=/dev/sda
MOUNT_PATH=/disk/data01
DISK_LABEL=Data
PARTITION_LABEL=data

#1a. Set vars
DEVICE_DISK=/dev/sdb
MOUNT_PATH=/disk/backup01
DISK_LABEL=Backup
PARTITION_LABEL=backup

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

DEVICE_PARTITION=$DEVICE_DISK
DEVICE_PARTITION+=1

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

#2. Name the Disk

#4a. Check the names before
lsblk --output NAME,SIZE,TYPE,KNAME,LABEL,PARTLABEL,MOUNTPOINT

#4b. Name the Disk
sudo e2label /dev/sda Data
sudo e2label /dev/sdb Backup
sudo e2label $DEVICE_DISK $DISK_LABEL

sudo tune2fs -L Data /dev/sda
sudo tune2fs -L $DISK_LABEL $DEVICE_DISK

#4c. Check the names after
lsblk --output NAME,SIZE,TYPE,KNAME,LABEL,PARTLABEL,MOUNTPOINT

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

#3. Create new partition

# Check to make sure there are no existing partitions already
lsblk

# Create new partition
sudo fdisk /dev/sda
sudo fdisk $DEVICE_DISK

m # for help menu
n # add a new partition
p # to select primary partition
1 # to create the first partition
<Enter> # to accept the defaults set for first sector
<Enter> # to accept the defaults set for last sector
# Using the defaults will use the entire disk, instead of just part of it

m # for help menu
t # change a partition's system id / to change the file system type
L # to see a list of known types
83 # for "Linux"

m # for help menu
w # to write the partition to the disk (this cannot be undone)

# Check what's up
lsblk

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

# Check to make sure there are no existing partitions already
lsblk

# Create new partition
sudo fdisk /dev/sdb
sudo fdisk $DEVICE_DISK

m # for help menu
n # add a new partition
p # to select primary partition
1 # to create the first partition
<Enter> # to accept the defaults set for first sector
<Enter> # to accept the defaults set for last sector
# Using the defaults will use the entire disk, instead of just part of it

m # for help menu
t # change a partition's system id / to change the file system type
L # to see a list of known types
83 # for "Linux"

m # for help menu
w # to write the partition to the disk (this cannot be undone)

# Check what's up
lsblk

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

#4. Format new partition

#4a. Check what's up
lsblk

#4b. Format new partition
sudo mkfs.ext4 /dev/sda1

sudo mkfs.ext4 $DEVICE_PARTITION

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

sudo mkfs.ext4 /dev/sdb1

sudo mkfs.ext4 $DEVICE_PARTITION

#4c. Check what's up
lsblk

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

#5. Name the new partition

#5a. Check the names before
lsblk --output NAME,SIZE,TYPE,KNAME,LABEL,PARTLABEL,MOUNTPOINT

#5b. Name the new partition
e2label # help command
# or
tune2fs # help command

sudo e2label /dev/sda1 data
sudo e2label /dev/sdb1 backup
sudo e2label $DEVICE_PARTITION $PARTITION_LABEL

sudo tune2fs -L data /dev/sda1
sudo tune2fs -L backup /dev/sdb1
sudo tune2fs -L $PARTITION_LABEL $DEVICE_PARTITION

#5c. Check the names after
lsblk --output NAME,SIZE,TYPE,KNAME,LABEL,PARTLABEL,MOUNTPOINT

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

#6. Create new directory to mount to
#DIR_TO_CREATE=/disk01
#[[ ! -e $DIR_TO_CREATE ]] && mkdir $DIR_TO_CREATE
#DIR_TO_CREATE=/disk02
#[[ ! -e $DIR_TO_CREATE ]] && mkdir $DIR_TO_CREATE
DIR_TO_CREATE=$MOUNT_PATH
[[ ! -e $DIR_TO_CREATE ]] && sudo mkdir -p $DIR_TO_CREATE

#mkdir /disk
#mkdir /disk/data01
#mkdir /disk/backup01

#[[ ! -e /disk ]] && mkdir /disk
#[[ ! -e /disk/data01 ]] && mkdir /disk/data01
#[[ ! -e /disk/backup01 ]] && mkdir /disk/backup01
[[ ! -e $MOUNT_PATH ]] && sudo mkdir -p $MOUNT_PATH

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

#7. Set new partition to be mounted at boot

#7a. Get line to add to fstab
echo $DEVICE_PARTITION $MOUNT_PATH ext4 defaults 1 2
ADD_TO_FSTAB="$DEVICE_PARTITION $MOUNT_PATH ext4 defaults 1 2"
echo $ADD_TO_FSTAB

#7b. Edit /etc/fstab
# Edit your fstab file so that the new drive will be mounted at boot. Fstab is the Linux file system configuration file to mount partitions at boot. You can edit /etc/fstab with the "nano" command or "vi" depending on which editor you prefer.
sudo nano /etc/fstab
# or 
sudo vi /etc/fstab

# Add the following line to the end of fstab:

/dev/sda1 /disk01 ext4 defaults 1 2
/dev/sda1 /disk/data01 ext4 defaults 1 2

/dev/sdb1 /disk02 ext4 defaults 1 2
/dev/sdb1 /disk/backup01 ext4 defaults 1 2

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

#===============================================================================
# 5: Mount/Un-mount drives to filesystem
#===============================================================================

# Mount drives to filesystem

#0. Set vars
DEVICE_DISK=/dev/sda
MOUNT_PATH=/disk/data01

DEVICE_DISK=/dev/sdb
MOUNT_PATH=/disk/backup01

DEVICE_PARTITION=$DEVICE_DISK
DEVICE_PARTITION+=1

#1. Create the directory to mount to
mkdir /disk01
[[ ! -e $MOUNT_PATH ]] && sudo mkdir -p $MOUNT_PATH

#2. Mount the directory
mount /dev/sdb1 /disk01
sudo mount $DEVICE_PARTITION $MOUNT_PATH

#3. View mounted directories to confirm
lsblk
df -H

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

# Un-Mount drives from filesystem

#0. Set vars
DEVICE_DISK=/dev/sda

#1. Check which drive to un-mount
lsblk
df -H

#2. Un-mount
umount /dev/sdb
umount $DEVICE_DISK

#3. View mounted directories to confirm
lsblk
df -H

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



