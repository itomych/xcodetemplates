file_dir = $(HOME)/Library/Developer/Xcode/Templates/File\ Templates/Playground
project_dir = $(HOME)/Library/Developer/Xcode/Templates/Project\ Templates/itomych

install: $(file_dir) $(project_dir)
	cp -R ./File\ Templates/*.xctemplate $(file_dir)
	cp -R ./Project\ Templates/*.xctemplate $(project_dir)

$(file_dir):
	mkdir -p $(file_dir)

$(project_dir):
	mkdir -p $(project_dir)

.PHONY = install
