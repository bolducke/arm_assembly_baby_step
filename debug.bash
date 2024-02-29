gdb-multiarch -q --nh \
  -ex 'set architecture aarch64' \
  -ex 'file main' \
  -ex 'target remote localhost:1234' \
  -ex 'break main' \
  -ex continue \
  -ex 'layout split' \
  -ex 'layout regs'
