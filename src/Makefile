SHOBJ_LDFLAGS = -dynamiclib -current_version 1.0

.c.o:
	$(CC) $(CFLAGS) -c -o $@ $<

../libexec/rbenv-realpath.dylib: realpath.o
	$(CC) $(CFLAGS) $(SHOBJ_LDFLAGS) -o $@ realpath.o

clean:
	rm -f *.o ../libexec/*.dylib
