sudo /usr/local/sbin/privoxy /usr/local/etc/privoxy/config
export http_proxy='http://localhost:8119'
export https_proxy='http://localhost:8119'
pub publish --server=https://pub.dartlang.org
unset http_proxy
unset https_proxy
sudo service privoxy stop