ssh mileena "rm -rf ~/hxredis/*"
scp -r ./src mileena:~/hxredis
scp ./build.hxml mileena:~/hxredis
ssh mileena "cd ~/hxredis && haxe build.hxml"
scp mileena:~/hxredis/build/Test ./
scp Test hitcollector-01:~/