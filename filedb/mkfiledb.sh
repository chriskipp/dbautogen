#!/bin/zsh

# HOME dir
${HOME}/bin/mkfiledb \
	-d "${HOME}/db/home.sqlite" \
	-T "tmp" \
	-t "files" \
	-f "${HOME}" \
	-p " -name .cache -o -name mnt -o -name .tor "

# Root dir
${HOME}/bin/mkfiledb \
	-f "/" \
	-d "${HOME}/db/root.sqlite" \
	-T "tmp" \
	-t "files" \
	-p " -name proc -o -name opt -o -name tmp -o -name home -o -name root -o -name sys -o -name media "

# ExtHDD
[ -e "${HOME}/mnt/extssd" ] && \
       	${HOME}/bin/mkfiledb \
	-d "${HOME}/db/extssd.sqlite" \
	-f "${HOME}/mnt/extssd" \
	-T "tmp" \
	-t "files" \
	-p " -name .cache -o -name mnt "

## Server
#[ -e "${HOME}/mnt/server" ] && \
#       	${HOME}/bin/mkfiledb \
#		-d "${HOME}/db/server.sqlite" \
#		-f "${HOME}/mnt/server" \
#		-T "tmp" \
#		-t "files" \
#		-s 100 \
#		-p " -name .cache -o -name mnt -o -name .tor "

## Storage
#[ 'fuse.sshfs' = $(
#	find "${HOME}/mnt/storage" \
#		-maxdepth 0 \
#		-not \
#		-empty \
#		-printf '%F'
#) ] && \
#	${HOME}/bin/mkfiledb \
#		-d "${HOME}/db/storage.sqlite" \
#		-T "tmp" \
#		-t "storage" \
#		-f "${HOME}/mnt/storage" \
#		-p " -name .cache "

