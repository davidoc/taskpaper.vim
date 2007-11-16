taskpaper.tar.gz:
	tar zcvf taskpaper.tar.gz doc/ ftplugin/ ftdetect/ syntax/

deploy:
	rsync -av doc ftdetect ftplugin syntax $(HOME)/.vim
