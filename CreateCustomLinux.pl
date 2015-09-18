#!/usr/bin/perl
############################################
# Preparing to create custom iso of CentOS #
############################################
# (c) by Wasiliy Besedin, besco@mail.ru, 2:5028/68@fidonet.org
# Feb-Mar, 2015
################################################################
use MIME::Base64;
 
# Root directory for files of an image
$distr_dir='/root/linuxDistr';
# Directory to mount the source disk
$src_dir="source";
# Directory with files of a new image
$custom_dir="prod";
# Name of a ready image
$iso_name="customCentOS65.iso";
# log file
$log_file="CreateCustoCentos.log";
# Directory for a ready image (it is added to $distr_dir)
$dest_iso_dir="iso";
# Directory for initial kickstart-files (are created in a place of start of a script)
# the kickstart-file is formed in $distr_dir/$custom_dir/isolinux/(ks-dvd.cfg and ks-flash.cfg)
$ks_dir="kssrc";
# place of start of a script
chomp($own_dir=`pwd`);


# iso_linux.cfg 
$iso_linux="
default vesamenu.c32
#prompt 1
timeout 300

display boot.msg

menu background splash.jpg
menu title Welcome to CentOS 6.5!
menu color border 0 #ffffffff #00000000
menu color sel 7 #ffffffff #ff000000
menu color title 0 #ffffffff #00000000
menu color tabmsg 0 #ffffffff #00000000
menu color unsel 0 #ffffffff #00000000
menu color hotsel 0 #ff000000 #ffffffff
menu color hotkey 7 #ffffffff #ff000000
menu color scrollbar 0 #ffffffff #00000000

label linux-usb
  menu label ^Install Our Linux from USB
  menu default
  kernel vmlinuz ks=hd:sda1:/isolinux/ks-flash.cfg
  append initrd=initrd.img
label linux-dvd
  menu label ^Install Our Linux from CD/DVD
  kernel vmlinuz ks=cdrom:/isolinux/ks-dvd.cfg
  append initrd=initrd.img
label memtest86
  menu label ^Memory test
  kernel memtest
  append -
";

