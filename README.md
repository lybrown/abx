abx
===

Atari Beaglebone Expansion

Programming Interface
---------------------

* Write $LL to $D7HH to request page $HHLL.
* Wait for ~700 CPU cycles for page to be loaded.
* Make sure 6502 program counter and ANTIC stay out of page range during loading.
* Page will appear to be filled with $FF during load.
* Upon load completion, 24K page will visible from $4000 through $9fff.

Schematic
---------

* https://www.circuitlab.com/circuit/d79fxj/abx/

Part List
---------

* [Beaglebone](http://www.amazon.com/gp/product/B007KW80M6/ref=oh_details_o03_s00_i00)
* [Jumper Wire](http://www.amazon.com/gp/product/B0040DEI9M/ref=oh_details_o00_s00_i00)
* [Jumper Wire](http://www.amazon.com/gp/product/B0002H7AIG/ref=oh_details_o00_s00_i01)
* [Jumper Wire](https://www.adafruit.com/products/759)
* [Five 8-bit level shifters](https://www.adafruit.com/products/735)

Photos
------

![ABX](https://github.com/lybrown/abx/raw/master/photos/abx1-small.jpg "ABX attached to stock Atari 600XL")
![ABX](https://github.com/lybrown/abx/raw/master/photos/abx2-small.jpg "ABX attached to stock Atari 600XL")

Demo
----

* http://www.youtube.com/watch?v=1irR4TQ5aMA

Caveats
-------

I've only tested on a stock NTSC Atari 600XL. ABX *does* assert
EXTSEL on reads from the page range, but I haven't verified that main
memory is properly disabled during these reads. If not, there would
be bus contention on a system with more than 16K RAM. Importantly,
ABX does not yet keep track of the state of PORTB or heed EXTENB,
so it *does* cause bus contention when the self-test ROM is enabled.
