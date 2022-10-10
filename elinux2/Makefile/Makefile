OBJS=mult.o main.o

all: sample

%.o: %.c
	gcc -c $<

main.o: mult.o

sample: $(OBJS)
	gcc -o $@ $^

clean:
	rm -rf $(OBJS) sample