# base-packages.lst
$base_packages="JXBhY2thZ2VzIC0tbm9iYXNlCnh6LWxpYnMKeHotbHptYS1jb21wYXQKYnppcDIKTmV0d29ya01h
bmFnZXIKTmV0d29ya01hbmFnZXItZ25vbWUKYWxzYS1wbHVnaW5zLXB1bHNlYXVkaW8KYXQtc3Bp
CmNvbnRyb2wtY2VudGVyCmNvbnRyb2wtY2VudGVyLWV4dHJhCmRidXMKZHJhY3V0CmRyYWN1dC1r
ZXJuZWwKZW9nCm1hbgpnZG0KZ2RtLXBsdWdpbi1maW5nZXJwcmludApnZG0tdXNlci1zd2l0Y2gt
YXBwbGV0Cmdub21lLWFwcGxldHMKZ25vbWUtbWVkaWEKZ25vbWUtcGFja2FnZWtpdApnbm9tZS1w
YW5lbApnbm9tZS1wb3dlci1tYW5hZ2VyCmdub21lLXNjcmVlbnNhdmVyCmdub21lLXNlc3Npb24K
Z25vbWUtdGVybWluYWwKZ25vbWUtdmZzMi1zbWIKZ29rCmd2ZnMtYXJjaGl2ZQpndmZzLWZ1c2UK
Z3Zmcy1zbWIKbWV0YWNpdHkKbmF1dGlsdXMKbm90aWZpY2F0aW9uLWRhZW1vbgpvcGVuc3NoLWFz
a3Bhc3MKb3JjYQpwb2xraXQtZ25vbWUKcHVsc2VhdWRpby1tb2R1bGUtZ2NvbmYKcHVsc2VhdWRp
by1tb2R1bGUteDExCnZpbm8KeGRnLXVzZXItZGlycy1ndGsKeWVscApDb25zb2xlS2l0CkNvbnNv
bGVLaXQtbGlicwpDb25zb2xlS2l0LXgxMQpEZXZpY2VLaXQtcG93ZXIKR0NvbmYyCkdDb25mMi1n
dGsKTW9kZW1NYW5hZ2VyCk5ldHdvcmtNYW5hZ2VyLWdsaWIKT1JCaXQyClBhY2thZ2VLaXQKUGFj
a2FnZUtpdC1kZXZpY2UtcmViaW5kClBhY2thZ2VLaXQtZ2xpYgpQYWNrYWdlS2l0LWd0ay1tb2R1
bGUKUGFja2FnZUtpdC15dW0KUGFja2FnZUtpdC15dW0tcGx1Z2luCmFsc2EtbGliCmFsc2EtdXRp
bHMKYXQtc3BpLXB5dGhvbgphdGsKYXZhaGktYXV0b2lwZAphdmFoaS1nbGliCmF2YWhpLWxpYnMK
Y2Fpcm8KY2RwYXJhbm9pYS1saWJzCmNvbXBzLWV4dHJhcwpjb250cm9sLWNlbnRlci1maWxlc3lz
dGVtCmN1cHMtbGlicwpkYnVzLXB5dGhvbgpkYnVzLXgxMQpkZXNrdG9wLWZpbGUtdXRpbHMKZG1p
ZGVjb2RlCmRtei1jdXJzb3ItdGhlbWVzCmRuc21hc3EKZG9jYm9vay1kdGRzCmRvc2ZzdG9vbHMK
ZWdnZGJ1cwpldm9sdXRpb24tZGF0YS1zZXJ2ZXIKZXhlbXBpCmZlc3RpdmFsCmZlc3RpdmFsLWxp
YgpmZXN0aXZhbC1zcGVlY2h0b29scy1saWJzCmZlc3R2b3gtc2x0LWFyY3RpYy1odHMKZmxhYwpm
b250Y29uZmlnCmZvbnRwYWNrYWdlcy1maWxlc3lzdGVtCmZwcmludGQKZnByaW50ZC1wYW0KZnJl
ZXR5cGUKZnVzZS1saWJzCmdkay1waXhidWYyCmdkbS1saWJzCmdsaWItbmV0d29ya2luZwpnbm9t
ZS1ibHVldG9vdGgtbGlicwpnbm9tZS1kZXNrdG9wCmdub21lLWRpc2stdXRpbGl0eS1saWJzCmdu
b21lLWRvYy11dGlscy1zdHlsZXNoZWV0cwpnbm9tZS1pY29uLXRoZW1lCmdub21lLWtleXJpbmcK
Z25vbWUta2V5cmluZy1wYW0KZ25vbWUtbWFnCmdub21lLW1lZGlhLWxpYnMKZ25vbWUtbWVudXMK
Z25vbWUtcGFuZWwtbGlicwpnbm9tZS1weXRob24yCmdub21lLXB5dGhvbjItYXBwbGV0Cmdub21l
LXB5dGhvbjItYm9ub2JvCmdub21lLXB5dGhvbjItY2FudmFzCmdub21lLXB5dGhvbjItZGVza3Rv
cApnbm9tZS1weXRob24yLWV4dHJhcwpnbm9tZS1weXRob24yLWdjb25mCmdub21lLXB5dGhvbjIt
Z25vbWUKZ25vbWUtcHl0aG9uMi1nbm9tZXZmcwpnbm9tZS1weXRob24yLWxpYmVnZwpnbm9tZS1w
eXRob24yLWxpYnduY2sKZ25vbWUtc2Vzc2lvbi14c2Vzc2lvbgpnbm9tZS1zZXR0aW5ncy1kYWVt
b24KZ25vbWUtc3BlZWNoCmdub21lLXRoZW1lcwpnbm9tZS11c2VyLWRvY3MKZ25vbWUtdmZzMgpn
bnV0bHMKZ3N0cmVhbWVyCmdzdHJlYW1lci1wbHVnaW5zLWJhc2UKZ3N0cmVhbWVyLXBsdWdpbnMt
Z29vZApnc3RyZWFtZXItdG9vbHMKZ3RrMgpndGsyLWVuZ2luZXMKZ3VjaGFybWFwCmd2ZnMKaGFs
CmhhbC1pbmZvCmhhbC1saWJzCmhkcGFybQpoaWNvbG9yLWljb24tdGhlbWUKaHVuc3BlbGwKaXNv
LWNvZGVzCmphc3Blci1saWJzCmxjbXMtbGlicwpsaWJJQ0UKbGliSURMCmxpYlNNCmxpYlgxMQps
aWJYMTEtY29tbW9uCmxpYlhTY3JuU2F2ZXIKbGliWGF1CmxpYlhjb21wb3NpdGUKbGliWGN1cnNv
cgpsaWJYZGFtYWdlCmxpYlhkbWNwCmxpYlhleHQKbGliWGZpeGVzCmxpYlhmb250CmxpYlhmdAps
aWJYaQpsaWJYaW5lcmFtYQpsaWJYbXUKbGliWHJhbmRyCmxpYlhyZW5kZXIKbGliWHJlcwpsaWJY
dApsaWJYdHN0CmxpYlh2CmxpYlh4Zjg2bWlzYwpsaWJYeGY4NnZtCmxpYmFyY2hpdmUKbGliYXJ0
X2xncGwKbGliYXN5bmNucwpsaWJhdGFzbWFydApsaWJhdmMxMzk0CmxpYmJvbm9ibwpsaWJib25v
Ym91aQpsaWJjYW5iZXJyYQpsaWJjYW5iZXJyYS1ndGsyCmxpYmNkaW8KbGliY3JvY28KbGliZGFl
bW9uCmxpYmR2CmxpYmVyYXRpb24tZm9udHMtY29tbW9uCmxpYmVyYXRpb24tc2Fucy1mb250cwps
aWJleGlmCmxpYmZvbnRlbmMKbGliZnByaW50CmxpYmdhaWwtZ25vbWUKbGliZ2RhdGEKbGliZ2xh
ZGUyCmxpYmdub21lCmxpYmdub21lY2FudmFzCmxpYmdub21la2JkCmxpYmdub21ldWkKbGliZ3Nm
CmxpYmd0b3AyCmxpYmd1ZGV2MQpsaWJnd2VhdGhlcgpsaWJpY2FsCmxpYmllYzYxODgzCmxpYmpw
ZWctdHVyYm8KbGlibWNwcApsaWJubApsaWJub3RpZnkKbGlib2dnCmxpYm9pbApsaWJwY2FwCmxp
YnBuZwpsaWJwcm94eQpsaWJwcm94eS1iaW4KbGlicHJveHktcHl0aG9uCmxpYnJhdzEzOTQKbGli
cnN2ZzIKbGlic2FtcGxlcmF0ZQpsaWJzaG91dApsaWJzbWJjbGllbnQKbGlic25kZmlsZQpsaWJz
b3VwCmxpYnRhbGxvYwpsaWJ0ZGIKbGlidGV2ZW50CmxpYnRoYWkKbGlidGhlb3JhCmxpYnRpZmYK
bGlidG9vbC1sdGRsCmxpYnVzYjEKbGlidjRsCmxpYnZpc3VhbApsaWJ2b3JiaXMKbGlid2Fjb20K
bGlid2Fjb20tZGF0YQpsaWJ3bmNrCmxpYnhjYgpsaWJ4a2JmaWxlCmxpYnhrbGF2aWVyCmxpYnhz
bHQKbWNwcAptZXNhLWRyaS1kcml2ZXJzCm1lc2EtZHJpLWZpbGVzeXN0ZW0KbWVzYS1kcmkxLWRy
aXZlcnMKbWVzYS1saWJHTAptZXNhLXByaXZhdGUtbGx2bQptb2JpbGUtYnJvYWRiYW5kLXByb3Zp
ZGVyLWluZm8KbW96aWxsYS1maWxlc3lzdGVtCm10b29scwpuYXV0aWx1cy1leHRlbnNpb25zCnBh
bmdvCnBhcnRlZApwaXhtYW4KcGx5bW91dGgtZ2RtLWhvb2tzCnBseW1vdXRoLXV0aWxzCnBtLXV0
aWxzCnBvbGtpdApwb2xraXQtZGVza3RvcC1wb2xpY3kKcHBwCnB1bHNlYXVkaW8KcHVsc2VhdWRp
by1nZG0taG9va3MKcHVsc2VhdWRpby1saWJzCnB1bHNlYXVkaW8tbGlicy1nbGliMgpwdWxzZWF1
ZGlvLXV0aWxzCnB5Y2Fpcm8KcHlnb2JqZWN0MgpweWd0azIKcHlvcmJpdApyYXJpYW4KcmFyaWFu
LWNvbXBhdApyZWRoYXQtbWVudXMKcnRraXQKc2FtYmEtY29tbW9uCnNhbWJhLXdpbmJpbmQKc2Ft
YmEtd2luYmluZC1jbGllbnRzCnNnM191dGlscy1saWJzCnNnbWwtY29tbW9uCnNtcF91dGlscwpz
b3VuZC10aGVtZS1mcmVlZGVza3RvcApzcGVleApzdGFydHVwLW5vdGlmaWNhdGlvbgpzeXN0ZW0t
Z25vbWUtdGhlbWUKc3lzdGVtLWljb24tdGhlbWUKc3lzdGVtLXNldHVwLWtleWJvYXJkCnRhZ2xp
Ygp1ZGlza3MKdW5pcXVlCnVzZXJtb2RlCnZ0ZQp3YXZwYWNrCndwYV9zdXBwbGljYW50CnhjYi11
dGlsCnhkZy11c2VyLWRpcnMKeGtleWJvYXJkLWNvbmZpZwp4bWwtY29tbW9uCnhvcmcteDExLWRy
di13YWNvbQp4b3JnLXgxMS1zZXJ2ZXItWG9yZwp4b3JnLXgxMS1zZXJ2ZXItY29tbW9uCnhvcmct
eDExLXNlcnZlci11dGlscwp4b3JnLXgxMS14YXV0aAp4b3JnLXgxMS14aW5pdAp4b3JnLXgxMS14
a2ItdXRpbHMKeHVscnVubmVyCnplbml0eQpnbGliMgpsaWJ1ZGV2Cm9wZW5zc2gKb3BlbnNzaC1j
bGllbnRzCm9wZW5zc2gtc2VydmVyCnBseW1vdXRoCnBseW1vdXRoLWNvcmUtbGlicwpmaXJzdGJv
b3QKZ2x4LXV0aWxzCnBseW1vdXRoLXN5c3RlbS10aGVtZQpzcGljZS12ZGFnZW50CndhY29tZXhw
cmVzc2tleXMKd2RhZW1vbgp4b3JnLXgxMS1kcml2ZXJzCnhvcmcteDExLXV0aWxzCnh2YXR0cgph
dXRoY29uZmlnLWd0awpidHBhcnNlcgpjcmFja2xpYi1weXRob24KbGliWHZNQwpsaWJYeGY4NmRn
YQpsaWJkbXgKbGlicmVwb3J0CmxpYnJlcG9ydC1jb21wYXQKbGlicmVwb3J0LWd0awpsaWJyZXBv
cnQtbmV3dApsaWJyZXBvcnQtcGx1Z2luLXJlcG9ydHVwbG9hZGVyCmxpYnJlcG9ydC1wbHVnaW4t
cmh0c3VwcG9ydApsaWJyZXBvcnQtcHl0aG9uCmxpYnNlbGludXgtcHl0aG9uCmxpYnRhcgpsaWJ1
c2VyLXB5dGhvbgptZXNhLWxpYkVHTAptZXNhLWxpYkdMVQptZXNhLWxpYmdibQptdGRldgpudHAK
bnRwZGF0ZQpwbHltb3V0aC1ncmFwaGljcy1saWJzCnBseW1vdXRoLXBsdWdpbi1sYWJlbApwbHlt
b3V0aC1wbHVnaW4tdHdvLXN0ZXAKcGx5bW91dGgtdGhlbWUtcmluZ3MKcHlndGsyLWxpYmdsYWRl
CnB5dGhvbi1ldGh0b29sCnB5dGhvbi1tZWgKcHl0aG9uLXNsaXAKcHl4Zjg2Y29uZmlnCnNldHVw
dG9vbApzeXN0ZW0tY29uZmlnLWRhdGUKc3lzdGVtLWNvbmZpZy1kYXRlLWRvY3MKc3lzdGVtLWNv
bmZpZy1rZXlib2FyZApzeXN0ZW0tY29uZmlnLWtleWJvYXJkLWJhc2UKc3lzdGVtLWNvbmZpZy11
c2VycwpzeXN0ZW0tY29uZmlnLXVzZXJzLWRvY3MKdXNlcm1vZGUtZ3RrCnhkZy11dGlscwp4bWxy
cGMtYwp4bWxycGMtYy1jbGllbnQKeG9yZy14MTEtZHJ2LWFjZWNhZAp4b3JnLXgxMS1kcnYtYWlw
dGVrCnhvcmcteDExLWRydi1hcG0KeG9yZy14MTEtZHJ2LWFzdAp4b3JnLXgxMS1kcnYtYXRpCnhv
cmcteDExLWRydi1jaXJydXMKeG9yZy14MTEtZHJ2LWR1bW15CnhvcmcteDExLWRydi1lbG9ncmFw
aGljcwp4b3JnLXgxMS1kcnYtZXZkZXYKeG9yZy14MTEtZHJ2LWZiZGV2CnhvcmcteDExLWRydi1m
cGl0CnhvcmcteDExLWRydi1nbGludAp4b3JnLXgxMS1kcnYtaHlwZXJwZW4KeG9yZy14MTEtZHJ2
LWkxMjgKeG9yZy14MTEtZHJ2LWk3NDAKeG9yZy14MTEtZHJ2LWludGVsCnhvcmcteDExLWRydi1r
ZXlib2FyZAp4b3JnLXgxMS1kcnYtbWFjaDY0CnhvcmcteDExLWRydi1tZ2EKeG9yZy14MTEtZHJ2
LW1vZGVzZXR0aW5nCnhvcmcteDExLWRydi1tb3VzZQp4b3JnLXgxMS1kcnYtbXV0b3VjaAp4b3Jn
LXgxMS1kcnYtbm91dmVhdQp4b3JnLXgxMS1kcnYtbnYKeG9yZy14MTEtZHJ2LW9wZW5jaHJvbWUK
eG9yZy14MTEtZHJ2LXBlbm1vdW50CnhvcmcteDExLWRydi1xeGwKeG9yZy14MTEtZHJ2LXIxMjgK
eG9yZy14MTEtZHJ2LXJlbmRpdGlvbgp4b3JnLXgxMS1kcnYtczN2aXJnZQp4b3JnLXgxMS1kcnYt
c2F2YWdlCnhvcmcteDExLWRydi1zaWxpY29ubW90aW9uCnhvcmcteDExLWRydi1zaXMKeG9yZy14
MTEtZHJ2LXNpc3VzYgp4b3JnLXgxMS1kcnYtc3luYXB0aWNzCnhvcmcteDExLWRydi10ZGZ4Cnhv
cmcteDExLWRydi10cmlkZW50CnhvcmcteDExLWRydi12NGwKeG9yZy14MTEtZHJ2LXZlc2EKeG9y
Zy14MTEtZHJ2LXZtbW91c2UKeG9yZy14MTEtZHJ2LXZtd2FyZQp4b3JnLXgxMS1kcnYtdm9pZAp4
b3JnLXgxMS1kcnYtdm9vZG9vCnhvcmcteDExLWRydi14Z2kKeG9yZy14MTEtZ2xhbW9yCmF1dGhj
b25maWcKbGlic2VsaW51eApsaWJzZWxpbnV4LXV0aWxzCnBlcmwtUG9kLUVzY2FwZXMKcGVybC1N
b2R1bGUtUGx1Z2dhYmxlCnBlcmwtbGlicwpwZXJsLVBvZC1TaW1wbGUKcGVybC12ZXJzaW9uCnBl
cmwKZ3BtLWxpYnMKbWMKdGNsCmV4cGVjdAphdXRvY29uZgphdXRvbWFrZQpnY2MKZ2l0Cmp3aG9p
cwpsaWJ0b29sCmxzb2YKbHpvLWRldmVsCm5tYXAKb3BlbnNzbC1kZXZlbApwYW0tZGV2ZWwKcGF0
Y2gKcnN5bmMKc2NyZWVuCnN5c3RlbS1jb25maWctZmlyZXdhbGwKc3lzdGVtLWNvbmZpZy1maXJl
d2FsbC10dWkKc3lzdGVtLWNvbmZpZy1uZXR3b3JrLXR1aQp0ZWxuZXQKdmltLWVuaGFuY2VkCndn
ZXQKemxpYi1kZXZlbApmaWxlCmNsb29nLXBwbApjcHAKY3JkYQpnbGliYy1kZXZlbApnbGliYy1o
ZWFkZXJzCmtlcm5lbC1oZWFkZXJzCmtlcm5lbC1kZXZlbAprZXl1dGlscy1saWJzLWRldmVsCmty
YjUtZGV2ZWwKbGliY29tX2Vyci1kZXZlbApsaWJnb21wCmxpYnNlbGludXgtZGV2ZWwKbGlic2Vw
b2wtZGV2ZWwKbHpvCmx6by1taW5pbHpvCm1wZnIKcGNpdXRpbHMKcGVybC1FcnJvcgpwZXJsLUdp
dApwcGwKcHl0aG9uLWRlY29yYXRvcgpweXRob24taXdsaWIKcHl0aG9uLXNsaXAtZGJ1cwp2aW0t
Y29tbW9uCndpcmVsZXNzLXRvb2xzCmUyZnNwcm9ncwplMmZzcHJvZ3MtbGlicwpmaWxlLWxpYnMK
Z2xpYmMKZ2xpYmMtY29tbW9uCmtleXV0aWxzLWxpYnMKa3JiNS1saWJzCmxpYmNvbV9lcnIKbGli
Z2NjCmxpYnNzCm9wZW5zc2wKcGFtCnBjaXV0aWxzLWxpYnMKc3lzdGVtLWNvbmZpZy1maXJld2Fs
bC1iYXNlCmNlbnRvcy1pbmRleGh0bWwKbGlidnB4CnJlZGhhdC1ib29rbWFya3MKbnNwcgpuc3MK
bnNzLXN5c2luaXQKbnNzLXRvb2xzCm5zcy11dGlsCmZpcmVmb3gKdGh1bmRlcmJpcmQKamF2YS0x
LjcuMC1vcGVuamRrCmdpZmxpYgpqcGFja2FnZS11dGlscwp0dG1rZmRpcgp0emRhdGEtamF2YQp4
b3JnLXgxMS1mb250LXV0aWxzCnhvcmcteDExLWZvbnRzLVR5cGUxCnRlYW12aWV3ZXIuaTY4Ngpi
NDMtb3BlbmZ3d2Yubm9hcmNoCmI0My10b29scy54ODZfNjQgCml3Lng4Nl82NAppd2wxMDAtZmly
bXdhcmUubm9hcmNoCml3bDYwMDAtZmlybXdhcmUubm9hcmNoCml3bDYwMDBnMmEtZmlybXdhcmUu
bm9hcmNoCml3bDYwNTAtZmlybXdhcmUubm9hcmNoCnN1ZG8KdmkKJWVuZAo=";

