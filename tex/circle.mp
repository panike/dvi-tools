def shipitout = shipit; charcode := charcode + 1; enddef;

vardef circarc(expr c,p) =
for i=0 upto11:
	p shifted -c rotated 30i shifted c ..
endfor cycle
enddef;

beginfig(1);
draw (-10pt,0)--(40pt,0);
draw (0,-20pt)--(0,20pt);
draw circarc((15pt,0),(0,0));
dotlabel.urt(btex $(6,0)$ etex,(30pt,0));
shipitout;
endfig;
end
