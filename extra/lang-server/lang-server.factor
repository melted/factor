! Copyright (C) 2019 Niklas Larsson.
! See http://factorcode.org/license.txt for BSD license.

USING: assocs combinators io io.encodings.utf8 io.files json json.reader
       json.writer kernel math.parser namespaces sequences
       splitting unicode ;
IN: lang-server

ERROR: invalid-message ;

TUPLE: sstate caps ;

SYMBOL: server

: <sstate> ( -- obj ) sstate new ;

: log? ( -- ? ) t ;

: log-data ( dat -- dat )
    dup log? [ "d:/Niklas/src/factor/langserv.log" utf8 [ ... write ] with-file-appender ] [ drop ] if ;

: read-header ( -- key/f val/f )
    readln dup empty? [ drop f f ] [ >lower ":" split1 ] if ;

: read-headers ( -- n/f )
    H{ } clone [ dup read-header [ spin set-at t ] [ drop ]  if* ] loop
    "content-length" swap at [ [ blank? ] trim string>number ] [ f ] if* ;

: read-message ( -- cmd/f ) read-headers [ read json> ] [ f ] if* ;

: write-message ( cmd -- ) >json dup length "Content-Length: " write
    number>string write nl nl write ;

: new-response ( cmd -- resp ) H{ } clone
    [ "2.0" "jsonrpc" rot set-at ] [ rot "id" swap at "id" rot set-at ] bi ;

: new-request ( id method params -- req ) 2drop ;

: server-caps ( -- caps )
    H{
        { "completionProvider" t }
    } clone ;

: handle-initialize ( cmd -- ? )
    new-response server-caps "capabilities" pick set-at write-message t ;

: handle-initialized ( cmd -- ? ) drop t ;

: handle-shutdown ( cmd -- ? ) ;

: handle-exit ( cmd -- ? ) drop f ;


: dispatch-method ( cmd method -- ? )
    { { "initialize" [ handle-initialize ] }
      { "initialized" [ handle-initialized ] }
      { "shutdown" [ handle-shutdown ] }
      { "exit" [ handle-exit ] } } case ;

: handle-one ( -- ? ) read-message dup "method" swap at
    [ dispatch-met hod ] [ drop f ] if* ;

: setup-server ( -- ) <sstate> server set ;

: serve ( -- ) setup-server [ handle-one ] loop  ;

MAIN: serve