# ks-1.part
$ks1="ZmlyZXdhbGwgLS1lbmFibGVkIC0tc3NoCmluc3RhbGwKY2Ryb20KI2hhcmRkcml2ZSAtLXBhcnRp
dGlvbj0vZGV2L3NkYTEgLS1kaXI9Ly8Kcm9vdHB3ICAtLWlzY3J5cHRlZCAkNiQuUWpvNFplN3R6
S2UxQkRPJG4zRm0vbTMudkJjeWRlWHR1YU1ERVdvSmp2Rm5kQlRwckxrNFZqRVluRmhjOFloOHFR
UjcxLlYzT2Zxc201dWhqU0VmTlZKd1UvL3RaOFlPNTMvakcxCmF1dGggIC0tdXNlc2hhZG93ICAt
LXBhc3NhbGdvPXNoYTUxMgp0ZXh0CmZpcnN0Ym9vdCAtLWRpc2FibGUKa2V5Ym9hcmQgdXMKbGFu
ZyBlbl9VUy5VVEYtOApzZWxpbnV4IC0tZGlzYWJsZWQKbG9nZ2luZyAtLWxldmVsPWRlYnVnCnJl
Ym9vdAp0aW1lem9uZSAgRXVyb3BlL01vc2NvdwpuZXR3b3JrICAtLWJvb3Rwcm90bz1kaGNwIC0t
ZGV2aWNlPWV0aDAgLS1vbmJvb3Q9b24KI2lnbm9yZWRpc2sgLS1kcml2ZXM9c2RhCmJvb3Rsb2Fk
ZXIgLS1sb2NhdGlvbj1tYnIKYm9vdGxvYWRlciAtLWxvY2F0aW9uPW1iciAtLWRyaXZlb3JkZXI9
c2RiLHZkYSxzZGEgLS1hcHBlbmQ9ImNyYXNoa2VybmVsPWF1dG8gcmhnYiByaGdiIHF1aWV0IHF1
aWV0IgpjbGVhcnBhcnQgLS1hbGwgLS1pbml0bGFiZWwKemVyb21icgphdXRoY29uZmlnIC0tZW5h
Ymxlc2hhZG93IC0tcGFzc2FsZ289c2hhNTEyCmF1dG9wYXJ0IC0tZW5jcnlwdGVkIC0tcGFzc3Bo
cmFzZT0xMjM0NTYgLS1jaXBoZXI9YWVzLXh0cy1wbGFpbjY0Cg==
";

