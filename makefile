CC = gcc
maindir = src/
pipesdir = src/pipes/
main = concurrent_pipe gettime debug_pipe hashtable linkedlist data pipe parameters register_pipes pipebuilder piperegistry pipeline
pipes = pipe_power pipe_dummy_computation pipe_writesharedmem pipe_inversefouriertransform pipe_dummyemotiv pipe_filter pipe_fouriertransform pipe_print pipe_emotiv pipe_writefile pipe_readfile pipe_rpi
ext = emokit edflib fidlib
mainf = $(addprefix $(maindir), $(main))
pipesf = $(addprefix $(pipesdir), $(pipes))
extf = $(addprefix $(maindir), $(ext))
lflags = -lhidapi-libusb -lmcrypt -lfftw3 -lm -lpthread
cflags = -Wall -std=gnu99 -DT_LINUX -D_LARGEFILE64_SOURCE -D_LARGEFILE_SOURCE 

all : compile 
	
compile : $(addsuffix .c, $(mainf) $(pipesf) $(extf))
	$(CC) -fPIC $(cflags) -c $(addsuffix .c, $(extf) $(pipesf) $(mainf)) 
	$(CC) -shared $(lflags) -Wl,-soname,libneuropipes.so.1 -o libneuropipes.so.1.0 $(addsuffix .o, $(ext) $(pipes) $(main)) 
	rm *.o

install :
	ln -sf libneuropipes.so.1.0 libneuropipes.so.1
	ln -sf libneuropipes.so.1.0 libneuropipes.so
	mv libneuropipes.so* /usr/lib
	cp src/neuropipes.h /usr/include

uninstall :
	rm /usr/lib/libneuropipes.so*
	rm /usr/include/neuropipes.h

clean : 
	rm -f driver cli tests/test libneuropipes.so* *.o

cli : cli.c
	$(CC) cli.c -o cli -lneuropipes

driver : driver.c
	$(CC) driver.c -o driver -lneuropipes

test :	tests/test.c $(addsuffix .c, $(extf) $(pipesf) $(mainf))
	$(CC) -o tests/test tests/test.c $(addsuffix .c, $(extf) $(pipesf) $(mainf)) $(lflags) -lcmocka $(cflags)
