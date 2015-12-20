/*
 *  The scanner definition for COOL.
 */

import java_cup.runtime.Symbol;

%%

%{

/*  Stuff enclosed in %{ %} is copied verbatim to the lexer class
 *  definition, all the extra variables/functions you want to use in the
 *  lexer actions should go here.  Don't remove or modify anything that
 *  was there initially.  */

    // Max size of string constants
    static int MAX_STR_CONST = 1025;

    // For assembling string constants
    StringBuffer string_buf = new StringBuffer();

    private int curr_lineno = 1;
    int get_curr_lineno() {
	return curr_lineno;
    }

    private AbstractSymbol filename;

    void set_filename(String fname) {
	filename = AbstractTable.stringtable.addString(fname);
    }

    AbstractSymbol curr_filename() {
	return filename;
    }
    
%}

	
%init{

/*  Stuff enclosed in %init{ %init} is copied verbatim to the lexer
 *  class constructor, all the extra initialization you want to do should
 *  go here.  Don't remove or modify anything that was there initially. */

    // empty for now
%init}

%eofval{

/*  Stuff enclosed in %eofval{ %eofval} specifies java code that is
 *  executed when end-of-file is reached.  If you use multiple lexical
 *  states and want to do something special if an EOF is encountered in
 *  one of those states, place your code in the switch statement.
 *  Ultimately, you should return the EOF symbol, or your lexer won't
 *  work.  */

    switch(yy_lexical_state) {
    case YYINITIAL:
	/* nothing special to do in the initial state */
	break;
	/* If necessary, add code for other states here, e.g:
	   case COMMENT:
	   ...
	   break;
	*/
    }
    return new Symbol(TokenConstants.EOF);
%eofval}

%class CoolLexer
%cup
%state COMMENT
%state STRING
LineTerminator = \r|\n|\r\n
WhiteSpace = {LineTerminator} | [ \t\f]
%%
<YYINITIAL>\"                   { yybegin(STRING); }
<YYINITIAL>{WhiteSpace}         {}
<YYINITIAL>"=>"			{ return new Symbol(TokenConstants.DARROW); }
<YYINITIAL>"(*"			{
                                    yybegin(COMMENT);
				}
<YYINITIAL>"class"              { 
                                    System.out.println("FOUND CLASS");
                                    return new Symbol(TokenConstants.CLASS); 
                                }
<COMMENT>"*)"                   { 
                                    System.out.println("END OF COMMENT");
                                    yybegin(YYINITIAL); }
<COMMENT>(.|\n)                 { /*System.out.println("Inside comment, matched: " + yytext());*/ }
<STRING>.                       { 
                                    System.out.println("APPENDING TO STRBUF: " + yytext());
                                    string_buf.append(yytext()); }
.                               { /* This rule should be the very last
                                     in your lexical specification and
                                     will match match everything not
                                     matched by other lexical rules. */
                                  System.err.println("LEXER BUG - UNMATCHED: " + yytext()); }

