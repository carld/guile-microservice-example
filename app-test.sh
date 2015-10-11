
guile server.scm &
pid=$!
sleep 1

curl -i -X GET "http://localhost:8080/hello2"
echo
curl -i -X GET "http://localhost:8080/hello?page=0"
echo
curl -i -X GET "http://localhost:8080/hello?page=1"
echo
curl -i -X GET "http://localhost:8080/hello?page=2"
echo
curl -i -X GET "http://localhost:8080/hello?page=3"
echo
curl -i -X GET "http://localhost:8080/hello?page=4"
echo
curl -i -X POST -d "page=0" "http://localhost:8080/hello2"
echo
#read -r -p "Run httperf Y/N? " response
response=Y
if [[ $response =~ ^([yY][eE][sS]|[yY])$ ]]
then
  echo "Running httperf... (not really that useful running client and server on the same machine)"
  httperf --hog --method GET  --server localhost --port 8080 --uri /hello --num-conn 10 --ra 10 --timeout 1
  httperf --hog --method POST  --server localhost --port 8080 --uri /hello --num-conn 10 --ra 10 --timeout 1
  httperf --hog --method GET  --server localhost --port 8080 --uri /non-existent --num-conn 10 --ra 10 --timeout 1
  httperf --hog --method GET  --server localhost --port 8080 --uri /hello2 --num-conn 10 --ra 10 --timeout 1
  echo
fi
echo "stopping server, $pid"
kill -int $pid
