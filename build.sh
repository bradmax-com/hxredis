ssh mileena "rm -rf ~/hxredis/*"
scp -r ./src mileena:~/hxredis
scp ./build.hxml mileena:~/hxredis
ssh mileena "cd ~/hxredis && haxe build.hxml"
scp mileena:~/hxredis/build/Test-debug ./
scp Test-debug hitcollector-01:~/