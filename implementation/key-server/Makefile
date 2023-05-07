ARCH_LIBDIR ?= /lib/$(shell $(CC) -dumpmachine)

ifeq ($(DEBUG),1)
GRAMINE_LOG_LEVEL = debug
CFLAGS += -O0 -ggdb3
else
GRAMINE_LOG_LEVEL = error
CFLAGS += -O2
endif

CFLAGS += -fPIE
LDFLAGS += -pie

RA_TYPE ?= epid
RA_CLIENT_SPID ?=
RA_CLIENT_LINKABLE ?= 0

.PHONY: all
all: app epid  # by default, only build EPID because it doesn't rely on additional (DCAP) libs

.PHONY: app
app: ssl/server.crt

.PHONY: epid
epid: ssl/server.crt server_epid

############################# SSL DATA DEPENDENCY #############################

# SSL data: key and x.509 self-signed certificate
ssl/server.crt: ssl/ca_config.conf
	openssl genrsa -out ssl/ca.key 2048
	openssl req -x509 -new -nodes -key ssl/ca.key -sha256 -days 1024 -out ssl/ca.crt -config ssl/ca_config.conf
	openssl genrsa -out ssl/server.key 2048
	openssl req -new -key ssl/server.key -out ssl/server.csr -config ssl/ca_config.conf
	openssl x509 -req -days 360 -in ssl/server.csr -CA ssl/ca.crt -CAkey ssl/ca.key -CAcreateserial -out ssl/server.crt

######################### CLIENT/SERVER EXECUTABLES ###########################

CFLAGS += -Wall -std=c11 $(shell pkg-config --cflags secret_prov_gramine)
LDFLAGS += -Wl,--enable-new-dtags $(shell pkg-config --libs secret_prov_gramine)

server_epid: server.c
	$(CC) $< $(CFLAGS) $(LDFLAGS) -lsecret_prov_verify_epid -pthread -o $@


################################## CLEANUP ####################################

.PHONY: clean
clean:
	$(RM) OUTPUT
	$(RM) client server_* *.token *.sig *.manifest.sgx *.manifest

.PHONY: distclean
distclean: clean
	$(RM) -r ssl/ca.* ssl/server.*
