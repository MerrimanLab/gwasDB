# create db

sqlite3 ~/data/gwasDB/gwasdb.sqlite < R/gwas_etl.sql

mkdir -p data
ln -s ~/data/gwasDB/gwasdb.sqlite data/gwasdb.sqlite

