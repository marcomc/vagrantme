#!/bin/bash

bash /vagrant/vagrantme/setup_ca_and_certificate.sh $HOSTNAME.local
##########
# install the Apache server
echo "Installing Apache, PHP, mod_ssl, Varnish"
yum -y -q install http php varnish mod_ssl
# set the Apache server to start at login
echo "Activating Apache"
chkconfig --levels 235 httpd on
echo "Activating Varnish, VarnishLog"
chkconfig --levels 235 varnish on
chkconfig --levels 235 varnishlog on

echo "Installing mod_pagespeed repository"
#### install mod_pagespeed #####
NEW_REPO="/etc/yum.repos.d/mod-pagespeed.repo"
touch $NEW_REPO

cat <<'EOF' > $NEW_REPO
[mod-pagespeed]
name=mod-pagespeed
baseurl=http://dl.google.com/linux/mod-pagespeed/rpm/stable/x86_64
#baseurl=http://dl.google.com/linux/mod-pagespeed/rpm/stable/i386
enabled=1
gpgcheck=0
EOF
echo "Installing mod_pagespeed"
yum -y -q --enablerepo=mod-pagespeed install mod-pagespeed

echo "Enabling mod_pagespeed"
# Enables the 'collapse_whitespace' of Pagespeed
sed -i 's/.*ModPagespeedEnableFilters collapse_whitespace.*/    ModPagespeedEnableFilters collapse_whitespace,elide_attributes/' /etc/httpd/conf.d/pagespeed.conf

# start Apache now
/etc/init.d/httpd restart
/etc/init.d/varnish restart
/etc/init.d/varnishlog restart
# Varnish is listening on the local port 6081
# Vagrant is configured to forward that port to port localhost:8081
# it's possible to test the Varnish cash using curl and monitoring the /etc/log/varnish/varnish.log file
# curl http://localhost:8081 # run this from the host machine

echo "Testing mod_pagespeed"
# set up the PHP test page from which we will check that Apache is actualy loading the modules we require 
DOCUMENT_ROOT=`grep DocumentRoot /etc/httpd/conf/httpd.conf | sed "/^#/d" | cut -d'"' -f2`
PHP_INFO=$DOCUMENT_ROOT/phpinfo.php
touch $PHP_INFO
cat <<'EOF' > $PHP_INFO
<?php phpinfo (); ?>
EOF

# verifies that X-Mod-Pagespeed is properly installed
if curl -# http://localhost/phpinfo.php 2>/dev/null |grep Pagespeed 
then
    echo "X-Mod-Pagespeed installed and activated"
else
    echo "X-Mod-Pagespeed not installed or not activated"
fi
##########

# verifies that X-Mod-Pagespeed is properly working
MULTISPACE_TEST=$DOCUMENT_ROOT/multispace_test.html
touch $MULTISPACE_TEST
cat <<'EOF' > $MULTISPACE_TEST
<html>
        <head>                <title>Title</title> </head>
        <body>  <p>Paragraph with m  a  n  y       contiguous     spaces      !</p>        </body>
</html>
EOF
echo "Original content of $MULTISPACE_TEST:"
cat $MULTISPACE_TEST

echo "Requesting $MULTISPACE_TEST from the webserver"
if curl -# http://localhost/multispace_test.html 2> /dev/null |grep "  "
then
    echo "X-Mod-Pagespeed is NOT working, double white spaces have been found"
else
    curl -# http://localhost/multispace_test.html 2> /dev/null
    echo "X-Mod-Pagespeed is removing space properly"
fi
