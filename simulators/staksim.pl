#!/usr/bin/perl

# STAKSIM, wersja 16.1.2008

# program wczytywany przez stdin, chyba ze podana jest nazwa pliku jako parametr
# w przypadku wczytywania przez stdin, od razu wykonuje i wychodzi (na stdout listing i tabelka stanu po wykonaniu)
# w przypadku wczytywania z pliku, dziala w trybie komend
# gdy bledy, to ich tresc na stderr

# @p-tresc programu, %e-etykiety, %v-zmienne, @s-stos (dla skokow do podprogramow), $c=zliczone cykle
# @ms-stos dla operacji i argumentow skokow (push, pop, arytmetyczne, jmpy, jxx)
# @mss-stos (zawiera nazwe etykiety tam gdzie dana poz. w @ms jest etykieta i "?" jesli nie wiadomo co to jest)
# $pc-licznik programu
# $bpc-poprzednia wartosc licznika programu
# linie numerowane sa od 0. dla celow prezentacji numerowane od 1
# @sl-zawiera numery linii pod ktorymi sa kolejne instrukcje
@p=(); %e=(); %v=(); @s=(); @ms=(); @mss=(); $c=0; $bpc=-1; $pc=0; @sl=();


# naglowek
print "======== STAKSIM ========\n";

# czytanie programu
if(!($fin=pop)) {
    print "* reading program from stdin...";
    @p=<>;
} else {
    print "* reading from file $fin...";
    open PROG,"<$fin" or die "failed (file not found).\n";
    @p=<PROG>; close PROG
}
print "OK\n";

# sprawdz, czy program poprawny syntaktycznie,
# zbieranie etykiet, zmiennych i obcinanie enterow
# i wypelnianie @sl
przejrzyj();

# wylistuj wszystko na poczatek
listuj();

# program w porzadku
print "========= start =========\n";

# jesli wczytano program ze stdin, to od razu wykonaj i wypisz wynik koncowy
if(!$fin) {
    while(exists $sl[$pc]) { last unless rozkaz($p[$sl[$pc]]) }
    print "========== stop =========\n* program ended at line ",$sl[$pc],"\n";
    stan();
    stanzmiennych();
    exit;
}

# jesli wczytano program z pliku, to dzialaj w trybie konsoli
pomoc();
$li=""; # to co wpisal uzytkownik ostatnim razem
for(;;) {
    print "staksim>"; chomp($_=lc <>); s/\s//g; last if /^q/;
    $_=$li if /^$/;
    $li=$_;
    if(/^\?/) {
        pomoc()
    }elsif(/^r$/){
        if(exists $sl[$pc]) {
            print "* running...\n";
            while(exists $sl[$pc]) { last unless rozkaz($p[$sl[$pc]]) }
            print "* program ended at line ",$sl[$bpc]+1,"\n";
            stan()
        } else {
            print "* program stopped. use x to reset.\n"
        }
    }elsif(/^t$/){
        if(exists $sl[$pc]) {
            print "* running to nearest BRK...\n";
            while(exists $sl[$pc]) { last if rozkaz($p[$sl[$pc]])==3 }
            stan()
        } else {
            print "* program stopped. use x to reset.\n"
        }
    }elsif(/^s$/){
        if(exists $sl[$pc]) {
            print "* executing: ",$p[$sl[$pc]],"\n";
            rozkaz($p[$sl[$pc]]);
            stan()
        } else {
            print "* program stopped. use x to reset.\n"
        }
    }elsif(/^t(\d+)$/){
        $i=$1;
        if(exists $sl[$pc]) {
            print "* tracing $i steps...\n";
            while($i--&&exists $sl[$pc]) {
                while(exists $sl[$pc]) { last if rozkaz($p[$sl[$pc]])==3 }
            }
            stan()
        } else {
            print "* program stopped. use x to reset.\n"
        }
    }elsif(/^s(\d+)$/){
        $i=$1;
        if(exists $sl[$pc]) {
            print "* running $i steps...\n";
            rozkaz($p[$sl[$pc]]) while $i--&&exists $sl[$pc];
            stan()
        } else {
            print "* program stopped. use x to reset.\n"
        }
    }elsif(/^l$/){
        listuj()
    }elsif(/^k$/){
        stakstan()
    }elsif(/^l(\d+)$/){
        listuj($1)
    }elsif(/^l(\d*):(\S+)$/){
        if($1) { listuj($1,$2) } else { listuj(10,$2) }
    }elsif(/^v$/){
        stanzmiennych()
    }elsif(/^x$/){
        print "* clearing stacks\n"; @s=(); @ms=(); @mss=();
        print "* clearing cycle count\n"; $c=0;
        print "* clearing program counter\n"; $pc=0; $bpc=-1;
        print "* reloading program from file $fin...";
        open PROG,"<$fin" or die "failed (file not found).\n";
        @p=<PROG>; close PROG;
        print "OK\n";
        przejrzyj();
    }elsif(/^p$/){
        stan()
    }else{
        print "unknown command\n"
    }
}
print "Bye\n";

