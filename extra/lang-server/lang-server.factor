! Copyright (C) 2019 Niklas Larsson.
! See http://factorcode.org/license.txt for BSD license.

USING: assocs io io.encodings.utf8 io.files json json.reader json.writer kernel
       math.parser sequences splitting unicode ;
IN: lang-server


: log? ( -- ? ) t ;

: log-data ( dat -- dat )
    dup log? [ "langserv.log" utf8 [ write ] with-file-appender ] [ drop ] if ;

: read-header ( -- key/f val/f )
    readln dup empty? [ drop f f ] [ >lower log-data ":" split1 ] if ;

: read-headers ( -- n/f )
    H{ } [ dup read-header [ swap rot push-at t ] [ 2drop f ]  if* ] loop
    "content-length" swap at first [ [ blank? ] trim string>number ] [ f ] if* ;

: read-message ( -- cmd/f ) read-headers [ read json> ] [ f ] if* ;

: write-message ( cmd -- ) >json dup length "Content-Length: " write
    number>string write nl nl write ;

: handle-one ( -- ? ) read-message ;

: setup-server ( -- ) ;

: serve ( -- ) setup-server [ handle-one ] loop  ;

MAIN: serve