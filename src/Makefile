SHOBJ_LDFLAGS = -dynamiclib

.c.o:
	$(CC) $(CFLAGS) -c -o $@ $<

../libexec/rbenv-realpath.dylib: realpath.o
	$(CC) $(CFLAGS) $(SHOBJ_LDFLAGS) -o $@ realpath.o

clean:
	rm -f *.o ../libexec/*.dylib
