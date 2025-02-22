CC=gcc
CFLAGS=-Wall -Wextra -pedantic -lpq

query: query.c
	$(CC) query.c -o query -I/usr/include/postgresql $(CFLAGS)

clean:
	rm query