# ks-2.part
$ks2="JXBvc3QKIyEvYmluL3NoCm1rZGlyIC91c3IvbG9jYWwvc2NyaXB0cwpkZCBpZj0vZGV2L3VyYW5k
b20gb2Y9L2V0Yy9sdWtzLXBhc3N3ZCBicz0xMDI0IGNvdW50PTQKY2F0ID4gL3Vzci9sb2NhbC9z
Y3JpcHRzL2V4cF9wYXNzd19jcnlwdC5zaCA8PEVPRgojIS91c3IvYmluL2V4cGVjdApzZXQgdGlt
ZW91dCAzMApzZXQgZGV2aWNlIFtscmFuZ2UgXCRhcmd2IDAgMF0Kc2V0IHBhc3N3b3JkIFtscmFu
Z2UgXCRhcmd2IDEgMV0Kc3Bhd24gL3NiaW4vY3J5cHRzZXR1cCBsdWtzQWRkS2V5IFwkZGV2aWNl
IC9ldGMvbHVrcy1wYXNzd2QKbWF0Y2hfbWF4IDEwMDAwMApleHBlY3QgIio/YXNzcGhyYXNlOioi
CnNlbmQgLS0gIlwkcGFzc3dvcmRcciIKc2VuZCAtLSAiXHIiCmV4cGVjdCBlb2YKRU9GCgpjaG1v
ZCAreCAvdXNyL2xvY2FsL3NjcmlwdHMvZXhwX3Bhc3N3X2NyeXB0LnNoCi91c3IvbG9jYWwvc2Ny
aXB0cy9leHBfcGFzc3dfY3J5cHQuc2ggL2Rldi9zZGIyIDEyMzQ1NgovdXNyL2xvY2FsL3Njcmlw
dHMvZXhwX3Bhc3N3X2NyeXB0LnNoIC9kZXYvc2RhMiAxMjM0NTYKICAgICAgICAgICAgICAgICAg
ICAgICAgICAgICAgICAgICAgICAgICAgICAgIApjaG1vZCA0MDAgL2V0Yy9sdWtzLXBhc3N3ZApz
ZWQgLWkgInMvbm9uZS9cL2V0Y1wvbHVrcy1wYXNzd2QvIiAvZXRjL2NyeXB0dGFiCmVjaG8gImlu
c3RhbGxfaXRlbXM9XCIvZXRjL2x1a3MtcGFzc3dkXCIiID4gL2V0Yy9kcmFjdXQuY29uZi5kLzkw
LWx1a3MtcGFzc3dkLmNvbmYKCmRyYWN1dCAtZgpjYXQgL3NiaW4vZHJhY3V0IHxzZWQgInMvXCQo
dW5hbWUgLXIpL1wkKGxzIFwvbGliXC9tb2R1bGVzXC98eGFyZ3MgLW4xKS8iID4vc2Jpbi9kcmFj
dXQtbW9kIApjaG1vZCAreCAvc2Jpbi9kcmFjdXQtbW9kCi9zYmluL2RyYWN1dC1tb2QgLWYKCmNh
dCA+IC9ldGMveXVtLnJlcG9zLmQvQ2VudE9TLU1lZGlhLnJlcG8gPDxFT0YKIyBDZW50T1MtTWVk
aWEucmVwbwojCiMgIFRoaXMgcmVwbyBjYW4gYmUgdXNlZCB3aXRoIG1vdW50ZWQgRFZEIG1lZGlh
LCB2ZXJpZnkgdGhlIG1vdW50IHBvaW50IGZvcgojICBDZW50T1MtNi4gIFlvdSBjYW4gdXNlIHRo
aXMgcmVwbyBhbmQgeXVtIHRvIGluc3RhbGwgaXRlbXMgZGlyZWN0bHkgb2ZmIHRoZQojICBEVkQg
SVNPIHRoYXQgd2UgcmVsZWFzZS4KIwojIFRvIHVzZSB0aGlzIHJlcG8sIHB1dCBpbiB5b3VyIERW
RCBhbmQgdXNlIGl0IHdpdGggdGhlIG90aGVyIHJlcG9zIHRvbzoKIyAgeXVtIC0tZW5hYmxlcmVw
bz1jNi1tZWRpYSBbY29tbWFuZF0KIwojIG9yIGZvciBPTkxZIHRoZSBtZWRpYSByZXBvLCBkbyB0
aGlzOgojCiMgIHl1bSAtLWRpc2FibGVyZXBvPVwqIC0tZW5hYmxlcmVwbz1jNi1tZWRpYSBbY29t
bWFuZF0KCltjNi1tZWRpYV0KbmFtZT1DZW50T1MtJHJlbGVhc2V2ZXIgLSBNZWRpYQpiYXNldXJs
PWZpbGU6L3Zhci9kaXN0ci8KZ3BnY2hlY2s9MQplbmFibGVkPTEKZ3Bna2V5PWZpbGU6Ly8vZXRj
L3BraS9ycG0tZ3BnL1JQTS1HUEctS0VZLUNlbnRPUy02CkVPRgoKZ3JvdXBhZGQgY2hyb290ZWQK
ZWNobyAiJWNocm9vdGVkCQlBTEw9Tk9QQVNTV0Q6L3Vzci9zYmluL2Nocm9vdCIgPj4vZXRjL3N1
ZG9lcnMKZWNobyAiIiA+Pi9ldGMvc3Vkb2VycwolZW5kCgolcHJlCiMhL2Jpbi9zaApleGVjIDwg
L2Rldi90dHkzID4gL2Rldi90dHkzIDI+JjEKY2h2dCAzCmVjaG8gIiMjIyMjIyMjIyMjIyMjIyMj
IyMjIyMjIyMjIyMjIyMjIgplY2hvICIjICAgICAgICAgQ3JlYXRlIHVzZXIgICAgICAgICAgIyIK
ZWNobyAiIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMiCndoaWxlIFsgIiR1c2VybmFt
ZSIgPT0gIiIgXTsgZG8KICBlY2hvIC1uICJQbGVhc2UgZW50ZXIgZGVzaXJlZCBzeXN0ZW0gdXNl
cjogIgogIHJlYWQgdXNlcm5hbWUKZG9uZQp3aGlsZSBbICIkdXBhc3N3b3JkIiA9PSAiIiBdOyBk
bwogIGVjaG8gLW4gIkVudGVyIHVzZXIgcGFzc3dvcmQ6ICIKICByZWFkIHVwYXNzd29yZApkb25l
CmVjaG8gIiR1c2VybmFtZSIgPi90bXAvdXNlcm5hbWUKZWNobyAiJHVwYXNzd29yZCIgPi90bXAv
dXBhc3N3b3JkCmVjaG8gIiIKZWNobyAiIgplY2hvICIjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMj
IyMjIyMjIyIKZWNobyAiIyAgICBOZXR3b3JrIGNvbmZpZ3VyYXRpb24gICAgICMiCmVjaG8gIiMj
IyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIgplY2hvIC1uICJQbGVhc2UgZW50ZXIgSVAt
YWRkcmVzcyAob3IgbGVhdmUgYmxhbmsgZm9yIERIQ1ApOiIKcmVhZCB1aXBhZGRyZXNzCmlmIFsg
IiR1aXBhZGRyZXNzIiAhPSAiIiBdOyB0aGVuCiAgICBlY2hvICIjIyMjIyMjIyMjIyMjIyMjIyMj
IyMjIyMjIyMjIyMjIyIKICAgIGVjaG8gLW4gIlBsZWFzZSBlbnRlciBuZXRtYXNrICgyNTUuMjU1
LjI1NS4wKToiCiAgICByZWFkIHVuZXRtYXNrCiAgICBpZiBbICIkdW5ldG1hc2siID09ICIiIF07
IHRoZW4KCXVuZXRtYXNrPSIyNTUuMjU1LjI1NS4wIgogICAgZmkKICAgIGVjaG8gIiMjIyMjIyMj
IyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIgogICAgZWNobyAtbiAiUGxlYXNlIGVudGVyIGdhdGV3
YXkgaXA6IgogICAgcmVhZCB1Z3cKICAgIGVjaG8gIiMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMj
IyMjIyMjIgogICAgZWNobyAtbiAiUGxlYXNlIGVudGVyIGRuczoiCiAgICByZWFkIHVkbnMKY2F0
ID4gL3RtcC9pZmNmZy1ldGgwIDw8RU9GCkRFVklDRT1ldGgwClRZUEU9RXRoZXJuZXQKT05CT09U
PXllcwpOTV9DT05UUk9MTEVEPXllcwpERUZST1VURT15ZXMKUEVFUkROUz15ZXMKUEVFUlJPVVRF
Uz15ZXMKSVBWNF9GQUlMVVJFX0ZBVEFMPXllcwpJUFY2SU5JVD1ubwpOQU1FPSJTeXN0ZW0gZXRo
MCIKQk9PVFBST1RPPXN0YXRpYwpJUEFERFI9JHVpcGFkZHJlc3MKTkVUTUFTSz0kdW5ldG1hc2sK
R0FURVdBWT0kdWd3CkROUzE9JHVkbnMKRE5TMj04LjguOC44CkVPRgpmaQpjaHZ0IDEKJWVuZAoK
JXBvc3QgLS1ub2Nocm9vdAojIS9iaW4vc2gKI21rZGlyIC1wIC9tbnQvc291cmNlCiNtb3VudCAv
ZGV2L3NkYTEgL21udC9zb3VyY2UKbWtkaXIgLXAgL21udC9zeXNpbWFnZS92YXIvZGlzdHIvUGFj
a2FnZXMKbWtkaXIgLXAgL21udC9zeXNpbWFnZS92YXIvZGlzdHIvcmVwb2RhdGEKY3AgL3RtcC91
cGFzc3dvcmQgL21udC9zeXNpbWFnZS90bXAKY3AgL3RtcC91c2VybmFtZSAvbW50L3N5c2ltYWdl
L3RtcApjcCAvdG1wL2lmY2ZnLWV0aDAgL21udC9zeXNpbWFnZS90bXAKY3AgL21udC9zb3VyY2Uv
UGFja2FnZXMvKiAvbW50L3N5c2ltYWdlL3Zhci9kaXN0ci9QYWNrYWdlcy8KY3AgL21udC9zb3Vy
Y2UvcmVwb2RhdGEvKiAvbW50L3N5c2ltYWdlL3Zhci9kaXN0ci9yZXBvZGF0YS8KY3AgL21udC9z
b3VyY2UvKiAvbW50L3N5c2ltYWdlL3Zhci9kaXN0ci8KJWVuZAoKJXBvc3QKdXNlcm5hbWU9YGNh
dCAvdG1wL3VzZXJuYW1lYAp1cGFzc3dvcmQ9YGNhdCAvdG1wL3VwYXNzd29yZGAKY3AgL3RtcC9p
ZmNmZy1ldGgwIC9ldGMvc3lzY29uZmlnL25ldHdvcmstc2NyaXB0cy9pZmNmZy1ldGgwCmFkZHVz
ZXIgJHVzZXJuYW1lIC0tcGFzc3dvcmQgYG9wZW5zc2wgcGFzc3dkIC0xICIkdXBhc3N3b3JkImAK
dXNlcm1vZCAtZyBjaHJvb3RlZCAkdXNlcm5hbWUKCnl1bSAtLWRpc2FibGVyZXBvPVwqIC0tZW5h
YmxlcmVwbz1jNi1tZWRpYSBpbnN0YWxsIC15IC92YXIvZGlzdHIvUGFja2FnZXMvdGVhbXZpZXdl
cl9saW51eC5ycG0KY3AgL29wdC90ZWFtdmlld2VyL3R2X2Jpbi9zY3JpcHQvdGVhbXZpZXdlcmQu
c3lzdiAvZXRjL2luaXQuZC8KIyBjaGtjb25maWcgLS1sZXZlbCAxMjM0NSB0ZWFtdmlld2VyZC5z
eXN2IG9uCgpjYXQgPj4gL2hvbWUvJHVzZXJuYW1lLy5iYXNoX3Byb2ZpbGUgPDxFT0YKaWYgcmM9
XGB0dHl8Z3JlcCAtYyAidHR5IlxgCnRoZW4KICBzdWRvIGNocm9vdCAtLXVzZXJzcGVjPSR1c2Vy
bmFtZSBcJEhPTUUvY2hyb290IHN1ZG8gL29wdC90ZWFtdmlld2VyL3R2X2Jpbi9zY3JpcHQvdGVh
bXZpZXdlcmQuc3lzdiByZXN0YXJ0CiAgc3VkbyBjaHJvb3QgLS11c2Vyc3BlYz0kdXNlcm5hbWUg
XCRIT01FL2Nocm9vdCBzdWRvIC11ICR1c2VybmFtZSAvdXNyL2Jpbi9zdGFydHggLS0gOjEKZWxz
ZQogIHN1ZG8gY2hyb290IC0tdXNlcnNwZWM9JHVzZXJuYW1lIFwkSE9NRS9jaHJvb3QgL2Jpbi9i
YXNoCmZpCmxvZ291dApFT0YKY3AgL2V0Yy9zeXNjb25maWcvaW5pdCAvZXRjL3N5c2NvbmZpZy9p
bml0LmJhawpjYXQgL2V0Yy9zeXNjb25maWcvaW5pdCB8c2VkIC1lICdzL1xcWzEtNlxcXS9bMS0y
XS8nID4vdG1wL2luaXQudG1wCmNwIC90bXAvaW5pdC50bXAgL2V0Yy9zeXNjb25maWcvaW5pdAoK
CmNhdCA+IC9ldGMvc3lzY29uZmlnL2luaXQgPDxFT0YKIyBjb2xvciA9PiBuZXcgUkg2LjAgYm9v
dHVwCiMgdmVyYm9zZSA9PiBvbGQtc3R5bGUgYm9vdHVwCiMgYW55dGhpbmcgZWxzZSA9PiBuZXcg
c3R5bGUgYm9vdHVwIHdpdGhvdXQgQU5TSSBjb2xvcnMgb3IgcG9zaXRpb25pbmcKQk9PVFVQPWNv
bG9yCiMgY29sdW1uIHRvIHN0YXJ0ICJbICBPSyAgXSIgbGFiZWwgaW4uClJFU19DT0w9NjAKIyB0
ZXJtaW5hbCBzZXF1ZW5jZSB0byBtb3ZlIHRvIHRoYXQgY29sdW1uLiBZb3UgY291bGQgY2hhbmdl
IHRoaXMKIyB0byBzb21ldGhpbmcgbGlrZSAidHB1dCBocGEgJHtSRVNfQ09MfSIgaWYgeW91ciB0
ZXJtaW5hbCBzdXBwb3J0cyBpdApNT1ZFX1RPX0NPTD0iZWNobyAtZW4gWzFdMDMzWyR7UkVTX0NP
TH1HIgojIHRlcm1pbmFsIHNlcXVlbmNlIHRvIHNldCBjb2xvciB0byBhICdzdWNjZXNzJyBjb2xv
ciAoY3VycmVudGx5OiBncmVlbikKU0VUQ09MT1JfU1VDQ0VTUz0iZWNobyAtZW4gWzFdMDMzWzA7
MzJtIgojIHRlcm1pbmFsIHNlcXVlbmNlIHRvIHNldCBjb2xvciB0byBhICdmYWlsdXJlJyBjb2xv
ciAoY3VycmVudGx5OiByZWQpClNFVENPTE9SX0ZBSUxVUkU9ImVjaG8gLWVuIFsxXTAzM1swOzMx
bSIKIyB0ZXJtaW5hbCBzZXF1ZW5jZSB0byBzZXQgY29sb3IgdG8gYSAnd2FybmluZycgY29sb3Ig
KGN1cnJlbnRseTogeWVsbG93KQpTRVRDT0xPUl9XQVJOSU5HPSJlY2hvIC1lbiBbMV0wMzNbMDsz
M20iCiMgdGVybWluYWwgc2VxdWVuY2UgdG8gcmVzZXQgdG8gdGhlIGRlZmF1bHQgY29sb3IuClNF
VENPTE9SX05PUk1BTD0iZWNobyAtZW4gWzFdMDMzWzA7MzltIgojIFNldCB0byBhbnl0aGluZyBv
dGhlciB0aGFuICdubycgdG8gYWxsb3cgaG90a2V5IGludGVyYWN0aXZlIHN0YXJ0dXAuLi4KUFJP
TVBUPXllcwojIFNldCB0byAneWVzJyB0byBhbGxvdyBwcm9iaW5nIGZvciBkZXZpY2VzIHdpdGgg
c3dhcCBzaWduYXR1cmVzCkFVVE9TV0FQPW5vCiMgV2hhdCB0dHlzIHNob3VsZCBnZXR0eXMgYmUg
c3RhcnRlZCBvbj8KQUNUSVZFX0NPTlNPTEVTPS9kZXYvdHR5WzEtMl0KIyBTZXQgdG8gJy9zYmlu
L3N1bG9naW4nIHRvIHByb21wdCBmb3IgcGFzc3dvcmQgb24gc2luZ2xlLXVzZXIgbW9kZQojIFNl
dCB0byAnL3NiaW4vc3VzaGVsbCcgb3RoZXJ3aXNlClNJTkdMRT0vc2Jpbi9zdXNoZWxsCkVPRgoK
Y2F0ID4gL2V0Yy9pbml0L3N0YXJ0LXR0eXMub3ZlcnJpZGUgPDxFT0YKIwojIFRoaXMgc2Vydmlj
ZSBzdGFydHMgdGhlIGNvbmZpZ3VyZWQgbnVtYmVyIG9mIGdldHR5cy4KIwojIERvIG5vdCBlZGl0
IHRoaXMgZmlsZSBkaXJlY3RseS4gSWYgeW91IHdhbnQgdG8gY2hhbmdlIHRoZSBiZWhhdmlvdXIs
CiMgcGxlYXNlIGNyZWF0ZSBhIGZpbGUgc3RhcnQtdHR5cy5vdmVycmlkZSBhbmQgcHV0IHlvdXIg
Y2hhbmdlcyB0aGVyZS4KCnN0YXJ0IG9uIHN0b3BwZWQgcmMgUlVOTEVWRUw9WzIzNDVdCgplbnYg
QUNUSVZFX0NPTlNPTEVTPS9kZXYvdHR5WzEtMl0KZW52IFhfVFRZPS9kZXYvdHR5MQp0YXNrCnNj
cmlwdAogICAgICAgIC4gL2V0Yy9zeXNjb25maWcvaW5pdAogICAgICAgIGZvciB0dHkgaW4gXCQo
ZWNobyBcJEFDVElWRV9DT05TT0xFUykgOyBkbwogICAgICAgICAgICAgICAgWyAiXCRSVU5MRVZF
TCIgPSAiNSIgLWEgIlwkdHR5IiA9ICJcJFhfVFRZIiBdICYmIGNvbnRpbnVlCiAgICAgICAgICAg
ICAgICBpZiBbICJcJHR0eSIgPSAiL2Rldi90dHkxIiBdOyB0aGVuCiAgICAgICAgICAgIAkgICAg
aW5pdGN0bCBzdGFydCBhdXRvbG9naW4gVFRZPVwkdHR5CiAgICAJCWVsc2UKICAgICAgICAgICAg
ICAgICAgICBpbml0Y3RsIHN0YXJ0IHR0eSBUVFk9XCR0dHkKICAgICAgICAJZmkKICAgICAgICBk
b25lCmVuZCBzY3JpcHQKRU9GCgpjYXQgPiAvZXRjL2luaXQvYXV0b2xvZ2luLmNvbmYgPDxFT0YK
IyB0dHkgLSBnZXR0eQojCiMgVGhpcyBzZXJ2aWNlIG1haW50YWlucyBhIGdldHR5IG9uIHRoZSBz
cGVjaWZpZWQgZGV2aWNlLgojCiMgRG8gbm90IGVkaXQgdGhpcyBmaWxlIGRpcmVjdGx5LiBJZiB5
b3Ugd2FudCB0byBjaGFuZ2UgdGhlIGJlaGF2aW91ciwKIyBwbGVhc2UgY3JlYXRlIGEgZmlsZSB0
dHkub3ZlcnJpZGUgYW5kIHB1dCB5b3VyIGNoYW5nZXMgdGhlcmUuCgpzdG9wIG9uIHJ1bmxldmVs
IFtTMDE2XQoKcmVzcGF3bgppbnN0YW5jZSBcJFRUWQpleGVjIC9zYmluL21pbmdldHR5IC0tYXV0
b2xvZ2luICR1c2VybmFtZSBcJFRUWQp1c2FnZSAndHR5IFRUWT0vZGV2L3R0eVggIC0gd2hlcmUg
WCBpcyBjb25zb2xlIGlkJwpFT0YKCmVjaG8gIk5PX1BBU1NXT1JEX0NPTlNPTEUgdHR5MTp0dHky
OnR0eTM6dHR5NDp0dHk1OnR0eTYiID4+L2V0Yy9sb2dpbi5kZWZzCm1rZGlyIC1wIC9ob21lLyR1
c2VybmFtZS9jaHJvb3Qve2Rldixwcm9jLHN5cyx0bXAsZGV2L3B0cyxkZXYvc2htLGRldi9pbnB1
dCx2YXIvcnVuLGV0Yyx2YXIvZGlzdHIsbWVkaWEvQ2VudE9TfQoKbW91bnQgLS1iaW5kIC9kZXYv
IC9ob21lLyR1c2VybmFtZS9jaHJvb3QvZGV2Cm1vdW50IC0tYmluZCAvcHJvYy8gL2hvbWUvJHVz
ZXJuYW1lL2Nocm9vdC9wcm9jCm1vdW50IC0tYmluZCAvc3lzIC9ob21lLyR1c2VybmFtZS9jaHJv
b3Qvc3lzCm1vdW50IC0tYmluZCAvdG1wIC9ob21lLyR1c2VybmFtZS9jaHJvb3QvdG1wCm1vdW50
IC0tYmluZCAvZGV2L3B0cyAvaG9tZS8kdXNlcm5hbWUvY2hyb290L2Rldi9wdHMKbW91bnQgLS1i
aW5kIC9kZXYvc2htIC9ob21lLyR1c2VybmFtZS9jaHJvb3QvZGV2L3NobQptb3VudCAtLWJpbmQg
L3Zhci9ydW4gL2hvbWUvJHVzZXJuYW1lL2Nocm9vdC92YXIvcnVuCm1vdW50IC0tYmluZCAvZGV2
L2lucHV0IC9ob21lLyR1c2VybmFtZS9jaHJvb3QvZGV2L2lucHV0Cm1vdW50IC0tYmluZCAvdmFy
L2Rpc3RyIC9ob21lLyR1c2VybmFtZS9jaHJvb3QvdmFyL2Rpc3RyCm1vdW50IC0tYmluZCAvdmFy
L2Rpc3RyIC9ob21lLyR1c2VybmFtZS9jaHJvb3QvbWVkaWEvQ2VudE9TCm1rZGlyIC1wIC9tZWRp
YS9DZW50T1MKbW91bnQgLS1iaW5kIC92YXIvZGlzdHIgL21lZGlhL0NlbnRPUwoKY2F0ID4+IC9l
dGMvcmMubG9jYWwgPDxFT0YKbW91bnQgLS1iaW5kIC9kZXYvIC9ob21lLyR1c2VybmFtZS9jaHJv
b3QvZGV2Cm1vdW50IC0tYmluZCAvcHJvYy8gL2hvbWUvJHVzZXJuYW1lL2Nocm9vdC9wcm9jCm1v
dW50IC0tYmluZCAvc3lzIC9ob21lLyR1c2VybmFtZS9jaHJvb3Qvc3lzCm1vdW50IC0tYmluZCAv
dG1wIC9ob21lLyR1c2VybmFtZS9jaHJvb3QvdG1wCm1vdW50IC0tYmluZCAvZGV2L3B0cyAvaG9t
ZS8kdXNlcm5hbWUvY2hyb290L2Rldi9wdHMKbW91bnQgLS1iaW5kIC9kZXYvc2htIC9ob21lLyR1
c2VybmFtZS9jaHJvb3QvZGV2L3NobQptb3VudCAtLWJpbmQgL3Zhci9ydW4gL2hvbWUvJHVzZXJu
YW1lL2Nocm9vdC92YXIvcnVuCm1vdW50IC0tYmluZCAvZGV2L2lucHV0IC9ob21lLyR1c2VybmFt
ZS9jaHJvb3QvZGV2L2lucHV0Cm1vdW50IC0tYmluZCAvdmFyL2Rpc3RyIC9ob21lLyR1c2VybmFt
ZS9jaHJvb3QvdmFyL2Rpc3RyCm1vdW50IC0tYmluZCAvdmFyL2Rpc3RyIC9ob21lLyR1c2VybmFt
ZS9jaHJvb3QvbWVkaWEvQ2VudE9TCkVPRgoKY2F0ID4gL2hvbWUvJHVzZXJuYW1lL2Nocm9vdC9l
dGMveXVtLnJlcG9zLmQvQ2VudE9TLU1lZGlhLnJlcG8gPDxFT0YKIyBDZW50T1MtTWVkaWEucmVw
bwojCiMgIFRoaXMgcmVwbyBjYW4gYmUgdXNlZCB3aXRoIG1vdW50ZWQgRFZEIG1lZGlhLCB2ZXJp
ZnkgdGhlIG1vdW50IHBvaW50IGZvcgojICBDZW50T1MtNi4gIFlvdSBjYW4gdXNlIHRoaXMgcmVw
byBhbmQgeXVtIHRvIGluc3RhbGwgaXRlbXMgZGlyZWN0bHkgb2ZmIHRoZQojICBEVkQgSVNPIHRo
YXQgd2UgcmVsZWFzZS4KIwojIFRvIHVzZSB0aGlzIHJlcG8sIHB1dCBpbiB5b3VyIERWRCBhbmQg
dXNlIGl0IHdpdGggdGhlIG90aGVyIHJlcG9zIHRvbzoKIyAgeXVtIC0tZW5hYmxlcmVwbz1jNi1t
ZWRpYSBbY29tbWFuZF0KIwojIG9yIGZvciBPTkxZIHRoZSBtZWRpYSByZXBvLCBkbyB0aGlzOgoj
CiMgIHl1bSAtLWRpc2FibGVyZXBvPVwqIC0tZW5hYmxlcmVwbz1jNi1tZWRpYSBbY29tbWFuZF0K
CltjNi1tZWRpYV0KbmFtZT1DZW50T1MtXCRyZWxlYXNldmVyIC0gTWVkaWEKYmFzZXVybD1maWxl
Oi92YXIvZGlzdHIvCmdwZ2NoZWNrPTEKZW5hYmxlZD0xCmdwZ2tleT1maWxlOi8vL2V0Yy9wa2kv
cnBtLWdwZy9SUE0tR1BHLUtFWS1DZW50T1MtNgpFT0YKY3AgL2V0Yy95dW0ucmVwb3MuZC9DZW50
T1MtTWVkaWEucmVwbyAvaG9tZS8kdXNlcm5hbWUvY2hyb290L2V0Yy95dW0ucmVwb3MuZC9DZW50
T1MtTWVkaWEucmVwbwoKY2F0ID4gL2hvbWUvJHVzZXJuYW1lL2Nocm9vdC9ldGMvcGFtLmQveHNl
cnZlciA8PEVPRgoKIyVQQU0tMS4wCmF1dGggc3VmZmljaWVudCBwYW1fcm9vdG9rLnNvCiNhdXRo
IHJlcXVpcmVkIHBhbV9jb25zb2xlLnNvCmF1dGggc3VmZmljaWVudCBwYW1fcGVybWl0LnNvCmFj
Y291bnQgc3VmZmljaWVudCBwYW1fcGVybWl0LnNvCnNlc3Npb24gb3B0aW9uYWwgcGFtX2tleWlu
aXQuc28gZm9yY2UgcmV2b2tlCkVPRgoKCmNwIC9ldGMvcmVzb2x2LmNvbmYgL2hvbWUvJHVzZXJu
YW1lL2Nocm9vdC9ldGMvcmVzb2x2LmNvbmYKcnBtIC0tcmVidWlsZGRiIC0tcm9vdD0vaG9tZS8k
dXNlcm5hbWUvY2hyb290L3Zhci9saWIvcnBtCnJwbSAtaSAtLXJvb3Q9L2hvbWUvJHVzZXJuYW1l
L2Nocm9vdCAtLW5vZGVwcyAlY2VudF9yZWwlCnl1bSAtLWRpc2FibGVyZXBvPVwqIC0tZW5hYmxl
cmVwbz1jNi1tZWRpYSAtLWluc3RhbGxyb290PS9ob21lLyR1c2VybmFtZS9jaHJvb3QgaW5zdGFs
bCAteSBycG0tYnVpbGQgeXVtCgo=";

