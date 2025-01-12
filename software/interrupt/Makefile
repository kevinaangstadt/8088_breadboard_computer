progs = timer

all: $(addsuffix .bin, $(progs))

%.bin: %.asm
	nasm -f bin $< -o $@ -l $(basename $@).lst

clean:
	rm -f *.bin *.lst

%.upload: %.bin
	minipro -p AT28C64B -uP -w $<

# Phony target to handle the upload command
upload: $(addsuffix .upload, $(filter-out upload, $(basename $(MAKECMDGOALS))))

# Prevent make from interpreting the goals as file names
%:
    @:

.PHONY: clean upload