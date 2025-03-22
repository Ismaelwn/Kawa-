
(* The type of tokens. *)

type token = 
  | WHILE
  | VAR
  | TVOID
  | TINT
  | TBOOL
  | SEMI
  | RPAR
  | RETURN
  | REM
  | PRINT
  | POINT
  | OR
  | OPP
  | NOT
  | NEW
  | NEQS
  | NEQ
  | MUL
  | METHOD
  | MAIN
  | LT
  | LPAR
  | LE
  | INT of (int)
  | INSTANCEOF
  | IF
  | IDENT of (string)
  | GT
  | GE
  | EXTENDS
  | EQS
  | EQ
  | EOF
  | END
  | ELSE
  | DIV
  | COMA
  | CLASS
  | BEGIN
  | ATTRIBUTE
  | AND
  | AFFECT
  | ADD

(* This exception is raised by the monolithic API functions. *)

exception Error

(* The monolithic API. *)

val program: (Lexing.lexbuf -> token) -> Lexing.lexbuf -> (Kawa.program)
