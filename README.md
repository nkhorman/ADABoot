ADABoot  
---------
 
This is a fork of a version of the ATMegaBOOT_168.c bootloader with AdaFruit modifications.
 
It is what was used on the [VT-X101](https://www.violetronix.com/vt-x101) board.

It can be compiled for the following CPU variations;
* ATMega128
* ATMega163
* ATMega168
* ATMega328P
* ATMega328PB
* ATMega344P
* ATMega644P
* ATMega644
* AT90USB1286
* AT90USB1287

I added the AT90USB128x and ATMega328PB CPU support.

You may need to massage the Makefile to get the build configuration and frequency that you're looking for.
I added several targets to support my needs. I only using the Make for building.

The compiler that I use for building this is avr-gcc 4.5.2.
Using newer versions does/may result in a bootloader that won't fit into the 0x7800 - 0x7FFF space.
