@*Introduction. This program will take a text file that has been converted
to text by \.{DVITOTXT} and has source \TeX\ with certain specials, and 
convert the file to another text file suitable for processing with
\.{TXTTODVI} to convert it into a pile of slides.
@c
@<Header inclusions@>@;
@h
@<Global variables@>@;
@<Global function declarations@>@;
@ @c int main(int argc,char* argv[])
{
    char* infile;
    struct stat in_stat;
    unsigned char* in_buf;
    int infd,ii,num_read,outfd;
    unsigned char* p,*in_buf_end;
    int bop_line,eop_line,cut_here,jj;
    @<Parse the command line@>@;
    @<Read in the file@>@;
    @<Output the file@>@;
    @<Clean up after ourselves@>@;
    return 0;
}
@ @<Output the file@>=
@<Find all the lines@>@;
@<Open the output file@>@;
@<Write out the preamble@>@;
@<Write out the |fnt_def| definitions@>@;
@ The heart of the program.  We output page by page.  Some pages will 
be processed into slides.
@<Output the file@>=
for(ii=0;ii<num_lines;++ii)
    if(lines[ii][0] == '8' && lines[ii][1] == 'b') {
        bop_line = ii;
        eop_line = find_eop(ii+1); 
        if(eop_line == -1) {
            fprintf(stderr,"bop not followed by an eop at line %d!?",bop_line);
            _exit(-5);
        }
        while((cut_here = find_cut_here(bop_line,eop_line)) >= 0) {
            for(jj = bop_line;jj<cut_here;++jj)
                write_line(outfd,lines[jj]); 
            write_eop(outfd);
            drop_line(cut_here);
            --eop_line;
        }
        for(jj=bop_line;jj<=eop_line;++jj) write_line(outfd,lines[jj]);
        ii = eop_line;
    }@+else
        write_line(outfd,lines[ii]);
@ @<Global func...@>=
int find_eop(int start);
int find_cut_here(int start,int finish);
void write_line(const int outfd,const unsigned char* p);
void write_eop(const int outfd)
{
    write_line(outfd,"8c % eop");
}
void drop_line(int cut);
@ @c void drop_line(int cut)
{
    int ii;
    --num_lines;
    for(ii=cut;ii<num_lines;++ii) {
        lines[ii] = lines[ii+1]; 
    }
}
@ @c void write_line(const int outfd, const unsigned char* p)
{
    unsigned char ch = '\n';
    const unsigned char* s;
    int ii,num_written;
    for(s=p;*s;++s);
    for(ii=0;&p[ii]<s;ii+= num_written) {
        num_written = write(outfd,&p[ii],s-&p[ii]);
        if(num_written < 0) {
            fprintf(stderr,"Error writing to %s.\n",outfile); 
            return;
        }
        else if(num_written == 0) return;
    }
    write(outfd,&ch,1);
}
@ @c
int find_eop(int start)
{
    int ii;
    for(ii=start;ii<num_lines;++ii) 
        if(lines[ii][0] == '8' && lines[ii][1] == 'c')
              return ii;
   return -1; 
}
@
@d CUT_HERE_STRING "CUTHERE"
@c
int find_cut_here(int start,int finish)
{
    int ii;
    for(ii=start;ii<finish;++ii)
        if(((lines[ii][0] == 'e' && lines[ii][1] == 'f') ||
            (lines[ii][0] == 'f' && (lines[ii][1] == '0' ||
                                     lines[ii][1] == '1' ||
                                     lines[ii][1] == '2')))
               && matches(lines[ii],CUT_HERE_STRING))
            return ii; 
    return -1;
}
@ @<Global func...@>=
int matches(const unsigned char*,const unsigned char*);
@ @c
int matches(const unsigned char*s,const unsigned char*exp)
{
    const unsigned char* t,*r;
    while(*s != '\0') {
        if(*s == *exp) 
            for(t=s,r=exp;; ++t,++r) {
                if(*r == '\0') return 1; 
                if(*r != *t) break;
                if(*t == '\0') return 0;
            }
        ++s;
    }
    return 0;
}
@ @<Global vari...@>=
unsigned char** lines;
volatile int num_lines;
@ @<Write out the |fnt_...@>=
ii=0;
while(ii<num_lines)
    if(lines[ii][0] == 'f' && (
                    lines[ii][1] == '3' ||
                    lines[ii][1] == '4' ||
                    lines[ii][1] == '5' ||
                    lines[ii][1] == '6'
                )) {
        write_line(outfd,lines[ii]);
        drop_line(ii);
    } @+else ++ii;
@ @<Write out the pre...@>=
if(lines[0][0] != 'f' || lines[0][1] != '7') {
    fprintf(stderr,"No preamble?\n");
    @<Clean up...@>@;
}
write_line(outfd,lines[0]);
drop_line(0);
@ @<Open the output file@>=
outfd = open(outfile,O_WRONLY|O_CREAT,S_IRUSR|S_IWUSR|S_IRGRP|S_IWGRP|
        S_IROTH|S_IWOTH);
if(outfd < 0) {
    fprintf(stderr,"Could not open %s.\n",outfile);
    @<Clean up...@>@;
    _exit(-7);
}
@ @<Clean up...@>=
if(outfd >= 0) {
    close(outfd);
    outfd = -1;
}
@ @<Find all the lines@>=
for(p=in_buf,num_lines = 0;p<in_buf_end;++p)
    if(*p == '\n') ++num_lines;
lines = (unsigned char**)malloc(sizeof(char*)*num_lines);
if(!lines) {
    fprintf(stderr,"Cannot allocate memory for lines.\n");
    _exit(-6);
}
lines[0] = in_buf;
for(p=in_buf,ii=0;p<in_buf_end;++p)
    if(*p == '\n') {
        ++ii;
        lines[ii] = p+1; 
        *p = '\0';
    }
if(ii != num_lines) fprintf(stderr,"Achhh! %d\n",num_lines-ii);
@ @<Clean up...@>=
free(lines);
@ @<Read in the file@>=
if(stat(infile,&in_stat)) {
    fprintf(stderr,"Error stat-ting %s.\n",infile);
    _exit(-2);
}
in_buf = (unsigned char*)malloc(in_stat.st_size);
if(!in_buf) {
    fprintf(stderr,"Could not allocate memory to hold %s.\n",infile);
    _exit(-3);
}
infd = open(infile,O_RDONLY);
if(infd < 0) {
    fprintf(stderr,"Could not open %s.\n",infile);
    _exit(-3);
}
for(ii=0;ii<in_stat.st_size;ii+=num_read) {
    num_read = read(infd,&in_buf[ii],in_stat.st_size-ii);
    if(num_read == 0) break;
    else if(num_read < 0) {
        fprintf(stderr,"Error reading %s.\n",infile);
        free(in_buf);
        _exit(-4);
    }
}
in_buf_end = in_buf + ii;
close(infd); infd = -1;
@ @<Clean up...@>=
if(infd >= 0) {
    close(infd);
    infd = -1;
}
if(in_buf) free(in_buf);
@ @<Parse the command line@>=
if(argc<3) {
    fprintf(stderr,"Usage: %s <infile> <outfile>\n",argv[0]);
    _exit(-1);
}
infile = argv[1];
outfile = argv[2];
@ @<Global vari...@>=
char* outfile=0;
@ @<Header inclusions@>=
#include <sys/types.h>
#include <sys/stat.h>
#include <unistd.h>
#include <fcntl.h>
#include <stdio.h>
#include <stdlib.h>
