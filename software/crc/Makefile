progs = crc

all: $(addsuffix .bin, $(progs))

%.bin: %.asm
	nasm -f bin $< -o $@ -l $(basename $@).lst
	crcany -16arc $@ > $(basename $@).crc
	printf $$(crcany -16arc $@ | cut -dx -f2 | sed 's/../\\x&/g') >> $@
	

clean:
	rm -f *.bin *.lst *.crc

%.upload: %.bin
	minipro -p AT28C64B -uP -w $<

# Phony target to handle the upload command
upload: $(addsuffix .upload, $(filter-out upload, $(basename $(MAKECMDGOALS))))

# Prevent make from interpreting the goals as file names
%:
    @:

.PHONY: clean upload