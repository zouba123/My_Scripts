###############
hadoop fs -cat /user/cloudera/import/basename/part-m-*|WC -l
###############
sqoop list-databases \
--connect "jdbc:mysql://zied:3306" \
--username zied \
--password zied
###############
sqoop list-tables \
--connect "jdbc:mysql://zied:3306/basename" \
--username zied \
--password zied
###############
sqoop import-all-tables \
-m 4 \
--connect "jdbc:mysql://zied:3306/basename" \
--username=retail_dba \
--password=cloudera \
--warehouse-dir=/user/cloudera/sqoop_import
############### avro format
sqoop import-all-tables \
-m 12 \
--connect "jdbc:mysql://zied:3306/retail_db" \
--username=retail_dba \
--password=cloudera \
--as-avrodatafile \
--warehouse-dir=/user/cloudera/sqoop_import
###############
hadoop eval --connect "jdbc:mysql://zied:3306/retail_db" \
--username=retail_dba \
--password=cloudera \
--query "select count(1) from departements"
###############
###############Make sure hive is up and running using 
hive -e "create table testing (t int); insert into testing values (1); select count(1) from testing;"

sqoop import-all-tables \
--num-mappers 1 \
--connect "jdbc:mysql://quickstart.cloudera:3306/retail_db" \
--username=retail_dba \
--password=cloudera \
--hive-import \
--hive-overwrite \
--create-hive-table \
--compress \
--compression-codec org.apache.hadoop.io.compress.SnappyCodec \
--outdir java_files

##############################
show tables;
describe formatted departement;
dfs -ls /user/hive/warehouse/departement;
dfs -du -s -h /user/hive/warehouse/departement;
##############################
