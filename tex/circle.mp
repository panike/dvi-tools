def shipitout = shipit; charcode := charcode + 1; enddef;

vardef circarc(expr c,p) =
for i=0 upto11:
	p shifted -c rotated 30i shifted c ..
endfor cycle
enddef;

beginfig(1);
draw (-10pt,0)--(40pt,0);
draw (0,-20pt)--(0,20pt);
pickup pencircle scaled 4pt;
linecap:=rounded;
draw (15pt,0) withcolor green;
shipitout;
draw (0,0) withcolor red;
shipitout;
draw (15pt,-15pt) withcolor red;
shipitout;
draw (30pt,0) withcolor red;
shipitout;
draw (15pt,15pt) withcolor red;
shipitout;
pickup defaultpen;
draw circarc((15pt,0),(0,0));
endfig;

beginfig(7);
draw (-10pt,0)--(40pt,0);
draw (0,-20pt)--(0,20pt);
pickup pencircle scaled 4pt;
draw (0,0) withcolor red;
draw (15pt,0) withcolor green;
draw (15pt,-15pt) withcolor red;
draw (15pt,15pt) withcolor red;
pickup defaultpen;
draw circarc((15pt,0),(0,0));
dotlabel.urt(btex $(6,0)$ etex,(30pt,0));
endfig;
end
