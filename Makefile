.PHONY: all

all:
	make -C byterun
	make -C runtime

clean:
	make clean -C byterun
	make clean -C runtime