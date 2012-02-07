taskpaper.tar.gz:
	tar zcvf taskpaper.tar.gz after/ doc/ ftplugin/ ftdetect/ syntax/

deploy:
	rsync --exclude '*.sw?' -av after doc ftdetect ftplugin syntax $(HOME)/.vim
