@*Introduction. This program is TXTTODVI.
It converts a text representation of the DVI file to a DVI file. The usefulness
of this is that one can convert the DVI file to text, edit it, and write
it back out to a DVI file.  We try to be intelligent about how we write the
DVI file back out to disk, so that if errors slip in during the editing
process, this program will try to fix it.
@c
@<Header inclusions@>@;
@h
@<Enumerated types@>@;
@<Global structure definitions@>@;
@<Global variable declarations@>@;
@<Global function declarations@>@;
@ @f out_fil int
@c int main(int argc,char* argv[])
{
    struct stat stat_buf,out_stat_buf;
    struct out_fil fil;
    int filefd,ii,num_read,k,a,l,stack_level=0,in_a_page=0;
    int current_fil_offset=0,current_bop,last_bop=-1;
    int post_offset=0,max_stack_level=0,number_of_pages=0;
    unsigned char* file_buf,*file_buf_end,*p,*curr_out,*curr_in,ch;
    @<Parse the command line@>@;
    @<Initialize the program@>@;
    @<Read in the file@>@;
    @<Convert the file to binary@>@;
    @<Fix the file@>@;  
    @<Clean up after ourselves@>@;
    return 0;
}
@ @<Convert the file...@>=
curr_out = curr_in = file_buf;
while(curr_in < file_buf_end) {
    while(curr_in < file_buf_end && cat_code[(int)*curr_in] == SPACE) 
        ++curr_in;    
    if(curr_in >= file_buf_end) break;
    if(cat_code[(int)*curr_in] == COMMENT) {
        while(curr_in < file_buf_end && *curr_in != '\n') 
            ++curr_in;
        continue;
    } 
    ch = hex_to_int(curr_in);
    curr_in += 2;
    *curr_out++ = ch;
}
file_buf_end = curr_out;
@ @<Global func...@>=
unsigned char hex_to_int(unsigned char* s)
{
    unsigned char result = 0;
    if(cat_code[(int)*s] != HEX_DIGIT || cat_code[(int)s[1]] != HEX_DIGIT) {
        fprintf(stderr,"Not a hex digit.\n"); 
        _exit(-7);
    }
    switch(*s) {
        case '0': case '1': case '2': case '3': case '4':
        case '5': case '6': case '7': case '8': case '9':
           result |= *s - '0'; 
           break;
        case 'a': case 'b': case 'c': 
        case 'd': case 'e': case 'f': 
           result |= *s - 'a' + 0xa; 
           break;
        case 'A': case 'B': case 'C': 
        case 'D': case 'E': case 'F': 
           result |= *s - 'a' + 0xa; 
           break;
        default: break;
    }
    ++s;
    result <<= 4;
    switch(*s) {
        case '0': case '1': case '2': case '3': case '4':
        case '5': case '6': case '7': case '8': case '9':
           result |= *s - '0'; 
           break;
        case 'a': case 'b': case 'c': 
        case 'd': case 'e': case 'f': 
           result |= *s - 'a' + 0xa; 
           break;
        case 'A': case 'B': case 'C': 
        case 'D': case 'E': case 'F': 
           result |= *s - 'A' + 0xa; 
           break;
        default: break;
    }
    return result;
}
@ We output the file as text. Note that no error checking is done; this 
is a check to see that we know what we are doing. We have a damn big 
switch statement that processes the file.
@<Fix the file@>=
p = file_buf;
while(p < file_buf_end) {
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
@ @<Global struct...@>=
struct out_fil {
   int fd;
   int offset;
   int length;
   unsigned char* buffer;
};
@ @<Global func...@>=
void write_out(unsigned char*,int,struct out_fil*);
@ @c
void write_out(unsigned char*p,int n,struct out_fil* filp)
{
    int k=0;

    while(k<n) {
        for(;filp->offset < filp->length && k<n;++k){
            filp->buffer[filp->offset] = p[k]; 
            ++filp->offset;
        }
        if(filp->offset >= filp->length) flush_out(filp);
    }
}
@ @<Global func...@>=
void flush_out(struct out_fil*);
@ @c
void flush_out(struct out_fil* filp)
{
    int j,num_written;

    fprintf(stderr,"Writing %d bytes in flush_out.\n",filp->offset);
    for(j=0;j<filp->offset;j += num_written)  {
        num_written = write(filp->fd,&filp->buffer[j],filp->offset-j);
        if(num_written < 0) {
            fprintf(stderr,"Error writing to the file.\n"); 
            _exit(-14);
        }@+else if(num_written == 0) {
            fprintf(stderr,"No more writing to the file.\n"); 
            _exit(-13);
        }
    }
    filp->offset = 0;
}

@ @<Typeset a single char...@>=
write_out(p,1,&fil);
++current_fil_offset;
++p;
@ @<Typeset a single high...@>=
write_out(p,2,&fil);
current_fil_offset+=2;
p += 2;
@ @<Typeset a double-byte high character@>=
write_out(p,3,&fil);
current_fil_offset+=3;
p += 3;
@ @<Typeset a triple-byte high character@>=
write_out(p,4,&fil);
current_fil_offset+=4;
p += 4;
@ @<Typeset a quad-byte high character@>=
write_out(p,5,&fil);
current_fil_offset+=5;
p += 5;
@ @<Typeset a rule@>=
write_out(p,9,&fil);
current_fil_offset+=9;
p += 9;
@ The following code is a cut and paste job.  Since our program is 
a simple filter rather than one that actually deals with fonts and 
such, we can get away with it.
@<Put a single potentially high character@>=
@<Typeset a single high...@>@;
@ This code is exactly the same as |@<Typeset a single char...@>|.
@<It's a no-op. Do nothing@>=
write_out(p,1,&fil);
++current_fil_offset;
++p;
@ Here we must remember what is going on.  The user has converted
the DVI file to a text file and edited it.  Presumably he will not be
so foolish as to add anything; rather, he will simply be moving stuff
around, copying and pasting, and doing some cutting. Consequently, our
main job is to make sure that the number of |push|es matches the
number of |pop|s, and that an |eop| is not inadvertently left out.  Finally,
we need to make sure that the pointer fields are correct.
@<We begin a page@>=
current_bop=current_fil_offset;
if(stack_level > 0) fprintf(stderr,"Stack not zero.\n");
@<Fix up the stack@>@;
if(in_a_page != 0) {
    fprintf(stderr,"bop in the middle of a page!.\n");
    write_eop(&fil);
    ++current_fil_offset;
    in_a_page = 0;  
}
++in_a_page;
@ @<We begin a page@>=
int_to_dvi_pointer(last_bop,(char*)&p[41]);
if(repaginate)
	@<Fix up \.{count0}@>@;
write_out(p,45,&fil);
++number_of_pages;
current_fil_offset += 45;
p+=45;
last_bop = current_bop;
@ @<Global vari...@>=
int repaginate;
int current_page_number;
@ @<Fix up \.{count0}@>={
    int_to_dvi_pointer(current_page_number,(char*)&p[1]);
    ++current_page_number;
}
@ @<Initialize the prog...@>=
current_page_number=1;
@ @<Global func...@>=
void write_eop(struct out_fil*);
void write_pop(struct out_fil*);
@ @<Fix up the stack@>=
while(stack_level > 0) {
    write_pop(&fil); 
    ++current_fil_offset;
    --stack_level;
}
@ @c void write_eop(struct out_fil*filp)
{
    unsigned char ch;
    ch = (unsigned char)eop;
    write_out(&ch,1,filp);
}
@ @c void write_pop(struct out_fil*filp)
{
    unsigned char ch;
    ch = (unsigned char)pop;
    write_out(&ch,1,filp);
}
@ @<We end a page@>=
if(stack_level > 0) fprintf(stderr,"Stack is not zero at eop.\n");
@<Fix up the stack@>@;
--in_a_page;
if(in_a_page != 0) {
    fprintf(stderr,"Ackkk... something is seriously wrong.\n");
    _exit(-14);
}
write_out(p,1,&fil);
++current_fil_offset;
++p;
@ @<We push parameters onto the stack@>=
++stack_level;
if(stack_level > max_stack_level)
    max_stack_level = stack_level;
write_out(p,1,&fil);
++current_fil_offset;
++p;
@ @<We pop parameters off...@>=
--stack_level;
if(stack_level < 0) {
    fprintf(stderr,"Stack underflow at index %d!\n",p-file_buf);
    _exit(-10);
}
write_out(p,1,&fil);
++current_fil_offset;
++p;
@ @<We shift with a one-byte right@>=
write_out(p,2,&fil);
current_fil_offset+=2;
p += 2;
@ @<We shift with a two-byte right@>=
write_out(p,3,&fil);
current_fil_offset+=3;
p += 3;
@ @<We shift with a three-byte right@>=
write_out(p,4,&fil);
current_fil_offset+=4;
p += 4;
@ @<We shift with a four-byte right@>=
write_out(p,5,&fil);
current_fil_offset+=5;
p += 5;
@ There is not much going on here.  Again, this is basically like the
shifting right with explicit parameters above.
@<We shift right by |w|@>=
write_out(p,1,&fil);
++current_fil_offset;
++p;
@ @<Change the current font@>=
write_out(p,1,&fil);
++current_fil_offset;
++p;
@ @<Use one-byte high value to change the current font@>=
write_out(p,2,&fil);
current_fil_offset+=2;
p += 2;
@ @<Use two-byte values to change the current font@>=
write_out(p,3,&fil);
current_fil_offset+=3;
p += 3;
@ @<Use three-byte values to change the current font@>=
write_out(p,4,&fil);
current_fil_offset+=4;
p += 4;
@ @<Use four-byte values to change the current font@>=
write_out(p,5,&fil);
current_fil_offset+=5;
p += 5;
@ @<Do the special one-byte edition@>=
k = buf_to_unsigned_int(p+1,1);
write_out(p,2+k,&fil);
current_fil_offset += 2+k;
p += 2+k;
@ @<Do the special two-byte edition@>=
k = buf_to_unsigned_int(p+1,2);
write_out(p,3+k,&fil);
current_fil_offset += 3+k;
p += 3+k;
@ @<Do the special three-byte edition@>=
k = buf_to_unsigned_int(p+1,3);
write_out(p,4+k,&fil);
current_fil_offset += 4+k;
p += 4+k;
@ @<Do the special four-byte edition@>=
k = buf_to_unsigned_int(p+1,4);
write_out(p,5+k,&fil);
current_fil_offset += 5+k;
p += 5+k;
@ @<Define one-byte font@>=
a = buf_to_unsigned_int(p+14,1);
l = buf_to_unsigned_int(p+15,1);
write_out(p,16+a+l,&fil);
current_fil_offset += 16+a+l;
p += 16 + a + l;
@ @<Define two-byte font@>=
a = buf_to_unsigned_int(p+15,1);
l = buf_to_unsigned_int(p+16,1);
write_out(p,17+a+l,&fil);
current_fil_offset += 17+a+l;
p += 17 + a + l;
@ @<Define three-byte font@>=
a = buf_to_unsigned_int(p+16,1);
l = buf_to_unsigned_int(p+17,1);
write_out(p,18+a+l,&fil);
current_fil_offset += 18+a+l;
p += 18 + a + l;
@ @<Define four-byte font@>=
a = buf_to_unsigned_int(p+17,1);
l = buf_to_unsigned_int(p+18,1);
write_out(p,19+a+l,&fil);
current_fil_offset += 19+a+l;
p += 19 + a + l;
@ @<The preamble@>=
k = buf_to_unsigned_int(p+14,1);
write_out(p,15+k,&fil);
current_fil_offset += 15+k;
p += 15 + k;
@ @<The postamb...@>=
post_offset = current_fil_offset;
int_to_dvi_pointer(last_bop,(char*)(p+1));
short_to_dvi_pointer(max_stack_level,(char*)(p+25));
short_to_dvi_pointer(number_of_pages,(char*)(p+27));
write_out(p,29,&fil);
current_fil_offset += 29;
p += 29;
@ @<The post-post...@>=
int_to_dvi_pointer(post_offset,(char*)(p+1));
write_out(p,6,&fil);
current_fil_offset += 6;
p += 6;
*p = 0xdf;
for(ii=0;ii<4;++ii) write_out(p,1,&fil);
current_fil_offset += 4;
fprintf(stderr,"The file offset is %d.\n",current_fil_offset);
if(current_fil_offset % 4 == 0) ii=0;
else ii = 4 - current_fil_offset % 4;
fprintf(stderr,"Saw post-post. Writing %d bytes.\n",ii);
while(ii>0) {
    fprintf(stderr,"Writing...\n");
    --ii;
    write_out(p,1,&fil);
}
p = file_buf_end;
flush_out(&fil);
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
filename=outfilename=(char*)0;
repaginate=0;
for(ii=1;ii<argc;++ii){
    if(strcmp(argv[ii],"-f")==0){
       ++ii;
       filename=argv[ii];  
    }
    if(strcmp(argv[ii],"-o")==0){
        ++ii;
        outfilename = argv[ii];  
    }
    if(strcmp(argv[ii],"-repage")==0)
        repaginate=1; 
}
@ @<Print a helpful message@>={
    fprintf(stderr,"Usage: %s "
            "<-f text-file> "
            "<-o output-file> "
            "[-repage]\n",argv[0]);
    fflush(stderr);
    _exit(-6);
}
@ @<Parse the command...@>=
if(!filename || !outfilename)
    @<Print a helpful message@>@;
@ @<Global vari...@>=
char* filename;
@
@d buf_to_int buf_to_unsigned_int
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
@d SPACE 256
@d COMMENT 257
@d HEX_DIGIT 258
@<Global vari...@>=
int cat_code[256];
@ @<Initialize the pro...@>=
for(ii=0;ii<256;++ii) cat_code[ii] = SPACE;
cat_code[@'%']=COMMENT;
cat_code[@'0']=HEX_DIGIT;
cat_code[@'1']=HEX_DIGIT;
cat_code[@'2']=HEX_DIGIT;
cat_code[@'3']=HEX_DIGIT;
cat_code[@'4']=HEX_DIGIT;
cat_code[@'5']=HEX_DIGIT;
cat_code[@'6']=HEX_DIGIT;
cat_code[@'7']=HEX_DIGIT;
cat_code[@'8']=HEX_DIGIT;
cat_code[@'9']=HEX_DIGIT;
cat_code[@'a']=HEX_DIGIT;
cat_code[@'b']=HEX_DIGIT;
cat_code[@'c']=HEX_DIGIT;
cat_code[@'d']=HEX_DIGIT;
cat_code[@'e']=HEX_DIGIT;
cat_code[@'f']=HEX_DIGIT;
cat_code[@'A']=HEX_DIGIT;
cat_code[@'B']=HEX_DIGIT;
cat_code[@'C']=HEX_DIGIT;
cat_code[@'D']=HEX_DIGIT;
cat_code[@'E']=HEX_DIGIT;
cat_code[@'F']=HEX_DIGIT;
@ @d OUT_BUFFER_LENGTH 4096
@<Global vari...@>=
char* outfilename;
unsigned char out_buffer[OUT_BUFFER_LENGTH];
@ @<Initialize the...@>=
fil.fd = open(outfilename,O_WRONLY|O_CREAT|O_TRUNC,S_IRUSR|S_IWUSR|S_IRGRP|
    S_IWGRP|S_IROTH|S_IWOTH);
if(fil.fd < 0) {
    fprintf(stderr,"Could not open %s.\n",outfilename);
    _exit(-7);
}
if(fstat(fil.fd,&out_stat_buf)) {
    fprintf(stderr,"Could not stat %s.\n",outfilename);
    _exit(-15);
}
if(out_stat_buf.st_blksize > OUT_BUFFER_LENGTH) {
    fil.length = OUT_BUFFER_LENGTH; 
    fprintf(stderr,"The block size for the output is %d.\n",
        (int)out_stat_buf.st_blksize);
}@+else 
    fil.length = OUT_BUFFER_LENGTH -
        (OUT_BUFFER_LENGTH % out_stat_buf.st_blksize);
fil.offset = 0;
fil.buffer = out_buffer;
@ @<Clean up...@>=
flush_out(&fil);
if(fil.fd >= 0) close(fil.fd);
fil.fd = -1;
@ @<Global func...@>=
static int bswap(int p)
{
    int result;
    asm @[volatile ("bswap %1": "=r" (result) : "0" (p))@];
    return result;
}
@ @<Global func...@>=
void int_to_dvi_pointer(int p,char* b)
{
    int ii;
    p = bswap(p);
    for(ii=0;ii<4;++ii) {
        b[ii] = (char)(p & 0xff); 
        p >>= 8;
    }
}

@ @<Global func...@>=
void short_to_dvi_pointer(int p,char* b)
{
    b[0]=(char)((p >> 8)&0xff);
    b[1]=(char)(p & 0xff);
}
@ @<Header inclusions@>=
#include <sys/types.h>
#include <sys/stat.h>
#include <unistd.h>
#include <fcntl.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
