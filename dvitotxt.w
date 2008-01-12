@*Introduction. This program is DVITOTXT.  It converts a DVI file to
its opcode representation, suitable for editing with a text editor 
(if one is careful).
@c
@<Header inclusions@>@;
@h
@<Enumerated types@>@;
@q@@<Global structure definitions@@>@@;@>
@<Global variable declarations@>@;
@<Global function declarations@>@;
@ @c int main(int argc,char* argv[])
{
    struct stat stat_buf;
    int filefd;
    unsigned char* file_buf;
    int ii,indent_width,the_indent_width;
    int num_read;
    unsigned char* file_buf_end;
    unsigned char* p,*pt;
    int k,a,l;
    indent_width=0;
    the_indent_width = INDENT_WIDTH;	
    @<Parse the command line@>@;
    @<Read in the file@>@;
    @<Output the file as text@>@;
    @<Clean up after ourselves@>@;
    return 0;
}
@ We output the file as text. Note that no error checking is done; this 
is a check to see that we know what we are doing. We have a damn big 
switch statement that processes the file.
@f dvi_op_code int
@<Output the file as text@>=
p = file_buf;
while(p < file_buf_end) {
    @<Indent the line@>@;
    switch((dvi_op_code)*p) {
        case set_char_0: case set_char_1: case set_char_2:
        case set_char_3: case set_char_4: case set_char_5:
        case set_char_6: case set_char_7: case set_char_8:
        case set_char_9: case set_char_10: case set_char_11:
        case set_char_12: case set_char_13: case set_char_14:
        case set_char_15: case set_char_16: case set_char_17:
        case set_char_18: case set_char_19: case set_char_20:
        case set_char_21: case set_char_22: case set_char_23:
        case set_char_24: case set_char_25: case set_char_26:
        case set_char_27: case set_char_28: case set_char_29:
        case set_char_30: case set_char_31: case set_char_32:
        case set_char_33: case set_char_34: case set_char_35:
        case set_char_36: case set_char_37: case set_char_38:
        case set_char_39: case set_char_40: case set_char_41:
        case set_char_42: case set_char_43: case set_char_44:
        case set_char_45: case set_char_46: case set_char_47:
        case set_char_48: case set_char_49: case set_char_50:
        case set_char_51: case set_char_52: case set_char_53:
        case set_char_54: case set_char_55: case set_char_56:
        case set_char_57: case set_char_58: case set_char_59:
        case set_char_60: case set_char_61: case set_char_62:
        case set_char_63: case set_char_64: case set_char_65:
        case set_char_66: case set_char_67: case set_char_68:
        case set_char_69: case set_char_70: case set_char_71:
        case set_char_72: case set_char_73: case set_char_74:
        case set_char_75: case set_char_76: case set_char_77:
        case set_char_78: case set_char_79: case set_char_80:
        case set_char_81: case set_char_82: case set_char_83:
        case set_char_84: case set_char_85: case set_char_86:
        case set_char_87: case set_char_88: case set_char_89:
        case set_char_90: case set_char_91: case set_char_92:
        case set_char_93: case set_char_94: case set_char_95:
        case set_char_96: case set_char_97: case set_char_98:
        case set_char_99: case set_char_100: case set_char_101:
        case set_char_102: case set_char_103: case set_char_104:
        case set_char_105: case set_char_106: case set_char_107:
        case set_char_108: case set_char_109: case set_char_110:
        case set_char_111: case set_char_112: case set_char_113:
        case set_char_114: case set_char_115: case set_char_116:
        case set_char_117: case set_char_118: case set_char_119:
        case set_char_120: case set_char_121: case set_char_122:
        case set_char_123: case set_char_124: case set_char_125:
        case set_char_126: case set_char_127:
            @<Typeset a single character@>@+@[break@];
        case set1: @<Typeset a single high character@>@+@[break@];
        case set2: @<Typeset a double-byte high character@>@+@[break@];
        case set3: @<Typeset a triple-byte high character@>@+@[break@];
        case set4: @<Typeset a quad-byte high character@>@+@[break@];
        case set_rule: @<Typeset a rule@>@+@[break@];
        case put1: @<Put a single potentially high character@>@+@[break@];
        case put2: @<Typeset a double-byte high character@>@+@[break@];
        case put3: @<Typeset a triple-byte high character@>@+@[break@];
        case put4: @<Typeset a quad-byte high character@>@+@[break@];
        case put_rule: @<Typeset a rule@>@+@[break@];
        case nop: @<It's a no-op. Do nothing@>@+@[break@];
        case bop: @<We begin a page@>@+@[break@];
        case eop: @<We end a page@>@+@[break@];
        case push: @<We push parameters onto the stack@>@+@[break@];
        case pop:@<We pop parameters off the stack@>@+@[break@];
        case right1: @<We shift with a one-byte right@>@+@[break@];
        case right2: @<We shift with a two-byte right@>@+@[break@];
        case right3: @<We shift with a three-byte right@>@+@[break@];
        case right4: @<We shift with a four-byte right@>@+@[break@];
        case w0: @<We shift right by |w|@>@+@[break@];
        case w1: @<We shift with a one-byte right@>@+@[break@];
        case w2: @<We shift with a two-byte right@>@+@[break@];
        case w3: @<We shift with a three-byte right@>@+@[break@];
        case w4: @<We shift with a four-byte right@>@+@[break@];
        case x0: @<We shift right by |w|@>@+@[break@];
        case x1:@<We shift with a one-byte right@>@+@[break@];
        case x2:@<We shift with a two-byte right@>@+@[break@];
        case x3:@<We shift with a three-byte right@>@+@[break@];
        case x4:@<We shift with a four-byte right@>@+@[break@];
        case down1: @<We shift with a one-byte right@>@+@[break@];
        case down2: @<We shift with a two-byte right@>@+@[break@];
        case down3: @<We shift with a three-byte right@>@+@[break@];
        case down4: @<We shift with a four-byte right@>@+@[break@];
        case y0: @<We shift right by |w|@>@+@[break@];
        case y1: @<We shift with a one-byte right@>@+@[break@];
        case y2: @<We shift with a two-byte right@>@+@[break@];
        case y3: @<We shift with a three-byte right@>@+@[break@];
        case y4: @<We shift with a four-byte right@>@+@[break@];
        case z0: @<We shift right by |w|@>@+@[break@];
        case z1: @<We shift with a one-byte right@>@+@[break@];
        case z2: @<We shift with a two-byte right@>@+@[break@];
        case z3: @<We shift with a three-byte right@>@+@[break@];
        case z4: @<We shift with a four-byte right@>@+@[break@];
        case fnt_num_0: case fnt_num_1: case fnt_num_2: case fnt_num_3:
        case fnt_num_4: case fnt_num_5: case fnt_num_6: case fnt_num_7:
        case fnt_num_8: case fnt_num_9: case fnt_num_10: case fnt_num_11:
        case fnt_num_12: case fnt_num_13: case fnt_num_14: case fnt_num_15:
        case fnt_num_16: case fnt_num_17: case fnt_num_18: case fnt_num_19:
        case fnt_num_20: case fnt_num_21: case fnt_num_22: case fnt_num_23:
        case fnt_num_24: case fnt_num_25: case fnt_num_26: case fnt_num_27:
        case fnt_num_28: case fnt_num_29: case fnt_num_30: case fnt_num_31:
        case fnt_num_32: case fnt_num_33: case fnt_num_34: case fnt_num_35:
        case fnt_num_36: case fnt_num_37: case fnt_num_38: case fnt_num_39:
        case fnt_num_40: case fnt_num_41: case fnt_num_42: case fnt_num_43:
        case fnt_num_44: case fnt_num_45: case fnt_num_46: case fnt_num_47:
        case fnt_num_48: case fnt_num_49: case fnt_num_50: case fnt_num_51:
        case fnt_num_52: case fnt_num_53: case fnt_num_54: case fnt_num_55:
        case fnt_num_56: case fnt_num_57: case fnt_num_58: case fnt_num_59:
        case fnt_num_60: case fnt_num_61: case fnt_num_62: case fnt_num_63:
                 @<Change the current font@>@+@[break@];
        case fnt1:
             @<Use one-byte high value to change the current font@>@+@[break@];
        case fnt2:
             @<Use two-byte values to change the current font@>@+@[break@];
        case fnt3:
             @<Use three-byte values to change the current font@>@+@[break@];
        case fnt4:
             @<Use four-byte values to change the current font@>@+@[break@];
        case xxx1:
             @<Do the special one-byte edition@>@+@[break@];
        case xxx2:
             @<Do the special two-byte edition@>@+@[break@];
        case xxx3:
             @<Do the special three-byte edition@>@+@[break@];
        case xxx4:
             @<Do the special four-byte edition@>@+@[break@];
        case fnt_def1: @<Define one-byte font@>@+@[break@];
        case fnt_def2: @<Define two-byte font@>@+@[break@];
        case fnt_def3: @<Define three-byte font@>@+@[break@];
        case fnt_def4: @<Define four-byte font@>@+@[break@];
        case pre: @<The preamble@>@+@[break@];
        case post: @<The postamble@>@+@[break@];
        case post_post: @<The post-postamble@>@+@[break@];
        default: fprintf(stderr,"Unknown opcode %02x at index %d.\n",*p,
                         p - file_buf); 
		fflush(stdout);
                 _exit(-5);
    }
}
@ @<Typeset a single char...@>=
print_n_chars(p,1);
if(isprint(*p))
	printf("%% %s \"%c\"\n",opcode_to_string((dvi_op_code)*p),*p);
