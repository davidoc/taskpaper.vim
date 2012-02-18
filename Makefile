taskpaper.tar.gz:
	tar zcvf taskpaper.tar.gz autoload/ doc/ ftplugin/ ftdetect/ syntax/

deploy:
	rsync --exclude '*.sw?' -av autoload doc ftdetect ftplugin syntax $(HOME)/.vim
