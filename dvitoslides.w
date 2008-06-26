@**Introduction. This program is called \.{DVITOSLIDES}. It processes a \.{DVI}
file and uses \.{\string\special} commands to create a slide show.
@c
@<Header inclusions@>@;
@h
@<Enumerated types@>@;
@<Global structure definitions@>@;
@<Global variable declarations@>@;
@<Global function declarations@>@;
@*2The main routine. This defines the |main| routine.
@c int main(int argc,char* argv[])
{
    @<|main| local variables@>@;
    @<Parse the command line@>@;
    @<Read in the \.{DVI} source file@>@;
    @<Read in the \.{TFM} database@>@;
    @<Open the output files@>@;
    @<The big processing loop@>@;
    @<Clean up after ourselves@>@;
    return 0;
}
@
@s dvi_code int
@<|main| local variables@>=
int ii;
unsigned char* dvi_buf;
int len;
unsigned char* curr;
unsigned char* end;
unsigned char* tfm_buf;
unsigned char* tfm_buf_end;
unsigned char* p;
char*pp,*qq;
dvi_code op;
@ @<|main| local variables@>=
unsigned char temp_buf[4];
unsigned char ch;
struct defined_font* current_font=0;
unsigned int temp;
unsigned char* data;
int k,a,l;
int width;
int temp_bop;
int level;
int just_dump_font_information=0;
@ @<|main| local variables@>=
struct defined_font* new_font;
struct defined_font* fnt_nxt;
int eliminate_start, eliminate_end;
int eliminate_stack = -1, eliminate_stack_level = 0;
const char* end_start;
int replacement_no,replace_len;
char* replace_start;
@ @<Global vari...@>=
FILE* out_dvi;
@ @<Open the output fi...@>=
out_dvi = fopen(output_file_name,"w");
if(!out_dvi){
    fprintf(stderr,"Could not open %s.\n",output_file_name);
    fflush(stderr);
    _exit(1);
}
@ @<Clean up...@>=
fclose(out_dvi);
out_dvi = ((FILE*)0);
@ @<Read in the \.{D...@>=
dvi_buf=read_file(input_file_name,&len);
if(!dvi_buf){
    fprintf(stderr,"Was not able to read %s.\n",input_file_name);
    fflush(stderr);
    _exit(1);
}
curr = dvi_buf;
end = &dvi_buf[len];
@ @<Clean up...@>=
free(dvi_buf);
@ @<Read in the \.{T...@>=
tfm_buf = (char*)read_file(tfm_db_file_name,&len);
if(!tfm_buf){
    fprintf(stderr,"Could not read file %s.\n",tfm_db_file_name);
    fflush(stderr);
    _exit(1);
}
tfm_buf_end = &tfm_buf[len];
for(num_lines=0,p=tfm_buf;p<tfm_buf_end;++p)
    if(*p == '\n')
        ++num_lines;
@ @<Global struc...@>=
struct tfm_db {
    char* tex_name;
    char* file_name;
};
@ @<Read in the \.{T...@>=
tfm_database = (struct tfm_db*)malloc(num_lines * sizeof(struct tfm_db)); 
for(p=tfm_buf,ii=0;ii<num_lines;++ii) {
   tfm_database[ii].tex_name = p;
   while(*p != ':')
       ++p; 
   *p = '\0';
   ++p;
   tfm_database[ii].file_name = p;
   while(*p != '\n')
       ++p;
    *p = '\0';
    ++p;
#if 0
    fprintf(stderr,"Assigned %s : %s\n",tfm_database[ii].tex_name,tfm_database[ii].file_name);
#endif
}
@ @<Global vari...@>=
struct tfm_db* tfm_database;
int num_lines;
@ The command line looks like this:
$$\hbox{\tt dvitoslides -i $\langle${\rm input}$\rangle$ -t $\langle${\rm
tfm}$\rangle$ -o $\langle${\rm output}$\rangle$}$$
@d NULL_NAME ((char*)0)
@<Parse the command line@>=
input_file_name = tfm_db_file_name = output_file_name = NULL_NAME;
for(ii=1;ii<argc;++ii) {
    if(strcmp("-i",argv[ii])==0) {
        ++ii;
        input_file_name = argv[ii]; 
    }@+else if(strcmp("-t",argv[ii])==0) {
        ++ii;
        tfm_db_file_name = argv[ii]; 
    }@+else if(strcmp("-o",argv[ii])==0) {
        ++ii;
        output_file_name = argv[ii];
    }@+else if(strcmp("-h",argv[ii])==0) {
        @<Print a usage...@>@;
        fflush(stderr);
        _exit(1);
    }
}
@ @<Global vari...@>=
char* input_file_name;
char* tfm_db_file_name;
char* output_file_name;
@ @<Header incl...@>=
#include <string.h>
#include <stdio.h>
#include <unistd.h>
#include <stdlib.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
@ @<Parse the comm...@>=
if(input_file_name == NULL_NAME ||
   tfm_db_file_name == NULL_NAME ||
   output_file_name == NULL_NAME) {
    @<Print a usage statement@>@;
    if(input_file_name == NULL_NAME)
        fprintf(stderr,"You did not define the input.\n"); 
    if(tfm_db_file_name == NULL_NAME)
        fprintf(stderr,"You did not define the tfm database.\n"); 
    if(output_file_name == NULL_NAME)
        fprintf(stderr,"You did not define the output.\n"); 
    fflush(stderr);
    _exit(1);
}
@ @<Print a us...@>=
fprintf(stderr,"Usage: %s <-i input> <-t tfm> <-o output> [-h]\n",argv[0]);
@**Define the opcodes. We copy the opcodes from the {\TeX} documentation.
@ @<Enumerated types@>=
typedef enum {
@!set_char_0 = 0, @!set_char_1, @!set_char_2, @!set_char_3,
@!set_char_4, @!set_char_5, @!set_char_6, @!set_char_7,
    @!set_char_8, @!set_char_9, @!set_char_10, @!set_char_11,
    @!set_char_12, @!set_char_13, @!set_char_14, @!set_char_15,
    @!set_char_16, @!set_char_17, @!set_char_18, @!set_char_19,
    @!set_char_20, @!set_char_21, @!set_char_22, @!set_char_23,
    @!set_char_24, @!set_char_25, @!set_char_26, @!set_char_27,
    @!set_char_28, @!set_char_29, @!set_char_30, @!set_char_31,
    @!set_char_32, @!set_char_33, @!set_char_34, @!set_char_35,
    @!set_char_36, @!set_char_37, @!set_char_38, @!set_char_39,
    @!set_char_40, @!set_char_41, @!set_char_42, @!set_char_43,
    @!set_char_44, @!set_char_45, @!set_char_46, @!set_char_47,
    @!set_char_48, @!set_char_49, @!set_char_50, @!set_char_51,
    @!set_char_52, @!set_char_53, @!set_char_54, @!set_char_55,
    @!set_char_56, @!set_char_57, @!set_char_58, @!set_char_59,
    @!set_char_60, @!set_char_61, @!set_char_62, @!set_char_63,
    @!set_char_64, @!set_char_65, @!set_char_66, @!set_char_67,
    @!set_char_68, @!set_char_69, @!set_char_70, @!set_char_71,
    @!set_char_72, @!set_char_73, @!set_char_74, @!set_char_75,
    @!set_char_76, @!set_char_77, @!set_char_78, @!set_char_79,
    @!set_char_80, @!set_char_81, @!set_char_82, @!set_char_83,
    @!set_char_84, @!set_char_85, @!set_char_86, @!set_char_87,
    @!set_char_88, @!set_char_89, @!set_char_90, @!set_char_91,
    @!set_char_92, @!set_char_93, @!set_char_94, @!set_char_95,
    @!set_char_96, @!set_char_97, @!set_char_98, @!set_char_99,
    @!set_char_100, @!set_char_101, @!set_char_102, @!set_char_103,
    @!set_char_104, @!set_char_105, @!set_char_106, @!set_char_107,
    @!set_char_108, @!set_char_109, @!set_char_110, @!set_char_111,
    @!set_char_112, @!set_char_113, @!set_char_114, @!set_char_115,
    @!set_char_116, @!set_char_117, @!set_char_118, @!set_char_119,
    @!set_char_120, @!set_char_121, @!set_char_122, @!set_char_123,
    @!set_char_124, @!set_char_125, @!set_char_126, @!set_char_127,
    @!set1, @!set2, @!set3, @!set4, @!set_rule,
    @!put1, @!put2, @!put3, @!put4, @!put_rule,
    @!nop, @!bop, @!eop,
    @!push, @!pop,
    @!right1, @!right2, @!right3, @!right4,
    @!w0, @!w1, @!w2, @!w3, @!w4,
    @!x0, @!x1, @!x2, @!x3, @!x4,
    @!down1, @!down2, @!down3, @!down4,
    @!y0, @!y1, @!y2, @!y3, @!y4,
    @!z0, @!z1, @!z2, @!z3, @!z4,
    @!fnt_num_0, @!fnt_num_1, @!fnt_num_2, @!fnt_num_3,
    @!fnt_num_4, @!fnt_num_5, @!fnt_num_6, @!fnt_num_7,
    @!fnt_num_8, @!fnt_num_9, @!fnt_num_10, @!fnt_num_11,
    @!fnt_num_12, @!fnt_num_13, @!fnt_num_14, @!fnt_num_15,
    @!fnt_num_16, @!fnt_num_17, @!fnt_num_18, @!fnt_num_19,
    @!fnt_num_20, @!fnt_num_21, @!fnt_num_22, @!fnt_num_23,
    @!fnt_num_24, @!fnt_num_25, @!fnt_num_26, @!fnt_num_27,
    @!fnt_num_28, @!fnt_num_29, @!fnt_num_30, @!fnt_num_31,
    @!fnt_num_32, @!fnt_num_33, @!fnt_num_34, @!fnt_num_35,
    @!fnt_num_36, @!fnt_num_37, @!fnt_num_38, @!fnt_num_39,
    @!fnt_num_40, @!fnt_num_41, @!fnt_num_42, @!fnt_num_43,
    @!fnt_num_44, @!fnt_num_45, @!fnt_num_46, @!fnt_num_47,
    @!fnt_num_48, @!fnt_num_49, @!fnt_num_50, @!fnt_num_51,
    @!fnt_num_52, @!fnt_num_53, @!fnt_num_54, @!fnt_num_55,
    @!fnt_num_56, @!fnt_num_57, @!fnt_num_58, @!fnt_num_59,
    @!fnt_num_60, @!fnt_num_61, @!fnt_num_62, @!fnt_num_63,
    @!fnt1, @!fnt2, @!fnt3, @!fnt4,
    @!xxx1, @!xxx2, @!xxx3, @!xxx4,
    @!fnt_def1, @!fnt_def2, @!fnt_def3, @!fnt_def4,
    @!pre, @!post, @!post_post 
} dvi_code;
@ @<Global func...@>=
char* opcode_to_string(dvi_code);
@ @c char* opcode_to_string(dvi_code c)
{
    int idx = (int)c;
    static char* op_strings[] = @[@<Define the translation table@>@];
    return op_strings[idx];
}
@ @<Define the trans...@>={
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
@**The big processing loop. The idea is that we read in a \.{DVI} command.  In
any case, we must process it in order to extract the information about how it
affects the \.{DVI} parameters.  If we are {\it skipping} over the text, then
all we do is note the effect the \.{DVI} command has on the \.{DVI} parameters.
If we are not {\it skipping}, then we need to write out the \.{DVI} data to the
new \.{DVI} file.
@<The big processing loop@>=
while(curr<end){
#if 0
    fprintf(stderr,"Now at offset %d. ",curr-dvi_buf);
    fprintf(stderr,"curr is %02x.\n",*curr);
#endif
    op = (dvi_code)*curr;
    if(op>= set_char_0 &&op<= set_char_127)
        @<Handle typesetting a character@>@;
    else if(op>= set1 &&op< set_rule)
        @<Handle typesetting a high character@>@;
    else if(op== set_rule)
        @<Typeset a rule@>@;
    else if(op>=put1 && op<put_rule)
        @<Put a character on the page@>@;
    else if(op == put_rule) 
        @<Put a rule on the page@>@;
    else if(op == nop) 
        @<Handle a \\{nop}@>@;
    else if(op == bop)
        @<Handle a \\{bop}@>@;
    else if(op == eop)
        @<Handle an \\{eop}@>@;
    else if(op == push)
        @<Save the current position@>@;
    else if(op == pop)
        @<Restore a previous position@>@;
    else if(op >= right1 && op < w0)
        @<Move right literally@>@;
    else if(op == w0)
        @<Move right by \\{w}@>@;
    else if(op >= w1 && op < x0)
        @<Move right and set \\{w}@>@; 
    else if(op == x0)
        @<Move right by \\{x}@>@;
    else if(op >= x1 && op < down1)
        @<Move right and set \\{x}@>@; 
    else if(op >= down1 && op < y0)
        @<Move down literally@>@;
    else if(op == y0)
        @<Move down by \\{y}@>@;
    else if(op >= y1 && op < z0)
        @<Move down and set \\{y}@>@; 
    else if(op == z0)
        @<Move down by \\{z}@>@;
    else if(op >= z1 && op < fnt_num_0)
        @<Move down and set \\{z}@>@; 
    else if(op >= fnt_num_0 && op < fnt1)   
        @<Set current font number@>@;
    else if(op >= fnt1 && op < xxx1)    
        @<Set current font multibyte number@>@;
    else if(op >= xxx1 && op < fnt_def1)
        @<Handle a \.{\string\special} command@>@;
    else if(op >= fnt_def1 && op < pre)
        @<Define a font@>@;
    else if(op == pre) 
        @<The preamble@>@;
    else if(op == post) 
        @<The |post|amble@>@;
    else if(op == post_post) 
        @<The |post_post|amble@>@;
    else @<This should never happen@>@;
}
@ @<This should never happen@>={
    fprintf(stderr,"Invalid opcode seen.\n");
    fflush(stderr);
    _exit(1);
}
@ This is used for writing out the new \.{DVI} file.
@<Global vari...@>=
int current_dvi_bop = -1;
@ This is only modified by the |write_dvi| function. It is 
read when we are writing out a |bop| command.
@<Global vari...@>=
int current_dvi_offset = 0;
int skipping = 0;
int eliminate = 0;
@ This is the command that we want to make sure works.
@<Handle typesetting a character@>=
if(skipping || eliminate)
    @<Insert a |right| command@>@;
else {
    write_dvi(curr,1,out_dvi);
    ++curr;
}
@ @<Insert a |righ...@>={
    width=get_width(current_font,(unsigned int)op); 
    int_to_buf(temp_buf,width,&len);
    ch = (unsigned char)((int)right1-1);
    ch += len;
    write_dvi(&ch,1,out_dvi);
    for(ii=0;ii<len;++ii)
        write_dvi(&temp_buf[ii],1,out_dvi);
    ++curr;
}
@ @<Handle typesetting a high character@>=
if(skipping || eliminate)
    @<Insert a high |right| command@>@;
else {
    ii = (int)op-(int)set1;
    ++ii;
    while(ii>=0) {
        write_dvi(curr,1,out_dvi);
        ++curr;
        --ii;
    }
}
@ @<Insert a high |righ...@>={
    width=get_width(current_font,
        buf_to_unsigned_int(curr+1,(int)op-(int)set1+1)); 
    int_to_buf(temp_buf,width,&len);
    ch = (unsigned char)((int)right1-1);
    ch += len;
    write_dvi(&ch,1,out_dvi);
    for(ii=0;ii<len;++ii)
        write_dvi(&temp_buf[ii],1,out_dvi);
    curr += 2+(int)op-(int)set1;    
}
@ @<Typeset a rule@>=
if(skipping || eliminate)
    curr += 9;
else
    for(ii=0;ii<9;++ii) {
        write_dvi(curr,1,out_dvi);
        ++curr;
    }
@ @<Put a charac...@>={
len = (int)op + 2 - (int)put1;
if(skipping || eliminate)
    curr += len;
else
    for(ii=0;ii<len;++ii) {
        write_dvi(curr,1,out_dvi);
        ++curr;
    }
}
@ @<Put a rul...@>={
    if(skipping || eliminate) 
        curr += 9;
    else
        for(ii=0;ii<9;++ii) {
            write_dvi(curr,1,out_dvi);
            ++curr;
        }
}
@ @<Handle a \\{n...@>={
    write_dvi(curr,1,out_dvi);
    ++curr;
}
@ @<Save the current position@>={
    write_dvi(curr,1,out_dvi);
    ++curr;
}
@ @<Restore a previous position@>={
    write_dvi(curr,1,out_dvi);
    ++curr;
}
@ @<Move right literally@>={
    len = (int)op + 2 - (int)right1;
    write_dvi(curr,len,out_dvi);
    curr+=len;
}
@ @<Move right by \\{w}@>={
    write_dvi(curr,1,out_dvi);
    ++curr;
}
@ @<Move right and set \\{w}@>={
    len = (int)op - (int) w1 + 2;
    write_dvi(curr,len,out_dvi);
    curr += len;
}
@ @<Move right by \\{x}@>={
    write_dvi(curr,1,out_dvi);
    ++curr;
}
@ @<Move right and set \\{x}@>={
    len = (int)op - (int) x1 + 2;
    write_dvi(curr,len,out_dvi);
    curr += len;
}
@ @<Move down literally@>={
    len = (int)op + 2 - (int)down1;
    write_dvi(curr,len,out_dvi);
    curr+=len;
}
@ @<Move down by \\{y}@>={
    write_dvi(curr,1,out_dvi);
    ++curr;
}
@ @<Move down and set \\{y}@>={
    len = (int)op - (int) y1 + 2;
    write_dvi(curr,len,out_dvi);
    curr += len;
}
@ @<Move down by \\{z}@>={
    write_dvi(curr,1,out_dvi);
    ++curr;
}
@ @<Move down and set \\{z}@>={
    len = (int)op - (int) z1 + 2;
    write_dvi(curr,len,out_dvi);
    curr += len;
}
@ @<Global vari...@>=
int counters[10];
@ @<Handle a \\{b...@>={
    skipping = 0;
    eliminate =0;
    stack_level=0;
    stack_level_off = -1;
    eliminate_stack_level = 0;
    eliminate_stack = -1;
    temp_bop = current_dvi_offset;
    for(ii=0;ii<10;++ii)
        counters[ii] = buf_to_int(curr+1+4*ii,4);  
    for(ii=44;ii>40;--ii) {
        curr[ii] = current_dvi_bop & 0xff; 
        current_dvi_bop >>= 8;
    }
    current_dvi_bop = temp_bop;
    write_dvi(curr,45,out_dvi);
    curr += 45;
}
@ @<Handle an \\{e...@>={
    write_dvi(curr,1,out_dvi);
    ++curr;
}
@ @<The preamble@>={
    k = (int)buf_to_unsigned_int(&curr[14],1);
    k += 15;
    for(ii=0;ii<k;++ii){
        write_dvi(curr,1,out_dvi); 
        ++curr;
    }
}
@ @<The |post|amble@>={
    temp_bop = current_dvi_offset;
    for(ii=4;ii>0;--ii) {
        curr[ii] = current_dvi_bop & 0xff; 
        current_dvi_bop >>= 8;
    }
    current_dvi_bop = temp_bop;
    write_dvi(curr,29,out_dvi);
    curr += 29;
    just_dump_font_information = 1;
}
@ @<The |post_post|amble@>={
    temp_bop = current_dvi_offset;
    for(ii=4;ii>0;--ii) {
        curr[ii] = (unsigned char)(current_dvi_bop & 0xff); 
        current_dvi_bop >>= 8;
    }
    current_dvi_bop = temp_bop;
    write_dvi(curr,6,out_dvi);
    curr+=6;
    for(ii=0;ii<4;++ii)
        write_dvi(curr,1,out_dvi);
    if((ii=current_dvi_offset % 4))
        while(ii>0){
            write_dvi(curr,1,out_dvi);
            --ii;
        }
    curr = end;
}
@ @<Global func...@>=
void write_dvi(unsigned char*,int,FILE*);
@ @c
void write_dvi(unsigned char*p,int n,FILE*fp)
{
    fwrite(p,1,n,fp);
    current_dvi_offset += n;
}
@**Font management. We learn how to load fonts. The first item of 
business is to have a list on which we keep the list of loaded fonts.
@<Global struct...@>=
struct defined_font {
    struct defined_font* next;
    unsigned int num,lf,lh,bc,ec,nw;
    unsigned int nh,nd,ni,nl,nk,ne,np;
    unsigned int*header,*char_info,*lig_kern,*exten;
    int*width,*height,*depth,*italic,*kern,*param;
};
@ @<Define a font@>=
if(just_dump_font_information == 0) {
    k = (int)op-fnt_def1+1;
    a = (int)buf_to_unsigned_int(curr+13+k,1);
    l = (int)buf_to_unsigned_int(curr+14+k,1);
    for(ii=0;ii<a+l;++ii)
        font_name[ii] = *(curr+k+15+ii);
    font_name[ii] = '\0';
    new_font=read_font_file(get_hash((char*)font_name));
    new_font->next = fonts;
    fonts = new_font;
    new_font->num = buf_to_unsigned_int(curr+1,k);
    write_dvi(curr,15+k+a+l,out_dvi);
    curr += 15 + k + a + l;
}@+else @<Simply dump the font information.@>@;
@ @<Simply dump...@>={
    k = (int)op-(int)fnt_def1+1;
    a = (int)buf_to_unsigned_int(curr+1+k+12,1);
    l = (int)buf_to_unsigned_int(curr+1+k+13,1);
    write_dvi(curr,15+k+a+l,out_dvi);
    curr += 15+k+a+l;
}
@ @<Global vari...@>=
unsigned char font_name[512];
@ @<Global func...@>=
const char* get_hash(const char*);
@ @c
const char* get_hash(const char*name)
{
    int left, right, mid;
    left = 0;
    right = num_lines - 1;
    mid = (left+right)/2;
    while(left<=right) {
        mid = (left+right)/2;
        if(strcmp(tfm_database[mid].tex_name,name)>0)
            right = mid - 1;
        else if(strcmp(tfm_database[mid].tex_name,name)<0)
            left = mid + 1;
        else if(strcmp(tfm_database[mid].tex_name,name)==0)
            return tfm_database[mid].file_name;
    }
    fprintf(stderr,"Did not find %s.\n",name);
    fflush(stderr);
    _exit(1);
}
@ @<Set current font number@>={
    temp = (unsigned int)op - (unsigned int)fnt_num_0;
    for(current_font = fonts;current_font;current_font = current_font->next)
        if(current_font->num == temp)
            break; 
    if(!current_font){
        fprintf(stderr,"Font number %u undefined.\n",temp); 
        fprintf(stderr,"The byte was %d.\n",curr-dvi_buf); 
        fflush(stderr);
        _exit(2);
    }
    write_dvi(curr,1,out_dvi);
    ++curr;
}
@ @<Set current font multibyte number@>={
    temp = buf_to_unsigned_int(curr+1,1+(int)op - (int)fnt1);
    for(current_font = fonts;current_font;current_font = current_font->next)
        if(current_font->num == temp)
            break; 
    if(!current_font){
        fprintf(stderr,"Font number %u undefined.\n",temp); 
        fprintf(stderr,"The byte is %d.\n",curr-dvi_buf); 
        fflush(stderr);
        _exit(2);
    }
    write_dvi(curr,2+(int)op-(int)fnt1,out_dvi);
    curr += 2 + (int)op - (int)fnt1;
}
@ @<Global func...@>=
int get_width(struct defined_font*,unsigned int);
@ @c
int get_width(struct defined_font*p,unsigned int n)
{
    if(n<p->bc||n>p->ec)
        return 0;
    n -= p->bc;
    return p->width[(p->char_info[n]>>24)&0xff];
}
@ @<Global vari...@>=
struct defined_font*fonts=0;
@ @<Clean up...@>=
while(fonts){
    fnt_nxt = fonts->next;  
    clean_up_font(fonts);
    fonts = fnt_nxt;
}
@ @<Global func...@>=
void clean_up_font(struct defined_font*);
@ @c
void clean_up_font(struct defined_font*p)
{
    if(p) {
        free(p->header);
        free(p->char_info);
        free(p->width);
        free(p->height);
        free(p->depth);
        free(p->italic);
        free(p->lig_kern);
        free(p->kern);
        free(p->exten);
        free(p->param);
        free(p);
    }
}
@ We read in a font.
@<Global func...@>=
struct defined_font* read_font_file(const char*);
@ @c
struct defined_font* read_font_file(const char*name)
{
    int len;
    struct defined_font*ret;
    unsigned char* buf = read_file(name,&len);
    int offset;
    int ii;
    ret=(struct defined_font*)malloc(sizeof(struct defined_font)); 
    if(!ret){
        fprintf(stderr,"Could not allocate memory for a font buffer.\n");
        fflush(stderr);
        _exit(1);
    }
    @<Get the first parameters@>@;
    @<Read the spacing data@>@;
    free(buf);
    return ret;
}
@ @<Get the first param...@>=
ret->lf=buf_to_unsigned_int(&buf[0],2);
if(len != ret->lf * 4) {
    fprintf(stderr,"len = %d. ret->lf = %d.\n",len,ret->lf*4);
    fprintf(stderr,"This file might be corrupted.\n");
    fflush(stderr);
    _exit(1);
}
@ @<Get the first param...@>=
ret->lh=buf_to_unsigned_int(&buf[2],2);
@ @<Get the first param...@>=
ret->bc=buf_to_unsigned_int(&buf[4],2);
if(ret->bc > 256){
    fprintf(stderr,"ret->bc bigger than expected.\n");
    fprintf(stderr,"This file might be corrupted.\n");
    fflush(stderr);
    _exit(1);
}
@ @<Get the first param...@>=
ret->ec=buf_to_unsigned_int(&buf[6],2);
if(ret->ec + 1 < ret->bc){
    fprintf(stderr,"ret->ec = %d, ret->bc = %d.\n",ret->ec,ret->bc);
    fprintf(stderr,"ret->ec smaller than expected.\n");
    fprintf(stderr,"This file might be corrupted.\n");
    fflush(stderr);
    _exit(1);
}
@ @<Get the first param...@>=
ret->nw=buf_to_unsigned_int(&buf[8],2);
@ @<Get the first param...@>=
ret->nh=buf_to_unsigned_int(&buf[10],2);
@ @<Get the first param...@>=
ret->nd=buf_to_unsigned_int(&buf[12],2);
@ @<Get the first param...@>=
ret->ni=buf_to_unsigned_int(&buf[14],2);
@ @<Get the first param...@>=
ret->nl=buf_to_unsigned_int(&buf[16],2);
@ @<Get the first param...@>=
ret->nk=buf_to_unsigned_int(&buf[18],2);
@ @<Get the first param...@>=
ret->ne=buf_to_unsigned_int(&buf[20],2);
@ @<Get the first param...@>=
ret->np=buf_to_unsigned_int(&buf[22],2);
@ @<Get the first param...@>=
if(ret->lf+ret->bc!=6+ret->lh+ret->ec+1+ret->nw+ret->nh+ret->nd+
    ret->ni+ret->nl+ret->nk+ret->ne+ret->np){
    fprintf(stderr,"This file might be corrupted.\n");
    fflush(stderr);
    _exit(1);
}
@ @<Read the spacing data@>= 
offset = 24;
@<Read the |header| information@>@;
@<Read the |char_info| information@>@;
@<Read the |width| information@>@;
@<Read the |height| information@>@;
@<Read the |depth| information@>@;
@<Read the |italic| information@>@;
@<Read the |lig_kern| information@>@;
@<Read the |kern| information@>@;
@<Read the |exten| information@>@;
@<Read the |param| information@>@;
@ @<Read the |header| information@>=
ret->header = (unsigned int*)malloc(sizeof(unsigned int)*ret->lh);
if(!ret->header){
    fprintf(stderr,"Could not get header information about the font.\n");
    fflush(stderr);
    _exit(1);
}
for(ii=0;ii<ret->lh;++ii,offset += 4)
   ret->header[ii]=buf_to_unsigned_int(&buf[offset],4);
@ @<Read the |char_info| information@>=
ret->char_info =
    (unsigned int*)malloc(sizeof(unsigned int)*(ret->ec-ret->bc+1));
if(!ret->char_info){
    fprintf(stderr,"Could not get char_info information about the font.\n");
    fflush(stderr);
    _exit(1);
}
for(ii=0;ii<ret->ec-ret->bc+1;++ii,offset += 4)
   ret->char_info[ii]=buf_to_unsigned_int(&buf[offset],4);
@ @<Read the |width| information@>=
ret->width=(int*)malloc(sizeof(int)*ret->nw);
if(!ret->width){
    fprintf(stderr,"Could not get width information about the font.\n");
    fflush(stderr);
    _exit(1);
}
for(ii=0;ii<ret->nw;++ii,offset += 4)
   ret->width[ii]=buf_to_scaled_int(&buf[offset],ret->header[1]);
@ @<Read the |height| information@>=
ret->height=(int*)malloc(sizeof(int)*ret->nh);
if(!ret->height){
    fprintf(stderr,"Could not get height information about the font.\n");
    fflush(stderr);
    _exit(1);
}
for(ii=0;ii<ret->nh;++ii,offset += 4)
   ret->height[ii]=buf_to_int(&buf[offset],4);
@ @<Read the |depth| information@>=
ret->depth = (int*)malloc(sizeof(int)*ret->nd);
if(!ret->depth){
    fprintf(stderr,"Could not get depth information about the font.\n");
    fflush(stderr);
    _exit(1);
}
for(ii=0;ii<ret->nd;++ii,offset += 4)
   ret->depth[ii]=buf_to_int(&buf[offset],4);
@ @<Read the |italic| information@>=
ret->italic = (int*)malloc(sizeof(int)*ret->ni);
if(!ret->italic){
    fprintf(stderr,"Could not get italic information about the font.\n");
    fflush(stderr);
    _exit(1);
}
for(ii=0;ii<ret->ni;++ii,offset += 4)
   ret->italic[ii]=buf_to_int(&buf[offset],4);
@ @<Read the |lig_kern| information@>=
ret->lig_kern =
    (unsigned int*)malloc(sizeof(unsigned int)*ret->nl);
if(!ret->lig_kern){
    fprintf(stderr,"Could not get lig_kern information about the font.\n");
    fflush(stderr);
    _exit(1);
}
for(ii=0;ii<ret->nl;++ii,offset += 4)
   ret->lig_kern[ii]=buf_to_unsigned_int(&buf[offset],4);
@ @<Read the |kern| information@>=
ret->kern = (int*)malloc(sizeof(int)*ret->nk);
if(!ret->kern){
    fprintf(stderr,"Could not get kern information about the font.\n");
    fflush(stderr);
    _exit(1);
}
for(ii=0;ii<ret->nk;++ii,offset += 4)
   ret->kern[ii]=buf_to_int(&buf[offset],4);
@ @<Read the |exten| information@>=
ret->exten =
    (unsigned int*)malloc(sizeof(unsigned int)*ret->ne);
if(!ret->exten){
    fprintf(stderr,"Could not get exten information about the font.\n");
    fflush(stderr);
    _exit(1);
}
for(ii=0;ii<ret->ne;++ii,offset += 4)
   ret->exten[ii]=buf_to_unsigned_int(&buf[offset],4);
@ @<Read the |param| information@>=
ret->param = (int*)malloc(sizeof(int)*(ret->np+1));
if(!ret->param){
    fprintf(stderr,"Could not get param information about the font.\n");
    fflush(stderr);
    _exit(1);
}
for(ii=1;ii<=ret->np;++ii,offset += 4)
   ret->param[ii]=buf_to_int(&buf[offset],4);
@**The special commands for specials.  The register |stack_level| indicates
when we should turn back on.
@<Global vari...@>=
int stack_level=0;
int stack_level_off=0;
@ @<Handle a \.{\stri...@>={
    len = (int)buf_to_unsigned_int(curr+1,(int)op - (int)xxx1 + 1);
    data = curr + (int) op - (int) xxx1 + 2;
    k = len + (data - curr);
#if 0
    fprintf(stderr,"len = %d, k=%d",len,k);
#endif
    @<Turn stuff off@>@;	
    @<Turn stuff back on@>@;
    @<Restore back to default operation@>@;
    @<Eliminate text, selectively@>@;
    @<Stop eliminating stuff@>@;
    @<Set the replacement iterator by hand@>@;
    @<Replace a epsf counter@>@;
    else if(skipping==0 && eliminate==0)
        write_dvi(curr,k,out_dvi); 
    curr += k;
}
@ @<Turn stuff off@>=
if(matches(data,len,"panike off")){
    level=scan_for_integer(data,len,0);
    ++stack_level;
    if(skipping==0 && level>counters[1]){
        skipping=1;
        stack_level_off=stack_level-1;
    }
}
@ @<Turn stuff back on@>=
else if(matches(data,len,"panike on")){
    --stack_level;
    if(skipping==1 && stack_level_off==stack_level) {
        skipping=0;
        stack_level_off = -1;
    }
}
@ @<Restore back to default operation@>=
else if(matches(data,len,"panike restore")) {
        skipping = 0;
        eliminate = 0;
}
@ @<Eliminate text, selectively@>=
else if(matches(data,len,"panike eliminate")) {
    eliminate_start = scan_for_integer(data,len,&end_start);
    eliminate_end = scan_for_integer(end_start,
            len - ((unsigned char*)end_start - data),0);
    if(eliminate == 0 &&
            counters[1] >= eliminate_start &&
            counters[1] < eliminate_end) { 
        eliminate = 1;
        eliminate_stack = eliminate_stack_level;
    }
    ++eliminate_stack_level;
}
@ @<Stop eliminating stuff@>=
else if(matches(data,len,"panike stop")) { 
    --eliminate_stack_level;
    if(eliminate > 0 && eliminate_stack == eliminate_stack_level)
        eliminate = 0;
}
@ @<Set the replacement iterator by hand@>=
else if(matches(data,len,"startreplacement")){
    replacement_no = scan_for_integer(data,len,0); 
}
@ @<Replace a epsf counter@>=
else if(eliminate == 0 && skipping == 0 && matches(data,len,"replaceme")){
    replace_start=return_match(data,len,"replaceme"); 
    replace_len = sprintf(replace_start,"%d",replacement_no);
    ++replacement_no;
    pp=replace_start+replace_len;
    qq=replace_start+9;
    ii=((char*)replace_start-(char*)data)+9;
    while(ii<len){
        *pp=*qq;
        ++pp;
        ++qq;
        ++ii;
    }
    unsigned_int_to_buf(curr+1,len-(9-replace_len),&ii);  
    write_dvi(curr,k-(9-replace_len),out_dvi); 
}
@ @<Parse the comm...@>=
replacement_no=1;
@ @<Global func...@>=
int matches(const char*,int,const char*);
int scan_for_integer(const char*,int,const char**);
char* return_match(const char*data,int len,const char*s);
@ @c
int scan_for_integer(const char*p,int n,const char**pc)
{
    int ii;    
    int ret=0;
    for(ii=0;ii<n && (p[ii]<'0' || p[ii]>'9');++ii);
    while(ii<n && p[ii]>='0' && p[ii]<='9'){
        ret *= 10; 
        ret += p[ii] - '0';
        ++ii;
    }
    if(pc)
        *pc = &p[ii];
    return ret;
}
@ @c
int matches(const char*data,int len,const char*s)
{
    int ii,jj,kk;
    for(ii=0;ii<len;++ii){
        kk = 0;
        for(jj=ii;jj<len;++jj){
            if(s[kk] == '\0')
                return 1; 
            else if(data[jj] != s[kk]) 
                break;       
            ++kk;
        } 
        if(jj==len && s[kk] == '\0')
            return 1;
    }
    return 0;
}
@ @c
char* return_match(const char*data,int len,const char*s)
{
    int ii,jj,kk;
    for(ii=0;ii<len;++ii){
        kk = 0;
        for(jj=ii;jj<len;++jj){
            if(s[kk] == '\0')
                return (char*)&data[ii]; 
            else if(data[jj] != s[kk]) 
                break;       
            ++kk;
        } 
        if(jj==len && s[kk] == '\0')
            return (char*)&data[ii];
    }
    return (char*)0;
}
@**Boilerplate code for files. I expect that some of this code will be
specific to the operating system, since we are dealing directly with
files here.
@<Global func...@>=
unsigned char* read_file(const char*,int*);
@ @c
unsigned char* read_file(const char*name,int*len){
    unsigned char* buf;
    struct stat filstat;
    int fd;
    int ii;
    int num_read;
    @<Open the file@>@;
    @<Get the size of the file@>@;
    buf = (unsigned char*)malloc(sizeof(unsigned char)* *len);
    if(!buf) {
        fprintf(stderr,"Could not allocate memory for the file.\n"); 
        fflush(stderr);
        _exit(1);
    }
    @<Now read the file@>@;
    close(fd);
    return buf;
}
@ @<Now read the file@>=
    for(ii=0;ii<*len;ii+=num_read){
        num_read = read(fd,&buf[ii],*len-ii); 
        if(num_read<0){
            fprintf(stderr,"Error reading from %s.\n",name); 
            fflush(stderr);
            _exit(1);
        }@+else if(num_read == 0){
            *len = ii;
            break;
        }
    }
@ @<Open the file@>=
fd = open(name,O_RDONLY);
if(fd<0) {
    fprintf(stderr,"Error opening %s.\n",name); 
    fflush(stderr);
    _exit(1);
}
@ @<Get the size of the file@>=
if(fstat(fd,&filstat)) {
    fprintf(stderr,"Error stat-ting %s.\n",name); 
    fflush(stderr);
    _exit(1);
}
@ @<Get the size of the file@>=
if(len) 
    *len = filstat.st_size;
else {
    fprintf(stderr,"Null pointer!!!\n"); 
    fflush(stderr);
    _exit(1);
}

@**Utility functions. Some things have proved to be useful. The \.{DVI}
documentation makes a distinction between unsigned integers and signed
integers, so we need to emulate that in code.
@ @<Global func...@>=
int buf_to_int(unsigned char*,int);
unsigned int buf_to_unsigned_int(unsigned char*,int);
@ @c
int buf_to_int(unsigned char*p,int n)
{
    int ret=0;
    int ii;
    if(*p&0x80)
        ret=-1;
    for(ii=0;ii<n;++ii){
        ret <<= 8; 
        ret |= p[ii];
    }
    return ret;
}
@ @c
unsigned int buf_to_unsigned_int(unsigned char*p,int n)
{
    unsigned int ret = 0;
    int ii;
    for(ii=0;ii<n;++ii){
        ret <<= 8; 
        ret |= p[ii];
    }
    return ret;
}
@ @<Global func...@>=
void unsigned_int_to_buf(unsigned char*,unsigned int,int*);
void int_to_buf(unsigned char*,int,int*);
@ Some silly conversion functions.
@c void unsigned_int_to_buf(unsigned char*p,unsigned int n,int*len)
{
    int ii,jj;
    if(!len){
        fprintf(stderr,"len is null.\n"); 
        fflush(stderr);
        _exit(1);
    }
    if(n<0x100)
        *len=1;
    else if(n<0x10000)
        *len=2;
    else if(n<0x1000000)
        *len=3; 
    else
        *len=4; 
    for(jj=0,ii=*len - 1;ii>=0;jj+=8,--ii)
        p[ii]=(unsigned char)((n>>jj)&0xff);
}
@ @c void int_to_buf(unsigned char*p,int n,int*len)
{
    int ii,jj;
    if(!len){
        fprintf(stderr,"len is null.\n"); 
        fflush(stderr);
        _exit(1);
    }
    if(n>=-128 && n<=127)
        *len=1;
    else if(n>=-32768 && n<=32767)
        *len=2;
    else if(n>=-8388608 && n <= 8388607)
        *len=3; 
    else
        *len=4; 
    for(jj=0,ii=*len - 1;ii>=0;jj+=8,--ii)
        p[ii]=(unsigned char)((n>>jj)&0xff);
}
@ @<Global func...@>=
int buf_to_scaled_int(unsigned char*,int);
@ I got this function directly from the code for \TeX. See section 
572 in the \TeX{} web source.
@c int buf_to_scaled_int(unsigned char*p,int z)
{
    unsigned char a,b,c,d;
    int alpha,beta;
    int ret;
    a = p[0];@+b = p[1];@+c = p[2];@+d = p[3];
    alpha = 16;
    z >>=4;
    while(z > 0x800000){
        z /= 2;
        alpha *= 2;
    }
    beta = 256/alpha;@+alpha *= z; 
    ret = (d * z) / 0x100;@+ret += (c*z);@+ret /= 0x100;
    ret += b*z;@+ret /= beta;
    if(a == 0xff)
        ret -= alpha;
    return ret;
}
@**Index of symbols used. Is not \.{CWEB} cool?
