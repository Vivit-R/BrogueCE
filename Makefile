include config.mk

cflags := -Isrc/brogue -Isrc/platform -std=c99 \
	-Wall -Wpedantic -Werror=implicit -Wno-parentheses -Wno-format-overflow
libs := -lm
cppflags := -DDATADIR=.

sources := $(wildcard src/brogue/*.c) $(wildcard src/platform/*.c)
objects := $(sources:.c=.o)

ifeq ($(TERMINAL),YES)
	cppflags += -DBROGUE_CURSES
	libs += -lncurses
endif

ifeq ($(GRAPHICS),YES)
	cflags += $(shell $(SDL_CONFIG) --cflags)
	cppflags += -DBROGUE_SDL
	libs += $(shell $(SDL_CONFIG) --libs) -lSDL2_image
endif

ifeq ($(MAC_APP),YES)
	cppflags += -DSDL_PATHS
endif

ifeq ($(DEBUG),YES)
	cflags += -g
	cppflags += -DDEBUGGING=1
else
	cflags += -O2
endif

.PHONY: clean

%.o: %.c src/brogue/Rogue.h src/brogue/IncludeGlobals.h
	$(CC) $(cppflags) $(CPPFLAGS) $(cflags) $(CFLAGS) -c $< -o $@

bin/brogue: $(objects)
	$(CC) $(cflags) $(CFLAGS) -Wl,-rpath,lib $(LDFLAGS) -o $@ $^ $(libs) $(LDLIBS)

icon.o: icon.rc
	windres $< $@

bin/brogue.exe: $(objects) icon.o
	$(CC) $(cflags) $(CFLAGS) $(LDFLAGS) -o $@ $^ $(libs) $(LDLIBS)

clean:
	$(RM) $(objects) bin/brogue{,.exe}


# $* is the matched %
icon_%.png: bin/assets/icon.png
	convert $< -resize $* $@

# Dependencies after | are not considered when deciding to update target
macos/Brogue.icns: | icon_32.png icon_128.png icon_256.png icon_512.png
	png2icns $@ $^
	$(RM) $^
