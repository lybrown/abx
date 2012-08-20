#CROSS_COMPILE?=arm-arago-linux-gnueabi-

#LIBDIR_APP_LOADER?=../../app_loader/lib
#INCDIR_APP_LOADER?=../../app_loader/include
#BINDIR?=../bin
#CFLAGS += -Wall -I$(INCDIR_APP_LOADER) -D__DEBUG -O2 -mtune=cortex-a8 -march=armv7-a
#LDFLAGS += -L$(LIBDIR_APP_LOADER) -lprussdrv -lpthread
#OBJDIR := .
#TARGET := $(BINDIR)/abx

CROSS_COMPILE := arm-linux-gnueabi-
LIBDIR_APP_LOADER := .
INCDIR_APP_LOADER := .
BINDIR := .

CFLAGS += -Wall -I$(INCDIR_APP_LOADER) -D__DEBUG -O2 -mtune=cortex-a8 -march=armv7-a -std=gnu99
LDFLAGS += -L$(LIBDIR_APP_LOADER) -lpthread
OBJDIR := .
TARGET := $(BINDIR)/abx

_DEPS = 
DEPS = $(patsubst %,$(INCDIR_APP_LOADER)/%,$(_DEPS))

_OBJ = abx.o prussdrv.o
OBJ = $(patsubst %,$(OBJDIR)/%,$(_OBJ))


$(OBJDIR)/%.o: %.c $(DEPS)
	$(CROSS_COMPILE)gcc $(CFLAGS) -c -o $@ $< 

%.bin: %.p
	pasm -b $<

%_bin.h: %.p
	pasm -C$* $<
	perl -pi -e 's/const *//' $@

all: $(TARGET)

copy_disable_abx:
	scp disable_abx root@bone:/usr/bin
test: all
	scp $(TARGET) bone:/dev/shm
	ssh root@bone "trap disable_abx SIGHUP EXIT; cd /dev/shm; time ./abx"

abx_pru0_bin.h abx_pru1_bin.h: pru.hp

abx_jumptable.h: abx_jumptable.pl
	./$< > $@~ && mv $@~ $@

ribbon.h:
	bin2h ribbon.obx | perl -pe 's/data/ribbon/' > ribbon.h

abx.o: abx_pru0_bin.h abx_pru1_bin.h abx_jumptable.h ribbon.h

$(TARGET): $(OBJ)
	$(CROSS_COMPILE)gcc $(CFLAGS) -o $@ $^ $(LDFLAGS)

.PHONY: clean

clean:
	rm -rf *~ $(TARGET) *.bin *_bin.h *.o
