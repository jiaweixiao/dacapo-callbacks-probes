.PHONY: all clean test

JAVA11_HOME=/home/xiaojiawei/jdks/mmtk-lxr/openjdk/build/linux-x86_64-normal-server-release/images/jdk
JAVAC=$(JAVA11_HOME)/bin/javac
JAR=$(JAVA11_HOME)/bin/jar
CC=gcc
CFLAGS=-O2 -g -Wall -Werror -D_GNU_SOURCE -fPIC
BENCHMARKS=..
DACAPOCHOPINJAR=$(BENCHMARKS)/dacapo-23.11-chopin/dacapo-23.11-chopin.jar
UNAME_M=$(shell uname -m)

all: out/probes.jar out/librust_mmtk_probe.so $(if $(findstring $(UNAME_M),x86_64),out/librust_mmtk_probe_32.so)

out/probes.jar: out/java11/probe/RustMMTkProbe.class out/java11/probe/MMTkProbe.class out/java11/probe/HelloWorldProbe.class out/java11/probe/DacapoChopinCallback.class
	$(JAR) -cf out/probes.jar -C out/java11/ .

out/java11/probe/RustMMTkProbe.class: src/probe/RustMMTkProbe.java
	mkdir -p out/java11 && $(JAVAC) -cp src -d out/java11 $<

out/java11/probe/HelloWorldProbe.class: src/probe/HelloWorldProbe.java
	mkdir -p out/java11 && $(JAVAC) -cp src -d out/java11 $<

out/java11/probe/MMTkProbe.class: src/probe/MMTkProbe.java
	mkdir -p out/java11 && $(JAVAC) -cp src -d out/java11 $<

out/java11/probe/DacapoChopinCallback.class: src/probe/DacapoChopinCallback.java
	mkdir -p out/java11 && $(JAVAC) -cp src:$(DACAPOCHOPINJAR) -d out/java11 $<

out/librust_mmtk_probe.so: out/native/rust_mmtk_probe.o
	$(CC) $(CFLAGS) -pthread -shared -o $@ $< -lc

out/native/rust_mmtk_probe.o: src/native/rust_mmtk_probe.c
	mkdir -p out/native && $(CC) $(CFLAGS) -pthread -c $< -o $@ -I$(JAVA11_HOME)/include -I$(JAVA11_HOME)/include/linux/

out/librust_mmtk_probe_32.so: out/native/rust_mmtk_probe_32.o
	$(CC) $(CFLAGS) -m32 -pthread -shared -o $@ $< -lc

out/native/rust_mmtk_probe_32.o: src/native/rust_mmtk_probe.c
	mkdir -p out/native && $(CC) $(CFLAGS) -m32 -pthread -c $< -o $@ -I$(JAVA11_HOME)/include -I$(JAVA11_HOME)/include/linux/

test:
	$(JAVA11_HOME)/bin/java -Djava.library.path=./out -Dprobes=HelloWorld -cp $(DACAPOCHOPINJAR):./out/probes.jar Harness -c probe.DacapoChopinCallback fop
	$(JAVA11_HOME)/bin/java -XX:+UseThirdPartyHeap -XX:ThirdPartyHeapOptions=plan=SemiSpace -Djava.library.path=./out -Dprobes=RustMMTk -cp $(DACAPOCHOPINJAR):./out/probes.jar Harness -c probe.DacapoChopinCallback fop

clean:
	rm -rf out