# ks-3.part
$ks3="Y2hyb290IC9ob21lLyR1c2VybmFtZS9jaHJvb3QgeXVtIC0tZGlzYWJsZXJlcG89XCogLS1lbmFi
bGVyZXBvPWM2LW1lZGlhIGluc3RhbGwgLXkgL3Zhci9kaXN0ci9QYWNrYWdlcy90ZWFtdmlld2Vy
Lmk2ODYucnBtCmNocm9vdCAvaG9tZS8kdXNlcm5hbWUvY2hyb290IGNwIC9vcHQvdGVhbXZpZXdl
ci90dl9iaW4vc2NyaXB0L3RlYW12aWV3ZXJkLnN5c3YgL2V0Yy9pbml0LmQvCiMgY2hyb290IC9o
b21lLyR1c2VybmFtZS9jaHJvb3QgY2hrY29uZmlnIC0tbGV2ZWwgMTIzNDU2IHRlYW12aWV3ZXJk
LnN5c3Ygb24KCmNocm9vdCAvaG9tZS8kdXNlcm5hbWUvY2hyb290IGFkZHVzZXIgJHVzZXJuYW1l
IC0tcGFzc3dvcmQgYG9wZW5zc2wgcGFzc3dkIC0xICIkdXBhc3N3b3JkImAKIyBjaHJvb3QgL2hv
bWUvJHVzZXJuYW1lL2Nocm9vdCBlY2hvICR1c2VybmFtZTokdXBhc3N3b3JkIHwgY2hwYXNzd2QK
IyBjaHJvb3QgL2hvbWUvJHVzZXJuYW1lL2Nocm9vdCBlY2hvIHJvb3Q6JHVwYXNzd29yZCB8IGNo
cGFzc3dkCgplY2hvICJuYW1lc2VydmVyIDguOC44LjgiID4vaG9tZS8kdXNlcm5hbWUvY2hyb290
L2V0Yy9yZXNvbHYuY29uZgplY2hvICIkdXNlcm5hbWUgICAgICAgIEFMTD0oQUxMKSAgICAgICBO
T1BBU1NXRDogQUxMIiA+Pi9ob21lLyR1c2VybmFtZS9jaHJvb3QvZXRjL3N1ZG9lcnMKCmNhdCA+
IC9ob21lLyR1c2VybmFtZS9jaHJvb3QvaG9tZS8kdXNlcm5hbWUvLmJhc2hfcHJvZmlsZSA8PEVP
RgovdXNyL2Jpbi9zdGFydHggLS0gOjEKbG9nb3V0CkVPRgoKbWtkaXIgLXAgL2hvbWUvJHVzZXJu
YW1lL2Nocm9vdC9ob21lLyR1c2VybmFtZS8uY29uZmlnL2F1dG9zdGFydApjYXQgPiAvaG9tZS8k
dXNlcm5hbWUvY2hyb290L2hvbWUvJHVzZXJuYW1lLy5jb25maWcvYXV0b3N0YXJ0L3RlYW12aWV3
ZXIuZGVza3RvcCA8PEVPRgpbRGVza3RvcCBFbnRyeV0KVHlwZT1BcHBsaWNhdGlvbgpFeGVjPS9v
cHQvdGVhbXZpZXdlci90dl9iaW4vc2NyaXB0L3RlYW12aWV3ZXIKSGlkZGVuPWZhbHNlClgtR05P
TUUtQXV0b3N0YXJ0LWVuYWJsZWQ9dHJ1ZQpOYW1lW2VuX1VTXT10ZWFtCk5hbWU9dGVhbQpDb21t
ZW50W2VuX1VTXT0KQ29tbWVudD0KRU9GCgpjaG93biAtUiAkdXNlcm5hbWU6JHVzZXJuYW1lIC9o
b21lLyR1c2VybmFtZS9jaHJvb3QvaG9tZS8kdXNlcm5hbWUKY3AgL2V0Yy9tdGFiIC9ob21lLyR1
c2VybmFtZS9jaHJvb3QvZXRjLwplY2hvICJuZXQuaXB2Ni5jb25mLmFsbC5kaXNhYmxlX2lwdjYg
PSAxIiA+PiAvZXRjL3N5c2N0bC5jb25mCmVjaG8gIm5ldC5pcHY2LmNvbmYuZGVmYXVsdC5kaXNh
YmxlX2lwdjYgPSAxIiA+PiAvZXRjL3N5c2N0bC5jb25mCgpta2RpciAvdG1wL2ZjdXR0ZXIKCmNh
dCA+IC90bXAvZmN1dHRlci9ta2ZjdXR0ZXIuc2g8PEVPRgp0YXIgeGpmIC92YXIvZGlzdHIvUGFj
a2FnZXMvYnJvYWRjb20td2wtNS4xMDAuMTM4LnRhci5iejIgLUMgL3RtcC9mY3V0dGVyCnRhciB4
amYgL3Zhci9kaXN0ci9QYWNrYWdlcy9iNDMtZndjdXR0ZXItMDE4LnRhci5iejIgLUMgL3RtcC9m
Y3V0dGVyCmNkIC90bXAvZmN1dHRlci9iNDMtZndjdXR0ZXItMDE4Cm1ha2UKbWFrZSBpbnN0YWxs
CkVPRgoKY2htb2QgK3ggL3RtcC9mY3V0dGVyL21rZmN1dHRlci5zaAoKL3RtcC9mY3V0dGVyL21r
ZmN1dHRlci5zaApleHBvcnQgRklSTVdBUkVfSU5TVEFMTF9ESVI9Ii9saWIvZmlybXdhcmUiCi91
c3IvbG9jYWwvYmluL2I0My1md2N1dHRlciAtdyAiJEZJUk1XQVJFX0lOU1RBTExfRElSIiAvdG1w
L2ZjdXR0ZXIvYnJvYWRjb20td2wtNS4xMDAuMTM4L2xpbnV4L3dsX2Fwc3RhLm8KCm1rZGlyIC1w
IC9ob21lLyR1c2VybmFtZS9jaHJvb3QvaG9tZS8kdXNlcm5hbWUvLmdjb25mL2FwcHMvZ25vbWUt
dGVybWluYWwvcHJvZmlsZXMvRGVmYXVsdAoKY2F0ID4gL2hvbWUvJHVzZXJuYW1lL2Nocm9vdC9o
b21lLyR1c2VybmFtZS8uZ2NvbmYvYXBwcy9nbm9tZS10ZXJtaW5hbC9wcm9maWxlcy9EZWZhdWx0
LyVnY29uZi54bWw8PEVPRgo8P3htbCB2ZXJzaW9uPSIxLjAiPz4KPGdjb25mPgoJPGVudHJ5IG5h
bWU9ImJhY2tncm91bmRfZGFya25lc3MiIG10aW1lPSIxNDI1MTg3MzA5IiB0eXBlPSJmbG9hdCIg
dmFsdWU9IjAuNDkxOTU0MDI4NjA2NDE0NzkiLz4KCTxlbnRyeSBuYW1lPSJiYWNrZ3JvdW5kX3R5
cGUiIG10aW1lPSIxNDI1MTg3MzA5IiB0eXBlPSJzdHJpbmciPgoJCTxzdHJpbmd2YWx1ZT50cmFu
c3BhcmVudDwvc3RyaW5ndmFsdWU+Cgk8L2VudHJ5PgoJPGVudHJ5IG5hbWU9ImJvbGRfY29sb3Jf
c2FtZV9hc19mZyIgbXRpbWU9IjE0MjUxODcwOTQiIHR5cGU9ImJvb2wiIHZhbHVlPSJ0cnVlIi8+
Cgk8ZW50cnkgbmFtZT0idXNlX3RoZW1lX2NvbG9ycyIgbXRpbWU9IjE0MjUxODczMDkiIHR5cGU9
ImJvb2wiIHZhbHVlPSJmYWxzZSIvPgoJPGVudHJ5IG5hbWU9ImZvbnQiIG10aW1lPSIxNDI1MTg3
MzA5IiB0eXBlPSJzdHJpbmciPgoJCTxzdHJpbmd2YWx1ZT5Db3VyaWVyIDEwIFBpdGNoIDEwPC9z
dHJpbmd2YWx1ZT4KCTwvZW50cnk+Cgk8ZW50cnkgbmFtZT0idXNlX3N5c3RlbV9mb250IiBtdGlt
ZT0iMTQyNTE4NzMwOSIgdHlwZT0iYm9vbCIgdmFsdWU9ImZhbHNlIi8+Cgk8ZW50cnkgbmFtZT0i
cGFsZXR0ZSIgbXRpbWU9IjE0MjUxODczMDkiIHR5cGU9InN0cmluZyI+CgkJPHN0cmluZ3ZhbHVl
PiMyRTJFMzQzNDM2MzY6I0NDQ0MwMDAwMDAwMDojNEU0RTlBOUEwNjA2OiNDNEM0QTBBMDAwMDA6
IzM0MzQ2NTY1QTRBNDojNzU3NTUwNTA3QjdCOiMwNjA2OTgyMDlBOUE6I0QzRDNEN0Q3Q0ZDRjoj
NTU1NTU3NTc1MzUzOiNFRkVGMjkyOTI5Mjk6IzhBOEFFMkUyMzQzNDojRkNGQ0U5RTk0RjRGOiM3
MjcyOUY5RkNGQ0Y6I0FEQUQ3RjdGQThBODojMzQzNEUyRTJFMkUyOiNFRUVFRUVFRUVDRUM8L3N0
cmluZ3ZhbHVlPgoJPC9lbnRyeT4KCTxlbnRyeSBuYW1lPSJiYWNrZ3JvdW5kX2NvbG9yIiBtdGlt
ZT0iMTQyNTE4NzMwOSIgdHlwZT0ic3RyaW5nIj4KCQk8c3RyaW5ndmFsdWU+IzAwMDAwMDAwMDAw
MDwvc3RyaW5ndmFsdWU+Cgk8L2VudHJ5PgoJPGVudHJ5IG5hbWU9InZpc2libGVfbmFtZSIgbXRp
bWU9IjE0MjUxODczMDkiIHR5cGU9InN0cmluZyI+CgkJPHN0cmluZ3ZhbHVlPkRlZmF1bHQ8L3N0
cmluZ3ZhbHVlPgoJPC9lbnRyeT4KCTxlbnRyeSBuYW1lPSJib2xkX2NvbG9yIiBtdGltZT0iMTQy
NTE4NzMwOSIgdHlwZT0ic3RyaW5nIj4KCQk8c3RyaW5ndmFsdWU+IzAwMDAwMDAwMDAwMDwvc3Ry
aW5ndmFsdWU+Cgk8L2VudHJ5PgoJPGVudHJ5IG5hbWU9ImZvcmVncm91bmRfY29sb3IiIG10aW1l
PSIxNDI1MTg3MzA5IiB0eXBlPSJzdHJpbmciPgoJCTxzdHJpbmd2YWx1ZT4jMDAwMEZGRkYwMUZD
PC9zdHJpbmd2YWx1ZT4KCTwvZW50cnk+CjwvZ2NvbmY+CkVPRgpjaG93biAtUiAkdXNlcm5hbWU6
JHVzZXJuYW1lIC9ob21lLyR1c2VybmFtZS9jaHJvb3QvaG9tZS8kdXNlcm5hbWUKCiVlbmQK
";


