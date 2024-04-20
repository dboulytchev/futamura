.PHONY: all

all:
	make -C byterun
	make -C runtime
	make -C tests

clean:
	make clean -C byterun
	make clean -C runtime
	make clean -C tests