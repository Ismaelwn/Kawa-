{

  open Lexing
  open Kawaparser

  exception Error of string

  let keyword_or_ident =
  let h = Hashtbl.create 17 in
  List.iter (fun (s, k) -> Hashtbl.add h s k)
    [ "print",    PRINT;
      "main",     MAIN;
      "if",       IF;
      "else",     ELSE;
      "while",    WHILE;
      "return", RETURN;

      "var" ,     VAR;

      "int" ,   TINT;
      "bool" ,  TBOOL ;
      "void" ,  TVOID ;

      "class" , CLASS;
      "attribute" , ATTRIBUTE;
      "new" , NEW;
      "method", METHOD;
      "extends", EXTENDS;
      "instanceof" , INSTANCEOF ;

    ] ;
  fun s ->
    try  Hashtbl.find h s
    with Not_found -> IDENT(s)
        
}

let digit = ['0'-'9']
let number = ['-']? digit+
let alpha = ['a'-'z' 'A'-'Z']
let ident = ['a'-'z' '_'] (alpha | '_' | digit)*
  
rule token = parse
  | "//" [^ '\n']* "\n"  { new_line lexbuf; token lexbuf }
  | "/*"                 { comment lexbuf; token lexbuf }

  | "!"  {NOT}

  | "+"  {ADD}
  | "-"  {OPP}
  | "*"  {MUL}
  | "/"  {DIV}
  | "%"  {REM}
  | "<"  {LT}
  | "<=" {LE}
  | ">"  {GT}
  | ">=" {GE}

  | "===" { EQS }
  | "=/=" { NEQS }

  | "==" {EQ}
  | "!=" {NEQ}

  | "&&" {AND}
  | "||" {OR}

  | "=" { AFFECT }
  | "if" { IF }
  | "else" { ELSE }
  | "while" { WHILE }
  | "return" { RETURN }

  | "var" { VAR }
  | "int" { TINT }
  | "bool" { TBOOL }
  | "void" { TVOID }

  | "class" {CLASS}
  | "attribute" { ATTRIBUTE }
  | "new" { NEW }
  | "." { POINT }
  | "method" {METHOD}
  | "extends" { EXTENDS }
  | "instanceof" { INSTANCEOF }

  | ";"  { SEMI }
  | "("  { LPAR }
  | ")"  { RPAR }
  | "{"  { BEGIN }
  | "}"  { END }
  | "," { COMA }

  | number as n  { INT(int_of_string n) }
  | ident as id  { keyword_or_ident id }

  | ['\n']            { new_line lexbuf; token lexbuf }
  | [' ' '\t' '\r']+  { token lexbuf }

  | _    { raise (Error ("unknown character : " ^ lexeme lexbuf)) }
  | eof  { EOF }

and comment = parse
  | "*/" { () }
  | _    { comment lexbuf }
  | eof  { raise (Error "unterminated comment") }

