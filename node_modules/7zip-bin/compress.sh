#!/bin/sh

sz_program=${SZA_PATH:-7za}
sz_type=${SZA_ARCHIVE_TYPE:-xz}

exec "$sz_program" a f -si -so -t${sz_type} -mx${SZA_COMPRESSION_LEVEL:-9}