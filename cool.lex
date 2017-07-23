/*
 * COOL scanner.
 */

%{
    // includes
%}

DIGIT   [0-9]
WORD    [a-zA-Z]
MULTI_LINE_COMMENT_START  \(\*
MULTI_LINE_COMMENT_END    \*\)
WHITESPACE  [ \n\f\r\t\v]
IDENTIFIER  [a-zA-Z0-9_]

%START  STRING_LITERAL COMMENT MULTI_LINE_COMMENT

%%
    /* Keywords ================================= */

    /* keywords are case-insensitive... */
(?i:class|else|fi|if|in|inherits|isvoid|let|loop|pool|then|while|case|esac|new|of|not) {
    printf("keyword: ");
    ECHO;
    printf("\n");
}

    /* ...except true / false, whose first character must be lowercase */
t(?i:rue) {
    printf("true found\n");
}
f(?i:alse) {
    printf("false found\n");
}

    /* Integers ================================= */
{DIGIT}+ {
    printf("integer found: ");
    ECHO;
    printf("\n");
}

    /* Identifiers ============================== */
[a-z]+{IDENTIFIER}* {
    printf("identifier found: ");
    ECHO;
    printf("\n");
}

[A-Z]+{IDENTIFIER}* {
    printf("type identifier found: ");
    ECHO;
    printf("\n");
}

    /* Comments ================================= */

<COMMENT>\n {
    BEGIN 0;
}
<COMMENT>.* { /* ignore comment */ }
-- {
    BEGIN COMMENT;
}

<MULTI_LINE_COMMENT>"*)" BEGIN 0;
<MULTI_LINE_COMMENT>[^*]*           /* ignore characters except * */
<MULTI_LINE_COMMENT>"*"+[^)]*       /* ignore * not followed by ) */
"(*" BEGIN MULTI_LINE_COMMENT;

    /* String literals ========================== */

<STRING_LITERAL>\" BEGIN 0;
<STRING_LITERAL>[^"]* {
    printf("Found string literal: ");
    ECHO;
    printf("\n");
}
\" BEGIN STRING_LITERAL;

{WHITESPACE}  /* ignore whitespace */
%%

main( argc, argv )
int argc;
char **argv;
{
    ++argv, --argc;  /* skip over program name */
    if ( argc > 0 )
            yyin = fopen( argv[0], "r" );
    else
            yyin = stdin;

    yylex();
}
