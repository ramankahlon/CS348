echo exit | sqlplus kahlonr@csora/basketball3298 @sql_scripts/drop.sql >/dev/null
echo exit | sqlplus kahlonr@csora/basketball3298 @sql_scripts/create.sql >/dev/null
echo exit | sqlplus kahlonr@csora/basketball3298 @sql_scripts/init.sql >/dev/null

javac -cp .:ojdbc8.jar Project3.java
java -cp .:ojdbc8.jar Project3 input.txt output.txt