sub prepareDirs {
  #
  # Creation and preparation of necessary directories
  #
  $source_iso=$_[0];
  print "---- Preparing new distr and dirs ---- \n";
  # Create a directory to mount your source.
  # Create a working directory for your customized media.
  print " --- Preparing dirs\n";
  if ( -d "$own_dir/$ks_dir" ) {
    print "  -- Dir $own_dir/$ks_dir already exist\n";
  } else {
    print "  -- Creating $own_dir/$ks_dir\n";
    $rc=`mkdir -p $own_dir/$ks_dir`;
  };
  if ( -d "$distr_dir") { 
    print "  -- Dir $distr_dir already exist\n";
  } else {
    print "  -- Creating dir $distr_dir\n";
    $rc=`mkdir -p $distr_dir`;
  };
  if ( -d "$distr_dir/$src_dir") {
    print "  -- Dir $distr_dir/$src_dir already exist\n";
  } else {
    print "  -- Creating dir $distr_dir/$src_dir\n";
    $rc=`mkdir -p $distr_dir/$src_dir`;
  };
  if ( -d "$distr_dir/$custom_dir") { 
    print "  -- Dir $distr_dir/$custom_dir already exist\n";
  } else {
    print "  -- Creating dir $distr_dir/$custom_dir \n";
    $rc=`mkdir -p $distr_dir/$custom_dir`;
  };
  if ( -d "$distr_dir/$dest_iso_dir") { 
    print "  -- Dir $distr_dir/$dest_iso_dir already exist\n";
  } else {
    print "  -- Creating dir $distr_dir/$dest_iso_dir \n";
    $rc=`mkdir -p $distr_dir/$dest_iso_dir`;
  };
  if ($source_iso) {
    # Copy the source media to the working directory.
    print "\nWarning. From this moment you should be careful. In the next step would be to delete the folder $distr_dir/$custom_dir and copied from the original disk. All the developments in the $distr_dir/$custom_dir will be removed. (enter \"YES\" to continue): ";
    $answer = <STDIN>;
    if ($answer =~ /YES/) { 
      # Loop mount the source ISO you are modifying. (Download from Red Hat / CentOS.)
      print " --- Preparing source iso \n";
      $rc=`mount | grep -c $distr_dir/$src_dir`;
      if ($rc=="1") {
        print "  -- Iso already mounted\n";
      } else {
        print "  -- Mount ISO as source in $distr_dir/$src_dir\n";
        $rc=`mount -o loop $source_iso $distr_dir/$src_dir`;
      };
      print "  -- Deleting and copying source iso files \n";
      $rc=`rm -rf $distr_dir/$custom_dir`;
      $rc=`cp -r $distr_dir/$src_dir/. $distr_dir/$custom_dir`;
      # Change permissions on the working directory.
      $rc=`chmod -R u+w $distr_dir/$custom_dir`;
      print "  -- Create isolinux.cfg \n";
      open(FILE, '>', "$distr_dir/$custom_dir/isolinux/isolinux.cfg");
      print FILE $iso_linux;
      close FILE;
      print " --- Umount source ISO\n";
      $rc=`umount $distr_dir/$src_dir`;
    } else {
      print "!Old directories were not removed and not copied!\n";
    };
  };
  print "---- Preparing dirs complet.\n";
  genNewKs();
  return;
}


