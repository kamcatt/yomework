#! /bin/bash

# The number of snapshots to retain is defined in the variable retention
snap_prefix=snap
retention=3

# Utilities used

date=/bin/date
grep=/usr/bin/grep
sed=/usr/bin/sed
sort=/usr/bin/sort
xargs=/usr/bin/xargs
zfs=/sbin/zfs

# Variables used 

src_0="new-pool/new-dataset"
today="$snap_prefix-`date +%H%M`"
snap_today="$src_0@$today"
snap_old=`$zfs list -t snapshot -o name | $grep "$src_0@$snap_prefix*" | $sort -r | $sed 1,${retention}d | $xargs -n 1`

# Create ZFS snapshot(if it doesn't exists )

if $zfs list -H -o name -t snapshot | $grep "$snap_today" > /dev/null
then
    echo "Today's snapshot '$snap_today' already exists."
else
    echo "Taking today's snapshot: $snap_today"
    $zfs snapshot -r $snap_today
fi

echo "Attempting to destroy old snapshots..."

# Remove snapshot if it's older than $retention 

if [ -n "$snap_old" ]
then
    echo "Destroying the following old snapshots:"
    echo "$snap_old"
    $zfs list -t snapshot -o name | $grep "$src_0@$snap_prefix*" | $sort -r | $sed 1,${retention}d | $xargs -n 1 $zfs destroy -r
else
    echo "Could not find any snapshots to destroy."
fi

#crontab -e 
#0 */4 * * * sh /root/snapshot.sh
