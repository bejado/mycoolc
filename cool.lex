/*
 * COOL scanner.
 */

%{
    // includes
%}

DIGIT   [0-9]
WORD    [a-zA-Z]
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

    /* Special ================================= */

(\{|\}|;|:|(<-)|\.|,|(=>)) {
    printf("found special notation: ");
    ECHO;
    printf("\n");
}

(\+|-|\*|\/) {
    printf("found math operator: ");
    ECHO;
    printf("\n");
}

(<|(<=)|=) {
    printf("found comparison operator: ");
    ECHO;
    printf("\n");
}

(\(|\)) {
    printf("found parenthesis: ");
    ECHO;
    printf("\n");
}

~ {
    printf("found not operator");
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

{DIGIT}+{WHITESPACE} {
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
<STRING_LITERAL>\n {
    printf("::ERROR:: unterminated string literal\n");
    BEGIN 0;
}
<STRING_LITERAL>([^"\n]*(\\.)?)* {
    printf("found string literal: ");
    char *literal = yytext;
    char *lookahead;
    char *copyHead;
    copyHead = literal;

    while (*copyHead) {
        if (*copyHead == '\\') {
            lookahead = copyHead + 1;
            switch (*lookahead) {
                case 'b': *lookahead = '\b'; break;
                case 't': *lookahead = '\t'; break;
                case 'n': *lookahead = '\n'; break;
                case 'f': *lookahead = '\f'; break;
            }
            copyHead++;
        }
        *literal = *copyHead;
        literal++;
        copyHead++;
    }
    while (literal != copyHead) {
        *literal = '\0';
        literal++;
    }
    ECHO;
    printf("\n");
}
\" BEGIN STRING_LITERAL;

    /* Whitespace =============================== */

{WHITESPACE}  /* ignore whitespace */

    /* Error handling =========================== */
. {
    printf("::ERROR::\n");
}

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
