# help to debug nginx errors
# this is not a script is just commands to use that's why don't have shebang

echo | sudo tee /var/log/nginx/error.log
echo | sudo tee /var/log/php-fpm/error.log

sudo systemctl restart php-fpm && sudo systemctl restart nginx

curl localhost --header 'Host: example.com'

sudo cat /var/log/nginx/error.log
sudo cat /var/log/php-fpm/error.log
