.PHONY: all

all:
	make -C runtime
	make -C byterun
	make -C tests

clean:
	make clean -C runtime
	make clean -C byterun
	make clean -C tests