# jesli rozkaz($tresc), to wykonanie
# jesli rozkaz($tresc,"v"), to tylko weryfikacja, bez poprawnosci etykiet i zmiennych
# jesli rozkaz($tresc,"vv"), to weryfikacja, lacznie z poprawnoscia etykiet i zmiennych
# zwraca niezero, jesli dobra instrukcja (w tym 1 jesli cos tam bylo, 2 jesli pusta, 3 jesli brk)
sub rozkaz {
    $_=lc shift; s/\s//g; s/^[^:]*://; s/;.*$//; # wycinanie etykiety, spacji i komentarza
    my $mode=shift;
    $bpc=$pc unless $mode=~/v/;
    if(/^$/||/^dd/) { # linia pusta lub deklaracja zmiennej
        return 2;
    }elsif(/^brk$/) {
        $pc++ unless $mode=~/v/;
        return 3;
    }elsif(/^push#(\-?\d+)$/) {
        unless($mode=~/v/) {
            push @ms,$1; push @mss,"?"; $c+=2; $pc++;
        }
        return 1;
    }elsif(/^push\[([^\]]+)\]$/) {
        if($mode ne "v") { return 0 unless exists $v{$1} } # niepoprawny adres
        unless($mode=~/v/) {
            push @ms,$v{$1}; push @mss,"?"; $c+=3; $pc++;
        }
        return 1;
    }elsif(/^push#(.+)$/) {
        if($mode ne "v") { return 0 unless exists $e{$1} } # niepoprawny adres
        unless($mode=~/v/) {
            push @ms,$e{$1}; push @mss,$1; $c+=3; $pc++;
        }
        return 1;
    }elsif(/^pop\[([^\]]+)\]$/) {
        if($mode ne "v") { return 0 unless exists $v{$1} } # niepoprawny adres
        unless($mode=~/v/) {
            if(@ms==0) {
                print "* error: stack underflow\n";
                return 0;
            }
            $v{$1}=pop @ms; pop @mss; $c+=3; $pc++;
        }
        return 1;
    }elsif(/^mov\[([^\]]+)\],st\((\d+)\)$/) {
        if($mode ne "v") { return 0 unless exists $v{$1} } # niepoprawny adres
        unless($mode=~/v/) {
            if(@ms<=$2) {
                print "* error: stack underflow\n";
                return 0;
            }
            $v{$1}=$ms[$#ms-$2]; $c+=4; $pc++;
        }
        return 1;
    }elsif(/^movst\((\d+)\),\[([^\]]+)\]$/) {
        if($mode ne "v") { return 0 unless exists $v{$2} } # niepoprawny adres
        unless($mode=~/v/) {
            if(@ms<=$1) {
                print "* error: stack underflow\n";
                return 0;
            }
            $ms[$#ms-$1]=$v{$2}; $mss[$#ms-$1]="?"; $c+=4; $pc++;
        }
        return 1;
    }elsif(/^dup$/) {
        unless($mode=~/v/) {
            if(@ms==0) {
                print "* error: stack underflow\n";
                return 0;
            }
            push @ms,$ms[$#ms]; push @mss,$mss[$#mss]; $c+=2; $pc++;
        }
        return 1;
    }elsif(/^del$/) {
        unless($mode=~/v/) {
            if(@ms==0) {
                print "* error: stack underflow\n";
                return 0;
            }
            pop @ms; pop @mss; $c++; $pc++;
        }
        return 1;
    }elsif(/^swap$/) {
        unless($mode=~/v/) {
            if(@ms<2) {
                print "* error: stack underflow\n";
                return 0;
            }
            @ms=(@ms[0..$#ms-2],$ms[$#ms],$ms[$#ms-1]);
            @mss=(@mss[0..$#mss-2],$mss[$#mss],$mss[$#mss-1]);
            $c+=3; $pc++;
        }
        return 1;
    }elsif(/^add$/) {
        unless($mode=~/v/) {
            if(@ms<2) {
                print "* error: stack underflow\n";
                return 0;
            }
            push @ms,(pop(@ms)+pop(@ms)); pop @mss; $mss[$#mss]="?"; $c+=2; $pc++;
        }
        return 1;
    }elsif(/^sub$/) {
        unless($mode=~/v/) {
            if(@ms<2) {
                print "* error: stack underflow\n";
                return 0;
            }
            push @ms,-(pop(@ms)-pop(@ms)); pop @mss; $mss[$#mss]="?"; $c+=2; $pc++;
        }
        return 1;
    }elsif(/^mul$/) {
        unless($mode=~/v/) {
            if(@ms<2) {
                print "* error: stack underflow\n";
                return 0;
            }
            push @ms,(pop(@ms)*pop(@ms)); pop @mss; $mss[$#mss]="?"; $c+=3; $pc++;
        }
        return 1;
    }elsif(/^div$/) {
        unless($mode=~/v/) {
            if(@ms<2) {
                print "* error: stack underflow\n";
                return 0;
            }
            if($ms[$#ms]==0) {
                print "* error: division by zero\n";
                return 0;
            }
            $ms[$#ms-1]=int($ms[$#ms-1]/$ms[$#ms]); pop @ms; pop @mss; $mss[$#mss]="?"; $c+=4; $pc++;
        }
        return 1;
    }elsif(/^not$/) {
        unless($mode=~/v/) {
            if(@ms==0) {
                print "* error: stack underflow\n";
                return 0;
            }
            $ms[$#ms]=$ms[$#ms]?0:1; $mss[$#mss]="?"; $c++; $pc++;
        }
        return 1;
    }elsif(/^neg$/) {
        unless($mode=~/v/) {
            if(@ms==0) {
                print "* error: stack underflow\n";
                return 0;
            }
            $ms[$#ms]=-$ms[$#ms]; $mss[$#mss]="?"; $c++; $pc++;
        }
        return 1;
    }elsif(/^call$/) {
        unless($mode=~/v/) {
            if(@ms==0) {
                print "* error: stack underflow\n";
                return 0;
            }
            push @s,$pc+1;
            $pc=pop @ms; pop @mss; $c+=4;
        }
        return 1;
    }elsif(/^ret$/) {
        unless($mode=~/v/) {
            if(@s==0) {
                print "* error: stack underflow\n";
                return 0;
            }
            $pc=pop @s; $c+=4;
        }
        return 1;
    }elsif(/^jmp$/) {
        unless($mode=~/v/) {
            if(@ms==0) {
                print "* error: stack underflow\n";
                return 0;
            }
            $pc=pop @ms; pop @mss; $c+=2
        }
        return 1;
    }elsif(/^je$/) {
        unless($mode=~/v/) {
            if(@ms<2) {
                print "* error: stack underflow\n";
                return 0;
            }
            $pc=!$ms[$#ms-1]?$ms[$#ms]:$pc+1; $c=!$ms[$#ms-1]?$c+2:$c+1; $#ms-=2; $#mss-=2;
        }
        return 1;
    }elsif(/^jne$/) {
        unless($mode=~/v/) {
            if(@ms<2) {
                print "* error: stack underflow\n";
                return 0;
            }
            $pc=!$ms[$#ms-1]?$pc+1:$ms[$#ms]; $c=!$ms[$#ms-1]?$c+1:$c+2; $#ms-=2; $#mss-=2;
        }
        return 1;
    }elsif(/^jge$/) {
        unless($mode=~/v/) {
            if(@ms<2) {
                print "* error: stack underflow\n";
                return 0;
            }
            $pc=$ms[$#ms-1]<0?$pc+1:$ms[$#ms]; $c=$ms[$#ms-1]<0?$c+1:$c+2; $#ms-=2; $#mss-=2;
        }
        return 1;
    }elsif(/^jle$/) {
        unless($mode=~/v/) {
            if(@ms<2) {
                print "* error: stack underflow\n";
                return 0;
            }
            $pc=$ms[$#ms-1]<=0?$ms[$#ms]:$pc+1; $c=$ms[$#ms-1]<=0?$c+2:$c+1; $#ms-=2; $#mss-=2;
        }
        return 1;
    }elsif(/^jl$/) {
        unless($mode=~/v/) {
            if(@ms<2) {
                print "* error: stack underflow\n";
                return 0;
            }
            $pc=$ms[$#ms-1]<0?$ms[$#ms]:$pc+1; $c=$ms[$#ms-1]<0?$c+2:$c+1; $#ms-=2; $#mss-=2;
        }
        return 1;
    }elsif(/^jg$/) {
        unless($mode=~/v/) {
            if(@ms<2) {
                print "* error: stack underflow\n";
                return 0;
            }
            $pc=$ms[$#ms-1]<=0?$pc+1:$ms[$#ms]; $c=$ms[$#ms-1]<=0?$c+1:$c+2; $#ms-=2; $#mss-=2;
        }
        return 1;
    }else{
        return 0
    }
}

# wyswietla zawartosc zmiennych
sub stanzmiennych {
    print "====== variable list ======\n";
    print "  (no variables)\n" unless keys %v;
    for(keys %v) { print "$_ = ",$v{$_},"\n" }
    print "=== end of variable list ==\n";
}

# wyswietla stan procesora (i stos tez)
sub stan {
    print  "+------------------------+\n";
    printf "|  current pc: %9d |     next line : %s\n",$pc,exists $sl[$pc]?$p[$sl[$pc]]:"<program ended>";
    print  "+------------------------+\n";
    printf "| previous pc: %9d | previous line : %s\n",$bpc,$bpc>=0?$p[$sl[$bpc]]:"<nothing>";
    print  "+------------------------+\n";
    printf "| cycle count: %9d |\n",$c;
    print  "+------------------------+\n";
    stakstan()
}

sub stakstan {
    my $nstak; # numer elementu na stosie

    print  "+------------------------------------+\n";
    print  "| ===== operation-stack bottom ===== |\n";

    print "|           (stack empty)            |\n" if @ms==0;
    $nstak=0;
    for(@ms) { printf "|     %20s           |\n",$mss[$nstak] eq "?"?$_:$_." (label:".$mss[$nstak].")"; $nstak++ }

    print  "| ===== top of operation-stack ===== |\n";
    print  "+------------------------------------+\n";
    print  "| ======= call-stack bottom ======== |\n";

    print "|           (stack empty)            |\n" if @s==0;
    for(@s) { printf "|   %30s   |\n","adr:$_ (line:".($_<=$#sl?$sl[$_]+1:$#p+2).")" }

    print  "| ======= top of call-stack ======== |\n";
    print  "+------------------------------------+\n";
}

# sprawdz, czy program poprawny syntaktycznie, zbieranie etykiet i zmiennych i obcinanie enterow
sub przejrzyj {
    %e=(); %v=(); @sl=();
    print "* checking program text...";
    my $n=0; # numer linii
    my $in=0; # numer instrukcji
    my $rcode; # kod zwrocony przez rozkaz()
    my $l; # przegladana linia
    for $l(@p) {
        chomp($l);
        if($l=~m/^\s*(\S+)\s*:/) { # etykieta?
            exists $e{lc $1} and die "failed at line ",$n+1,": \"$l\" (label name must be unique)";
            $e{lc $1}=$in
        }
        if($l=~m/^\s*dd\s*(\S+)\s*$/i) { # zmienna?
            exists $v{lc $1} and die "failed at line ",$n+1,": \"$l\" (variable already exists)";
            $v{lc $1}=0
        }
        $rcode=rozkaz($l,"v") or die "failed at line ",$n+1,": \"$l\" (syntax error)";
        if($rcode==1||$rcode==3) {
            push @sl,$n;
            $in++;
        }
        $n++;
    }

    # sprawdz, czy nie ma odwolan do nieistniejacych zmiennych i etykiet
    $n=0; # numer linii
    for $l(@p) {
        rozkaz($l,"vv") or die "failed at line ",$n+1,": \"$l\" (reference to undefined label or variable)";
        $n++;
    }
    print "OK\n";

    # punkt wejscia
    if(exists $e{"start"}) {
        print "* setting pc to ",($pc=$e{"start"}),"\n"
    } else {
        print "* \"start\" label not found. assuming entry point at instruction 0\n"
    }
}

# help n/t komend
sub pomoc {
    print "=== commands:\n=== ? - display command list\n+++\n=== r - run until end\n=== s - one step forward\n".
      "=== sN - N steps forward\n".
      "=== t - run to nearest BRK\n=== tN - run to nearest N-th BRK\n+++\n".
      "=== p - processor state\n=== v - variable state\n=== k - stacks state\n+++\n".
      "=== l - list all\n=== lN - list around pc (2 backwd, N fwd)\n".
      "=== lN:M - list around line M (2 backwd, N fwd. N is optional - default N=10)\n".
      "=== lN:label - list arnd label (2 backwd, N fwd. N is optional - default N=10)\n+++\n".
      "=== x - program reset\n=== q - quit\n".
      "=== (enter empty line to repeat last command)\n"
}

# listowanie programu
# jesli bez parametru - caly
# jesli z parametrem - od linii $pc-2 wlacznie do $pc+parametr wlacznie
# jesli z dwoma parametrami - od linii (drugi param, moze byc etykieta, a jesli linia
# to numerowana od 1) do (drugim param)+(pierwszy param) wlacznie
sub listuj {
    my $n=0; my ($rel,$around,$lstart,$lend);
    my $naddr=0;

    # wycinanie pustych linii z konca
    while(@p>0) {
        if($p[$#p]=~/^\s*$/) { pop @p } else { last }
    }

    # listing itself
    print "     +-------------+---------+\n";
    print "     | line number | address |\n";
    print "     +-------------+---------+\n";

    if(@_>0) { # tylko dane linie
        $around=shift;
        if(@_>0) { # od wskazanej linii/etykiety
            $rel=shift;
            if($rel=~/\d+/) { $rel--; $lstart=$rel-2; $lend=$rel+$around }
            else {
                unless(exists $e{$rel}) {
                    print "* error: label \"$rel\" not found.\n";
                    return;
                }
                $lstart=$sl[$e{$rel}]-2;
                $lend=$sl[$e{$rel}]+$around
            }
        } else { # od pece
            if($pc<=$#sl) { $lstart=$sl[$pc]-2; $lend=$sl[$pc]+$around }
            else { $lstart=$#p-1; $lend=$#p }
        }
        $lstart=$#p if $lstart>$#p;
        $lstart=0 if $lstart<0;
        $lend=$#p if $lend>$#p;
        $n=$lstart;
        print "     |     ...     |   ...   |\n" if $lstart>0;
        while($n<=$lend) { # tylko wybrane linie
            if($pc&&exists $sl[$pc] and $n==$sl[$pc]) { print "---> " } else { print "     " }
            printf "| %11s | %7s | %s\n",$n+1,$n==$sl[$naddr]?$naddr:" ",$p[$n],"\n";
            $naddr++ if $n==$sl[$naddr];
            $n++;
        }
        print "     |     ...     |   ...   |\n" if $lend<$#p
    } else { # wszystko
        for $l(@p) {
            chomp($l);
            if($pc&&exists $sl[$pc] and $n==$sl[$pc]) { print "---> " } else { print "     " }
            printf "| %11s | %7s | %s\n",$n+1,$n==$sl[$naddr]?$naddr:" ",$p[$n],"\n";
            $naddr++ if $n==$sl[$naddr];
            $n++;
        }
    }

    print "     +-------------+---------+\n";
}