else
	printf("%% %s\n",opcode_to_string((dvi_op_code)*p));
++p;
@ @<Typeset a single high...@>=
print_n_chars(p,2);
printf("%% %s %d\n",opcode_to_string((dvi_op_code)*p),buf_to_int(p+1,1));
p += 2;
@ @<Typeset a double-byte high character@>=
print_n_chars(p,3);
printf("%% %s %d\n",opcode_to_string((dvi_op_code)*p),buf_to_int(p+1,2));
p += 3;
@ @<Typeset a triple-byte high character@>=
print_n_chars(p,4);
printf("%% %s %d\n",opcode_to_string((dvi_op_code)*p),buf_to_int(p+1,3));
p += 4;
@ @<Typeset a quad-byte high character@>=
print_n_chars(p,5);
printf("%% %s %d\n",opcode_to_string((dvi_op_code)*p),buf_to_int(p+1,4));
p += 5;
@ @<Typeset a rule@>=
print_n_chars(p,9);
printf("%% %s %d %d\n",opcode_to_string((dvi_op_code)*p),
        buf_to_int(p+1,4),buf_to_int(p+5,4));
p += 9;
@ The following code is a cut and paste job.  Since our program is 
a simple filter rather than one that actually deals with fonts and 
such, we can get away with it.
@<Put a single potentially high character@>=
@<Typeset a single high...@>@;
@ This code is exactly the same as |@<Typeset a single char...@>|.
@<It's a no-op. Do nothing@>=
print_n_chars(p,1);
printf("%% %s\n",opcode_to_string((dvi_op_code)*p));
++p;
@ @<We begin a page@>=
printf("%% BEGINNING A PAGE\n");
print_n_chars(p,45);
printf("%% %s ",opcode_to_string((dvi_op_code)*p));
++p;
for(ii=0;ii<11;++ii) {
    printf("%d ",buf_to_int(p,4));
    p += 4;
}
printf("\n");
@ @<We end a page@>=
print_n_chars(p,1);
printf("%% %s\n",opcode_to_string((dvi_op_code)*p));
++p;
printf("%% ENDING A PAGE\n");
@
@d INDENT_WIDTH 2
@<We push parameters onto the stack@>=
print_n_chars(p,1);
printf("%% %s\n",opcode_to_string((dvi_op_code)*p));
indent_width += the_indent_width;
++p;
@ @<Indent the li...@>=
if(((dvi_op_code)*p)==pop && indent_width >= the_indent_width)
    indent_width -= the_indent_width;
