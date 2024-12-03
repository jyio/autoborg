FROM alpine:latest

RUN	apk add --no-cache supercronic openssh-client borgbackup

COPY	--chmod=755 <<EOT /entrypoint.sh
#!/bin/sh
printenv CRONTAB > /crontab
exec /usr/bin/supercronic /crontab
EOT

COPY    --chmod=755 <<"EOT" /usr/local/bin/borgx
#!/bin/sh
if [ x"${BORGX_CD}" != x ]; then
	set -x; cd "${BORGX_CD}"; { set +x; } 2>/dev/null
fi
set -x; /usr/bin/borg "$@"; { set +x; } 2>/dev/null
if [ x"${BORGX_PRUNE}" != x ]; then
	if [ x"${BORGX_KEEP_WITHIN}" != x ] || [ x"${BORGX_KEEP_LAST}" != x ] || [ x"${BORGX_KEEP_SECONDLY}" != x ] || [ x"${BORGX_KEEP_MINUTELY}" != x ] || [ x"${BORGX_KEEP_HOURLY}" != x ] || [ x"${BORGX_KEEP_DAILY}" != x ] || [ x"${BORGX_KEEP_WEEKLY}" != x ] || [ x"${BORGX_KEEP_MONTHLY}" != x ] || [ x"${BORGX_KEEP_YEARLY}" != x ]; then
		CMD=/usr/bin/borg\ prune
		[ x"${BORGX_PRUNE_LIST}" != x ] &&		CMD=${CMD}\ --list
		[ x"${BORGX_KEEP_WITHIN}" != x ] &&		CMD=${CMD}\ --keep-within="${BORGX_KEEP_WITHIN}"
		[ x"${BORGX_KEEP_LAST}" != x ] &&		CMD=${CMD}\ --keep-last="${BORGX_KEEP_LAST}"
		[ x"${BORGX_KEEP_SECONDLY}" != x ] &&	CMD=${CMD}\ --keep-secondly="${BORGX_KEEP_SECONDLY}"
		[ x"${BORGX_KEEP_MINUTELY}" != x ] &&	CMD=${CMD}\ --keep-minutely="${BORGX_KEEP_MINUTELY}"
		[ x"${BORGX_KEEP_HOURLY}" != x ] &&		CMD=${CMD}\ --keep-hourly="${BORGX_KEEP_HOURLY}"
		[ x"${BORGX_KEEP_DAILY}" != x ] &&		CMD=${CMD}\ --keep-daily="${BORGX_KEEP_DAILY}"
		[ x"${BORGX_KEEP_WEEKLY}" != x ] &&		CMD=${CMD}\ --keep-weekly="${BORGX_KEEP_WEEKLY}"
		[ x"${BORGX_KEEP_MONTHLY}" != x ] &&	CMD=${CMD}\ --keep-monthly="${BORGX_KEEP_MONTHLY}"
		[ x"${BORGX_KEEP_YEARLY}" != x ] &&		CMD=${CMD}\ --keep-yearly="${BORGX_KEEP_YEARLY}"
		set -x; ${CMD}; { set +x; } 2>/dev/null
	fi
fi
if [ x"${BORGX_COMPACT}" != x ]; then
	set -x; /usr/bin/borg compact; { set +x; } 2>/dev/null
fi
EOT

WORKDIR	/root

CMD	["/entrypoint.sh"]
