#!/bin/bash

#
# Set environment
#

function simu_killall()
{
  sleep 1 ; killall -SIGINT rviz2
  sleep 1 ; killall -SIGINT sick_generic_caller
  sleep 1 ; killall -SIGINT sick_scan_emulator
  sleep 1 ; killall -9 rviz2
  sleep 1 ; killall -9 sick_generic_caller
  sleep 1 ; killall -9 sick_scan_emulator 
  sleep 1
}

simu_killall
printf "\033c"
pushd ../../../..
source ./install/setup.bash

#
# Run simulation:
# 1. Start sick_scan_emulator
# 2. Start sick_scan driver sick_generic_caller
# 3. Run rviz
#

echo -e "run_linux_ros2_simu_rms.bash: starting rms emulation\n"
cp -f ./src/sick_scan_xd/test/emulator/scandata/20211201_RMS_3xx_start_up.pcapng.json /tmp/lmd_scandata.pcapng.json
sleep  1 ; ros2 run sick_scan sick_scan_emulator ./src/sick_scan_xd/test/emulator/launch/emulator_rms3xx.launch &
# sleep  1 ; ros2 run sick_scan sick_generic_caller ./src/sick_scan_xd/launch/sick_rms_3xx.launch hostname:=127.0.0.1 port:=2111  & 
# sleep  1 ; ros2 run sick_scan sick_generic_caller ./src/sick_scan_xd/launch/sick_rms_3xx.launch hostname:=127.0.0.1 port:=2111 sw_pll_only_publish:=False &
sleep  1 ; ros2 launch sick_scan sick_rms_3xx.launch.py hostname:=127.0.0.1 port:=2111 sw_pll_only_publish:=False &
sleep  1 ; ros2 run rviz2 rviz2 -d ./src/sick_scan_xd/test/emulator/config/rviz_emulator_cfg_ros2_rms.rviz &

# Wait for 'q' or 'Q' to exit or until rviz is closed ...
while true ; do  
  echo -e "rms emulation running. Close rviz or press 'q' to exit..." ; read -t 1.0 -n1 -s key
  if [[ $key = "q" ]] || [[ $key = "Q" ]]; then break ; fi
  rviz_running=`(ps -elf | grep rviz2 | grep -v grep | wc -l)`
  if [ $rviz_running -lt 1 ] ; then break ; fi
done

# ... or stop simulation after 30 seconds
# sleep 30

simu_killall  
popd

