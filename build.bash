aarch64-linux-gnu-gcc -Wa,-mcpu=cortex-a57 -ggdb3 -static $1.S -o $1

qemu-aarch64 -g 1234 ./$1
