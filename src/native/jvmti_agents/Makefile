include ../../common.mk

all: libperf_statistics.so

libperf_statistics.so: perf_statistics.o common.o
	gcc $(CFLAGS) -fPIC -shared -o libperf_statistics.so perf_statistics.o common.o -lpfm

perf_statistics.o: perf_statistics.c
	gcc $(CFLAGS) -fPIC -c perf_statistics.c -I$(JDK)/include -I$(JDK)/include/linux/

common.o: common.c
	gcc $(CFLAGS) -fPIC -c common.c -I$(JDK)/include -I$(JDK)/include/linux/

clean:
	rm -rf *.o *.so

test: default

