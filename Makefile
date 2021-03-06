APXS=apxs2
APACHECTL=sudo /etc/init.d/apache2
CFLAGS=-Wc,-g -Wc,-Wall
LIBS=-ltcpcrypt

install:
	$(APXS) $(CFLAGS) $(INCLUDES) $(LIBS) -cia mod_tcpcrypt.c

#   cleanup
clean:
	-rm -f mod_tcpcrypt.o mod_tcpcrypt.lo mod_tcpcrypt.slo mod_tcpcrypt.la 

#   simple test
configtest:
	-cp test/test-tcpcrypt-site /etc/apache2/sites-available/
	-sudo a2ensite test-tcpcrypt-site

test: configtest reload req

req:
	curl http://localhost:7777/tcpcrypt.sh

#   install and activate shared object by reloading Apache to
#   force a reload of the shared object file
reload: install restart

#   the general Apache start/restart/stop
#   procedures
start:
	$(APACHECTL) start
restart:
	$(APACHECTL) restart
stop:
	$(APACHECTL) stop

iptables-on:
	iptables -I INPUT  -p tcp -m tcp --dport 80 -j NFQUEUE --queue-num 666
	iptables -I OUTPUT -p tcp -m tcp --sport 80 -j NFQUEUE --queue-num 666

iptables-off:
	iptables -D INPUT  -p tcp -m tcp --dport 80 -j NFQUEUE --queue-num 666
	iptables -D OUTPUT -p tcp -m tcp --sport 80 -j NFQUEUE --queue-num 666
