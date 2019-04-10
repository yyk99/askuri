all:
	perl -cw parser.pl
	php -l edit-plans.php
	php -l plans.php
dump-base:
	mysqldump --add-drop-table rcm | gzip > rcm.sql.gz
restore-base:
	gunzip -c rcm.sql.gz | mysql rcm
