
guile server.scm &
pid=$!
sleep 1

curl -i -X GET -d "page=0" http://localhost:8080/hello2
echo
curl -i -X GET -d "page=0" http://localhost:8080/hello
echo
curl -i -X POST -d "page=0" http://localhost:8080/hello2
echo

echo "Running httperf... (not really that useful running client and server on the same machine)"
httperf --hog --method GET  --server localhost --port 8080 --uri /hello --num-conn 10 --ra 10 --timeout 1
httperf --hog --method POST  --server localhost --port 8080 --uri /hello --num-conn 10 --ra 10 --timeout 1
httperf --hog --method GET  --server localhost --port 8080 --uri /non-existent --num-conn 10 --ra 10 --timeout 1
httperf --hog --method GET  --server localhost --port 8080 --uri /hello2 --num-conn 10 --ra 10 --timeout 1
echo

kill $pid
wait