for(ii=0;ii<indent_width;++ii)
    printf(" ");
@ @<We pop parameters off...@>=
print_n_chars(p,1);
printf("%% %s\n",opcode_to_string((dvi_op_code)*p));
++p;
@ @<We shift with a one-byte right@>=
print_n_chars(p,2);
printf("%% %s %d\n",opcode_to_string((dvi_op_code)*p),buf_to_int(p+1,1));
p += 2;
@ @<We shift with a two-byte right@>=
print_n_chars(p,3);
printf("%% %s %d\n",opcode_to_string((dvi_op_code)*p),buf_to_int(p+1,2));
p += 3;
@ @<We shift with a three-byte right@>=
print_n_chars(p,4);
printf("%% %s %d\n",opcode_to_string((dvi_op_code)*p),buf_to_int(p+1,3));
p += 4;
@ @<We shift with a four-byte right@>=
print_n_chars(p,5);
printf("%% %s %d\n",opcode_to_string((dvi_op_code)*p),buf_to_int(p+1,4));
p += 5;
@ There is not much going on here.  Again, this is basically like the
shifting right with explicit parameters above.
@<We shift right by |w|@>=
print_n_chars(p,1);
printf("%% %s\n",opcode_to_string((dvi_op_code)*p));
++p;
@ @<Change the current font@>=
print_n_chars(p,1);
printf("%% %s\n",opcode_to_string((dvi_op_code)*p));
++p;
@ @<Use one-byte high value to change the current font@>=
print_n_chars(p,2);
printf("%% %s %d\n",opcode_to_string((dvi_op_code)*p),buf_to_int(p+1,1));
p += 2;
@ @<Use two-byte values to change the current font@>=
print_n_chars(p,3);
printf("%% %s %d\n",opcode_to_string((dvi_op_code)*p),buf_to_int(p+1,2));
p += 3;
@ @<Use three-byte values to change the current font@>=
print_n_chars(p,4);
printf("%% %s %d\n",opcode_to_string((dvi_op_code)*p),buf_to_int(p+1,3));
p += 4;
@ @<Use four-byte values to change the current font@>=
print_n_chars(p,5);
printf("%% %s %d\n",opcode_to_string((dvi_op_code)*p),buf_to_int(p+1,4));
p += 5;
@ @<Do the special one-byte edition@>=
print_n_chars(p,2);
k = buf_to_unsigned_int(p+1,1);
print_n_chars(p+2,k);
printf("%% %s %d \"",opcode_to_string((dvi_op_code)*p),k);
p += 2;
@^Printing literal characters@>
for(ii=0;ii<k;++ii) if(isprint(p[ii])) printf("%c",p[ii]); else printf(".");
printf("\"\n");
p += ii;
@ @<Do the special two-byte edition@>=
print_n_chars(p,3);
k = buf_to_unsigned_int(p+1,2);
print_n_chars(p+3,k);
printf("%% %s %d \"",opcode_to_string((dvi_op_code)*p),k);
p += 3;
@^Printing literal characters@>
for(ii=0;ii<k;++ii) if(isprint(p[ii])) printf("%c",p[ii]); else printf(".");
printf("\"\n");
p += ii;
@ @<Do the special three-byte edition@>=
print_n_chars(p,4);
k = buf_to_unsigned_int(p+1,3);
print_n_chars(p+4,k);
printf("%% %s %d \"",opcode_to_string((dvi_op_code)*p),k);
p += 4;
@^Printing literal characters@>
for(ii=0;ii<k;++ii) if(isprint(p[ii])) printf("%c",p[ii]); else printf(".");
printf("\"\n");
p += ii;
@ @<Do the special four-byte edition@>=
print_n_chars(p,5);
k = buf_to_unsigned_int(p+1,4);
print_n_chars(p+5,k);
printf("%% %s %d \"",opcode_to_string((dvi_op_code)*p),k);
p += 5;
@^Printing literal characters@>
for(ii=0;ii<k;++ii) if(isprint(p[ii])) printf("%c",p[ii]); else printf(".");
printf("\"\n");
p += ii;
@ @<Define one-byte font@>=
print_n_chars(p,16);
a = buf_to_unsigned_int(p+14,1);
l = buf_to_unsigned_int(p+15,1);
print_n_chars(p+16,a+l);
printf("%% %s ",opcode_to_string((dvi_op_code)*p));
++p;
printf("%d ",buf_to_unsigned_int(p,1));
++p;
printf("%08x ",buf_to_unsigned_int(p,4));
p += 4;
printf("%d ",buf_to_unsigned_int(p,4));
p += 4;
printf("%d ",buf_to_unsigned_int(p,4));
p += 4;
printf("%d ",a);
printf("%d \"",l);
p += 2;
for(ii=a+l;ii>0;--ii) {
@^Printing literal characters@>
    if(isprint(*p)) printf("%c",*p); else printf(".");
    ++p;
}
printf("\"\n");
@ @<Define two-byte font@>=
print_n_chars(p,17);
a = buf_to_unsigned_int(p+15,1);
l = buf_to_unsigned_int(p+16,1);
print_n_chars(p+17,a+l);
printf("%% %s ",opcode_to_string((dvi_op_code)*p));
++p;
printf("%d ",buf_to_unsigned_int(p,2));
p += 2;
printf("%08x ",buf_to_unsigned_int(p,4));
p += 4;
printf("%d ",buf_to_unsigned_int(p,4));
p += 4;
printf("%d ",buf_to_unsigned_int(p,4));
p += 4;
printf("%d ",a);
printf("%d \"",l);
p += 2;
for(ii=a+l;ii>0;--ii) {
@^Printing literal characters@>
     if(isprint(*p)) printf("%c",*p); else printf(".");
    ++p;
}
printf("\"\n");
@ @<Define three-byte font@>=
print_n_chars(p,18);
a = buf_to_unsigned_int(p+16,1);
l = buf_to_unsigned_int(p+17,1);
print_n_chars(p+18,a+l);
printf("%% %s ",opcode_to_string((dvi_op_code)*p));
++p;
printf("%d ",buf_to_unsigned_int(p,3));
p += 3;
printf("%08x ",buf_to_unsigned_int(p,4));
p += 4;
printf("%d ",buf_to_unsigned_int(p,4));
p += 4;
printf("%d ",buf_to_unsigned_int(p,4));
p += 4;
printf("%d ",a);
printf("%d \"",l);
p += 2;
for(ii=a+l;ii>0;--ii) {
@^Printing literal characters@>
    if(isprint(*p)) printf("%c",*p); else printf(".");
    ++p;
}
printf("\"\n");
@ @<Define four-byte font@>=
print_n_chars(p,19);
a = buf_to_unsigned_int(p+17,1);
l = buf_to_unsigned_int(p+18,1);
print_n_chars(p+19,a+l);
printf("%% %s ",opcode_to_string((dvi_op_code)*p));
++p;
printf("%d ",buf_to_unsigned_int(p,4));
p += 4;
printf("%08x ",buf_to_unsigned_int(p,4));
p += 4;
printf("%d ",buf_to_unsigned_int(p,4));
p += 4;
printf("%d ",buf_to_unsigned_int(p,4));
p += 4;
printf("%d ",a);
printf("%d \"",l);
p += 2;
for(ii=a+l;ii>0;--ii) {
@^Printing literal characters@>
    if(isprint(*p)) printf("%c",*p); else printf(".");
    ++p;
}
printf("\"\n");
@ @<The preamble@>=
print_n_chars(p,15);
k = buf_to_unsigned_int(p+14,1);
print_n_chars(p+15,k);
printf("%% %s %d %d %d %d %d \"",
    opcode_to_string((dvi_op_code)*p),
    buf_to_int(p+1,1),
    buf_to_unsigned_int(p+2,4),
    buf_to_unsigned_int(p+6,4),
    buf_to_unsigned_int(p+10,4), k);
