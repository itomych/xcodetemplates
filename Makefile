playground_dir = $(HOME)/Library/Developer/Xcode/Templates/File\ Templates/Playground
project_dir = $(HOME)/Library/Developer/Xcode/Templates/Project\ Templates/itomych
frameworks_dir = $(HOME)/Library/Developer/Xcode/Templates/Project\ Templates/itomych\ Frameworks
empty_file_dir = $(HOME)/Library/Developer/Xcode/Templates/File\ Templates/Empty\ Files
prefilled_file_dir = $(HOME)/Library/Developer/Xcode/Templates/File\ Templates/Prefilled\ Files

install: $(playground_dir) $(project_dir) $(frameworks_dir) $(empty_file_dir) $(prefilled_file_dir)
	cp -R ./Playground\ Templates/*.xctemplate $(playground_dir)
	cp -R ./Project\ Templates/*.xctemplate $(project_dir)
	cp -R ./Framework\ Templates/*.xctemplate $(frameworks_dir)
	cp -R ./Empty\ File\ Templates/*.xctemplate $(empty_file_dir)
	cp -R ./Prefilled\ File\ Templates/*.xctemplate $(prefilled_file_dir)

$(playground_dir):
	mkdir -p $(playground_dir)

$(project_dir):
	mkdir -p $(project_dir)

$(frameworks_dir):
	mkdir -p $(frameworks_dir)

$(empty_file_dir):
	mkdir -p $(empty_file_dir)

$(prefilled_file_dir):
	mkdir -p $(prefilled_file_dir)

.PHONY = install
