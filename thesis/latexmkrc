$xdvipdfmx = "xdvipdfmx -z 0 -o %D %O %S";
$dvi_mode = 0;
$postscript_mode = 0;
$hash_calc_ignore_pattern{'timestamp'} = '^';

# https://tex.stackexchange.com/questions/1226/how-to-make-latexmk-use-makeglossaries
# https://overleaf.com/learn/how-to/How_does_Overleaf_compile_my_project%3F

# glossaries package
add_cus_dep('glo', 'gls', 0, 'makeglo2gls');
sub makeglo2gls {
    system("makeindex -s '$_[0]'.ist -t '$_[0]'.glg -o '$_[0]'.gls '$_[0]'.glo");
}

# nomencl package
add_cus_dep( 'nlo', 'nls', 0, 'makenlo2nls' );
sub makenlo2nls {
system( "makeindex -s nomencl.ist -o \"$_[0].nls\" \"$_[0].nlo\"" );
}