sub prepareSoft {
  #
  # Installation necessary for preparation and creation of an ISO image
  #
  print "---- Preparing and installing necessary soft \n";
  $rc=`yum list installed|grep yum-utils.noarch|wc -l`;
  if ($rc == "0") {
    print " --- Installing yum-utils \n";
    $rc=`yum -y install yum-utils.noarch`;
  } else {
    print "  -- Yum-util already installed. \n"
  };
  $rc=`yum list installed|grep genisoimage|wc -l`;
  if ($rc == "0") {
    print " --- Installing ISO tools \n";
    $rc=`yum -y install genisoimage`;
  } else {
    print "  -- ISO tools already installed. \n";
  };
  $rc=`yum list installed|grep "man\."|wc -l`;
  if ($rc == "0") {
    print " --- Installing man \n";
    $rc=`yum -y install man`;
  } else {
    print "  -- Man already installed. \n";
  };
  $rc=`yum list installed|grep createrepo.noarch|wc -l`;
  if ($rc == "0") {
    print " --- Installing repo tools \n";
    $rc=`yum -y install createrepo.noarch`;
  } else {
    print "  -- Createrepo already installed \n";
  };
  $rc=`yum list installed|grep epel-release.noarch|wc -l`;
  if ($rc == "0") {
    print " --- Installing epel repo \n";
    $rc=`yum -y install epel-release.noarch`;
  } else {
    print "  -- Epel repo already installed \n";
  };
  $rc=`yum list installed|grep syslinux|wc -l`;
  if ($rc < "2") {
    print " --- Installing syslinux \n";
    $rc=`yum -y install syslinux`;
  } else {
    print "  -- Syslinux already installed \n";
  };
  $rc=`yum list installed|grep wget|wc -l`;
  if ($rc == "0") {
    print " --- Installing wget \n";
    $rc=`yum -y install wget`;
  } else {
    print "  -- Wget already installed \n";
  };
  print "---- Necessary soft installed\n";
  return;
}
sub genNewKs {
  print "---- Preapaing files \n";
  print " --- Creating kickstart files \n";
  print "  -- Create kickstart part 1 \n";
  open(FILE, '>', "$own_dir/$ks_dir/ks-1.part");
  print FILE decode_base64($ks1);
  close FILE;

  print "  -- Create kickstart part 2 \n";
  open(FILE, '>', "$own_dir/$ks_dir/ks-2.part");
  print FILE decode_base64($ks2);
  close FILE;

  print "  -- Create kickstart part 3 \n";
  open(FILE, '>', "$own_dir/$ks_dir/ks-3.part");
  print FILE decode_base64($ks3);
  close FILE;
  print " --- Creating kickstart files complete\n";
  print " --- Create packages list \n"; 
  print "  -- Create base packages list \n";
  open(FILE, '>', "$own_dir/$ks_dir/base-packages.lst");
  print FILE decode_base64($base_packages);
  close FILE;

  print " --- Creating files complet\n";
  print "---- Preparing files complete \n";
  return;
};