p += 15;
for(ii=k;ii>0;--ii) {
@^Printing literal characters@>
    if(isprint(*p)) printf("%c",*p); else printf(".");
    ++p;
}
printf("\"\n");
@ @<The postamb...@>=
print_n_chars(p,29);
printf("%% %s %d %d %d %d %d %d %d %d\n",opcode_to_string((dvi_op_code)*p),
        buf_to_unsigned_int(p+1,4),
        buf_to_unsigned_int(p+5,4),
        buf_to_unsigned_int(p+9,4),
        buf_to_unsigned_int(p+13,4),
        buf_to_unsigned_int(p+17,4),
        buf_to_unsigned_int(p+21,4),
        buf_to_unsigned_int(p+25,2),
        buf_to_unsigned_int(p+27,2));
p += 29;
@ @<The post-post...@>=
for(pt = p; pt < file_buf_end; ++pt) {
    print_n_chars(pt,1);
}
printf("%% %s %d %d\n",opcode_to_string((dvi_op_code)*p),
        buf_to_unsigned_int(p+1,4),
        buf_to_unsigned_int(p+5,1));
p += 6;
while(p < file_buf_end) ++p;
@ @<Enumerated types@>=
typedef enum {
set_char_0 = 0, set_char_1, set_char_2, set_char_3,
set_char_4, set_char_5, set_char_6, set_char_7,
    set_char_8, set_char_9, set_char_10, set_char_11,
    set_char_12, set_char_13, set_char_14, set_char_15,
    set_char_16, set_char_17, set_char_18, set_char_19,
    set_char_20, set_char_21, set_char_22, set_char_23,
    set_char_24, set_char_25, set_char_26, set_char_27,
    set_char_28, set_char_29, set_char_30, set_char_31,
    set_char_32, set_char_33, set_char_34, set_char_35,
    set_char_36, set_char_37, set_char_38, set_char_39,
    set_char_40, set_char_41, set_char_42, set_char_43,
    set_char_44, set_char_45, set_char_46, set_char_47,
    set_char_48, set_char_49, set_char_50, set_char_51,
    set_char_52, set_char_53, set_char_54, set_char_55,
    set_char_56, set_char_57, set_char_58, set_char_59,
    set_char_60, set_char_61, set_char_62, set_char_63,
    set_char_64, set_char_65, set_char_66, set_char_67,
    set_char_68, set_char_69, set_char_70, set_char_71,
    set_char_72, set_char_73, set_char_74, set_char_75,
    set_char_76, set_char_77, set_char_78, set_char_79,
    set_char_80, set_char_81, set_char_82, set_char_83,
    set_char_84, set_char_85, set_char_86, set_char_87,
    set_char_88, set_char_89, set_char_90, set_char_91,
    set_char_92, set_char_93, set_char_94, set_char_95,
    set_char_96, set_char_97, set_char_98, set_char_99,
    set_char_100, set_char_101, set_char_102, set_char_103,
    set_char_104, set_char_105, set_char_106, set_char_107,
    set_char_108, set_char_109, set_char_110, set_char_111,
    set_char_112, set_char_113, set_char_114, set_char_115,
    set_char_116, set_char_117, set_char_118, set_char_119,
    set_char_120, set_char_121, set_char_122, set_char_123,
    set_char_124, set_char_125, set_char_126, set_char_127,
    set1, set2, set3, set4, set_rule,
    put1, put2, put3, put4, put_rule,
    nop, bop, eop,
    push, pop,
    right1, right2, right3, right4,
    w0, w1, w2, w3, w4,
    x0, x1, x2, x3, x4,
    down1, down2, down3, down4,
    y0, y1, y2, y3, y4,
    z0, z1, z2, z3, z4,
    fnt_num_0, fnt_num_1, fnt_num_2, fnt_num_3,
    fnt_num_4, fnt_num_5, fnt_num_6, fnt_num_7,
    fnt_num_8, fnt_num_9, fnt_num_10, fnt_num_11,
    fnt_num_12, fnt_num_13, fnt_num_14, fnt_num_15,
    fnt_num_16, fnt_num_17, fnt_num_18, fnt_num_19,
    fnt_num_20, fnt_num_21, fnt_num_22, fnt_num_23,
    fnt_num_24, fnt_num_25, fnt_num_26, fnt_num_27,
    fnt_num_28, fnt_num_29, fnt_num_30, fnt_num_31,
    fnt_num_32, fnt_num_33, fnt_num_34, fnt_num_35,
    fnt_num_36, fnt_num_37, fnt_num_38, fnt_num_39,
    fnt_num_40, fnt_num_41, fnt_num_42, fnt_num_43,
    fnt_num_44, fnt_num_45, fnt_num_46, fnt_num_47,
    fnt_num_48, fnt_num_49, fnt_num_50, fnt_num_51,
    fnt_num_52, fnt_num_53, fnt_num_54, fnt_num_55,
    fnt_num_56, fnt_num_57, fnt_num_58, fnt_num_59,
    fnt_num_60, fnt_num_61, fnt_num_62, fnt_num_63,
    fnt1, fnt2, fnt3, fnt4,
    xxx1, xxx2, xxx3, xxx4,
    fnt_def1, fnt_def2, fnt_def3, fnt_def4,
    pre, post, post_post 
} dvi_op_code;
@
@<Global func...@>=
char* opcode_to_string(dvi_op_code);
@
@c
char* opcode_to_string(dvi_op_code c)
{
    int idx = (int)c;
    static char* op_strings[] = @[@<Define the translation table@>@];
    return op_strings[idx];
}
@
@<Define the trans...@>={
    "set_char_0", "set_char_1", "set_char_2", "set_char_3",
    "set_char_4", "set_char_5", "set_char_6", "set_char_7",
    "set_char_8", "set_char_9", "set_char_10", "set_char_11",
    "set_char_12", "set_char_13", "set_char_14", "set_char_15",
    "set_char_16", "set_char_17", "set_char_18", "set_char_19",
    "set_char_20", "set_char_21", "set_char_22", "set_char_23",
    "set_char_24", "set_char_25", "set_char_26", "set_char_27",
    "set_char_28", "set_char_29", "set_char_30", "set_char_31",
    "set_char_32", "set_char_33", "set_char_34", "set_char_35",
    "set_char_36", "set_char_37", "set_char_38", "set_char_39",
    "set_char_40", "set_char_41", "set_char_42", "set_char_43",
    "set_char_44", "set_char_45", "set_char_46", "set_char_47",
    "set_char_48", "set_char_49", "set_char_50", "set_char_51",
    "set_char_52", "set_char_53", "set_char_54", "set_char_55",
    "set_char_56", "set_char_57", "set_char_58", "set_char_59",
    "set_char_60", "set_char_61", "set_char_62", "set_char_63",
    "set_char_64", "set_char_65", "set_char_66", "set_char_67",
    "set_char_68", "set_char_69", "set_char_70", "set_char_71",
    "set_char_72", "set_char_73", "set_char_74", "set_char_75",
    "set_char_76", "set_char_77", "set_char_78", "set_char_79",
    "set_char_80", "set_char_81", "set_char_82", "set_char_83",
    "set_char_84", "set_char_85", "set_char_86", "set_char_87",
    "set_char_88", "set_char_89", "set_char_90", "set_char_91",
    "set_char_92", "set_char_93", "set_char_94", "set_char_95",
    "set_char_96", "set_char_97", "set_char_98", "set_char_99",
    "set_char_100", "set_char_101", "set_char_102", "set_char_103",
    "set_char_104", "set_char_105", "set_char_106", "set_char_107",
    "set_char_108", "set_char_109", "set_char_110", "set_char_111",
    "set_char_112", "set_char_113", "set_char_114", "set_char_115",
    "set_char_116", "set_char_117", "set_char_118", "set_char_119",
    "set_char_120", "set_char_121", "set_char_122", "set_char_123",
    "set_char_124", "set_char_125", "set_char_126", "set_char_127",
    "set1", "set2", "set3", "set4", "set_rule",
    "put1", "put2", "put3", "put4", "put_rule",
    "nop", "bop", "eop", "push", "pop",
    "right1", "right2", "right3", "right4",
    "w0", "w1", "w2", "w3", "w4",
    "x0", "x1", "x2", "x3", "x4",
    "down1", "down2", "down3", "down4",
    "y0", "y1", "y2", "y3", "y4",
    "z0", "z1", "z2", "z3", "z4",
    "fnt_num_0", "fnt_num_1", "fnt_num_2", "fnt_num_3",
    "fnt_num_4", "fnt_num_5", "fnt_num_6", "fnt_num_7",
    "fnt_num_8", "fnt_num_9", "fnt_num_10", "fnt_num_11",
    "fnt_num_12", "fnt_num_13", "fnt_num_14", "fnt_num_15",
    "fnt_num_16", "fnt_num_17", "fnt_num_18", "fnt_num_19",
    "fnt_num_20", "fnt_num_21", "fnt_num_22", "fnt_num_23",
    "fnt_num_24", "fnt_num_25", "fnt_num_26", "fnt_num_27",
    "fnt_num_28", "fnt_num_29", "fnt_num_30", "fnt_num_31",
    "fnt_num_32", "fnt_num_33", "fnt_num_34", "fnt_num_35",
    "fnt_num_36", "fnt_num_37", "fnt_num_38", "fnt_num_39",
    "fnt_num_40", "fnt_num_41", "fnt_num_42", "fnt_num_43",
    "fnt_num_44", "fnt_num_45", "fnt_num_46", "fnt_num_47",
    "fnt_num_48", "fnt_num_49", "fnt_num_50", "fnt_num_51",
    "fnt_num_52", "fnt_num_53", "fnt_num_54", "fnt_num_55",
    "fnt_num_56", "fnt_num_57", "fnt_num_58", "fnt_num_59",
    "fnt_num_60", "fnt_num_61", "fnt_num_62", "fnt_num_63",
    "fnt1", "fnt2", "fnt3", "fnt4",
    "xxx1", "xxx2", "xxx3", "xxx4",
    "fnt_def1", "fnt_def2", "fnt_def3", "fnt_def4",
    "pre", "post", "post_post" 
}
@ @<Global func...@>=
void print_n_chars(unsigned char* p,int n);
@ @c
void print_n_chars(unsigned char* p,int n)
{
    int ii;

    for(ii=0;ii<n;++ii) printf("%02x ",p[ii]);
}
@*Reading in the file. This is some boilerplate code to read a file
into memory.
@<Read in the file@>=
if(stat(filename,&stat_buf) != 0) {
   fprintf(stderr,"Error stat-ting %s.\n",filename); 
   _exit(-1);
}
if((filefd = open(filename,O_RDONLY)) < 0) {
    fprintf(stderr,"Could not open %s.\n", filename);
   _exit(-2);
}
file_buf = (unsigned char*)malloc(stat_buf.st_size);
if(!file_buf) {
    fprintf(stderr,"Could not allocate enough memory to hold %s.\n",
                filename);
   _exit(-3);
}
@ @<Read in the ...@>=
for(ii=0;ii<stat_buf.st_size;ii += num_read) {
    num_read = read(filefd,&file_buf[ii],stat_buf.st_size - ii);
    if(num_read < 0) {
        fprintf(stderr,"Error reading from %s",filename); 
        free(file_buf);
        close(filefd);
        _exit(-4);
    }@+else if(num_read == 0) {
        stat_buf.st_size = ii;
        break;
    }
}
file_buf_end = file_buf + ii;
close(filefd); filefd = -1;
@ @<Clean up...@>=
if(filefd >= 0) close(filefd);
if(file_buf != 0) free(file_buf);
@ @<Parse the command...@>=
filename=0;
for(ii=1;ii<argc;++ii){
   if(strcmp("-f",argv[ii])==0){
        ++ii;
        filename=argv[ii]; 
   } 
   if(strcmp("-i",argv[ii])==0){
       ++ii;
       the_indent_width = atoi(argv[ii]);
   }
}
if(argc<3) {
    fprintf(stderr,"Usage: %s <-f DVI file> [-i indent_width]\n",argv[0]);
    fflush(stderr);
    _exit(-6);
}
@ @<Global vari...@>=
char* filename;
@ For the purposes of this program, it does not matter what this says; the
bytes get copied into the DVI file anyway. But for reading, it does matter.
@<Global func...@>=
int buf_to_unsigned_int(unsigned char* p,int k)
{
    int result = 0,i;
    for(i=0;i<k;++i) {
        result <<= 8;
        result |= *p;
        ++p; 
    }
    return result;
}
@
@<Global func...@>=
int buf_to_int(unsigned char* p,int k)
{
    int result = 0,i;
    if(*p & 0x80)
        result = -1; 
    for(i=0;i<k;++i) {
        result <<= 8;
        result |= *p;
        ++p; 
    }
    return result;
}
@ @<Header inclusions@>=
#include <sys/types.h>
#include <sys/stat.h>
#include <unistd.h>
#include <fcntl.h>
#include <stdio.h>
#include <stdlib.h>
#include <ctype.h>
#include <string.h>
