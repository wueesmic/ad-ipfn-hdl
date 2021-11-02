#Run on console
#source /mnt/sda5/Xilinx/SDK/2019.1/.settings64-SDK_Core_Tools.sh
#xsct  run_xsct.tcl
#
connect
fpga -f ./system_top.bit
#fpga -f ../output/system_top.bit
after 1000
# Linux buildroot 4.9.0 #4 Fri Jun 21 12:29:50 WEST 2019 microblaze GNU/Linux
# mount  -o port=2049,nolock,proto=tcp 10.136.241.211:/opt/share /mnt/nfs
#
#4* MicroBlaze #0 (Running)
target 4
dow ./simpleImage.kc705_fmcjesdadc1
after 1000
con
disconnect 
# ssh-keygen -f "/home/bernardo/.ssh/known_hosts" -R 10.136.242.198
# ssh root@10.136.242.198
# mount /mnt/nfs