sub dlPacks {
    print "---- Updating packages \n";
    $rc=`cat $own_dir/$ks_dir/base-packages.lst | sed -n '/\%packages/,/\%end/p'|grep -v "%"`;
    @fileArr1=split(/\n/,$rc);
    for ($i=0;$i<=$#fileArr1;$i++) {
      print " --- [".$i."/".$#fileArr1."] Updating $fileArr1[$i] \n";
      $cmd="rm -f $distr_dir/$custom_dir/Packages/$fileArr1[$i]\-\[0\-9\]*";
      print `$cmd`;
      $rc=`yumdownloader --resolve --destdir=$distr_dir/$custom_dir/Packages $fileArr1[$i] >>$log_file`;
    };
    $rc=`rm -f $distr_dir/$custom_dir/Packages/centos-release-[6-9]-[6-9]*`;
    $rc=`yumdownloader --resolve --destdir=$distr_dir/$custom_dir/Packages centos-release`;
    $rc=`rm -f $distr_dir/$custom_dir/Packages/teamviewer.i686.rpm`;
    $rc=`wget --directory-prefix=$distr_dir/$custom_dir/Packages/ http://download.teamviewer.com/download/teamviewer.i686.rpm >/dev/null`;
    print "---- Updating packages complet \n";
};

sub preparePacks {
  if ($_[0] =~ /true/) {;
    dlPacks();
  };
  print " --- Update package-list \n";
  $rc=`rm -f $distr_dir/$custom_dir/repodata/*.gz $distr_dir/$custom_dir/repodata/*.*.bz2 $distr_dir/$custom_dir/repodata/*.repomd.xml`;
  $ofile=`ls $distr_dir/$custom_dir/repodata/\*-\*.xml`;
  chomp($ofile);
  $xml_file=`ls $distr_dir/$custom_dir/repodata/\*-\*.xml|awk \'{nb = split(\$0,a,\"-\"); for (i=2;i<=nb;i++) {str=str\"\"a[i]; if (i!=nb) {str=str\"-\"}} print str}\'`;
  $rc=`mv -f $ofile $distr_dir/$custom_dir/repodata/$xml_file`;
  $disk_info=`head -1 $distr_dir/$custom_dir/.discinfo`;
  $rc=`declare -x discinfo=$disk_info`;
  chomp($xml_file);
  $rc=`createrepo -u media://$discinfo -g $distr_dir/$custom_dir/repodata/$xml_file $distr_dir/$custom_dir/.`;
  print "---- Update package-list complete \n";
  return;
}

sub prepareIso {
  #
  # Creation of an ISO image
  #
  print "---- Creating ISO\n";
  print " --- Generate ks-dvd.cfg\n";
#  $rc=`cat $own_dir/$ks_dir/ks-1.part >$distr_dir/$custom_dir/isolinux/ks-dvd.cfg`;
#  $rc=`echo >> $distr_dir/$custom_dir/isolinux/ks-dvd.cfg`;
#  $rc=`cat $own_dir/$ks_dir/base-packages.lst >>$distr_dir/$custom_dir/isolinux/ks-dvd.cfg`;
#  $rc=`echo >> $distr_dir/$custom_dir/isolinux/ks-dvd.cfg`;
#  $rel_dir="$distr_dir/$custom_dir/Packages";
#  $rc=`ls $rel_dir/centos-release-[6-9]-[6-9]*`;
#  chomp($rc);
#  $rc=~ s/$rel_dir/\\\/var\\\/distr\\\/Packages\\/;
#  $rel_file=$rc;
#  $rc=`cat $own_dir/$ks_dir/ks-2.part |sed 's/\%cent_rel\%/$rel_file/' >>$distr_dir/$custom_dir/isolinux/ks-dvd.cfg`;
#  $rc=`echo >> $distr_dir/$custom_dir/isolinux/ks-dvd.cfg`;
#  $rc=`cat $own_dir/$ks_dir/base-packages.lst|grep -v \"%\"|awk \'{print \"chroot /home/\$username/chroot yum --disablerepo=\\\\\* --enablerepo=c6-media install -y \"\$0}\' >>$distr_dir/$custom_dir/isolinux/ks-dvd.cfg`;
#  $rc=`echo >> $distr_dir/$custom_dir/isolinux/ks-dvd.cfg`;
#  $rc=`cat $own_dir/$ks_dir/ks-3.part >>$distr_dir/$custom_dir/isolinux/ks-dvd.cfg`;
  print " --- Generate ks-flash.cfg\n";
#  $rc=`cat $distr_dir/$custom_dir/isolinux/ks-dvd.cfg | sed 's/#harddrive/harddrive/;s/cdrom/#cdrom/;s/#ignoredisk/ignoredisk/;s/#mkdir -p/mkdir -p/;s/#mount/mount/' >$distr_dir/$custom_dir/isolinux/ks-flash.cfg`;
  ###
  $rc=`mkisofs -o $distr_dir/iso/customCentOS67.iso -b isolinux/isolinux.bin -c isolinux/boot.cat -no-emul-boot -boot-load-size 4 -boot-info-table -R -J -v -T $distr_dir/$custom_dir`;
  $rc=`isohybrid $distr_dir/iso/customCentOS67.iso`;
  print "---- Creating ISO complet\n";
  return;
}

sub printHelp {
  print "Usage script with options: \n";
  print " --make-dirs		- Create necessary dirs, mount source iso and copy files to own distr. Require --source-iso \n";
  print " --source-iso=<iso> 	- Path to file and name original ISO-image (It is necessary to download in advance)\n";
  print "\n";
  print " --check-soft		- Check and install necessary soft \n";
  print " --dl-packs		- Download and update necessary packages for install from own ISO-image (Need internet)\n";
  print " --upd-list-packs	- Update list of new packages for install from own ISO-image \n";
  print " --make-iso     	- Create ISO-image \n";
  print " --make-all             - include --make-dirs, --check-soft, --dl-packs and --upd-list-packs \n";
  print "\n";
  print "Examples: \n";
  print "  Create all dirs and copy original iso for create custom iso: \n";
  print "  	CreateCustomLinux.sh --make-dirs --source-iso=/root/Centos.iso \n";
  print "  Create all dirs, copy original, download fresh packages, update package-list: \n";
  print "  	CreateCustomLinux.sh --make-all --source-iso=/root/Centos.iso \n";
  print "  Create iso: \n";
  print "  	CreateCustomLinux.sh --make-iso \n";
  print "\n";
  exit;
};


if ($#ARGV == -1) {
    printHelp();
} else {
    for ($i=0;$i<=$#ARGV;$i++) {
	if ($ARGV[$i] =~ /--make-iso/) {
	    print "!!!! UNDER CONSTRUCTION !!!\n";
	    prepareIso();
	};
	if ($ARGV[$i] =~ /--upd-list-packs/) {
	    preparePacks();
	};
	if ($ARGV[$i] =~ /--check-soft/) {
	    prepareSoft();
	};
        if ($ARGV[$i] =~ /--dl-packs/) {
            dlPacks();
        };
	if ($ARGV[$i] =~ /--make-dirs/) {
	    if (!$ARGV[$i+1]) {
		prepareDirs();
	    } else {
		my @args = split(/=/,$ARGV[$i+1]);
		prepareDirs($args[1]);
	    };
	};
        if ($ARGV[$i] =~ /--make-all/) {
            if (!$ARGV[$i+1]) {
                prepareDirs();
                prepareSoft();
                preparePacks("true");
                
            } else {
		my @args = split(/=/,$ARGV[$i+1]);
                prepareDirs($args[1]);
                prepareSoft();
                preparePacks("true");
            };
        };
    };
};

