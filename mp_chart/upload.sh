sudo /usr/local/sbin/privoxy /usr/local/etc/privoxy/config
export http_proxy='http://localhost:8118'
export https_proxy='http://localhost:8118'
pub publish --server=https://pub.dartlang.orgy
unset http_proxy
unset https_proxy
sudo service privoxy stop