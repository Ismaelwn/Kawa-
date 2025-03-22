%{

  open Lexing
  open Kawa

%}

%token <int> INT
%token <string> IDENT
%token MAIN

%token LPAR RPAR BEGIN END SEMI COMA

%token LT LE GT GE EQ NEQ EQS NEQS
%token AND OR NOT
%token ADD OPP MUL DIV REM

%token PRINT AFFECT IF ELSE WHILE RETURN

%token VAR 

%token CLASS ATTRIBUTE NEW POINT METHOD EXTENDS

%token TBOOL TVOID TINT

%token EOF

%token INSTANCEOF




%left EQ NEQ EQS NEQS
%left OR
%left AND
%left LT LE GT GE
%left ADD OPP
%left MUL DIV REM
%left NOT
%nonassoc UMINUS
%left POINT


%start program
%type <Kawa.program> program
%type <Kawa.instr> instruction
%%

mem:
| id = IDENT { Var(id) }
| e = expression POINT id = IDENT { Field(e,id) }
;

expression:
| n=INT { Int(n) }
| LPAR e=expression RPAR { e }

| exp1 = expression ADD exp2 = expression { Binop(Add, exp1, exp2) }
| exp1 = expression OPP exp2 = expression { Binop(Sub, exp1, exp2) }

| exp1 = expression MUL exp2 = expression { Binop(Mul, exp1, exp2) }
| exp1 = expression DIV exp2 = expression { Binop(Div, exp1, exp2) }


| exp1 = expression REM exp2 = expression { Binop(Rem, exp1, exp2) }
| exp1 = expression LT  exp2 = expression { Binop(Lt, exp1, exp2)  }
| exp1 = expression LE  exp2 = expression { Binop(Le, exp1, exp2)  }
| exp1 = expression GT  exp2 = expression { Binop(Gt, exp1, exp2)  }
| exp1 = expression GE  exp2 = expression { Binop(Ge, exp1, exp2)  }

| exp1 = expression EQ  exp2 = expression { Binop(Eq, exp1, exp2)  }
| exp1 = expression NEQ exp2 = expression { Binop(Neq, exp1, exp2) }

| exp1 = expression AND exp2 = expression { Binop(And, exp1, exp2) }
| exp1 = expression OR  exp2 = expression { Binop(Or, exp1, exp2)  }
| exp1=expression EQS exp2=expression { Binop(Eqs, exp1, exp2) }
| exp1=expression NEQS exp2=expression { Binop(Neqs, exp1, exp2) }

| OPP e=expression %prec UMINUS { Unop(Opp, e) }
| NOT e1=expression { Unop(Not, e1) }
| e=expression INSTANCEOF t=types  {InstanceOf(e,t)}

| e=mem { Get(e) }

| NEW id = IDENT {New(id)}
| NEW id = IDENT LPAR l=separated_list(COMA, expression) RPAR { NewCstr(id,l) }
| e=expression POINT id=IDENT LPAR l=separated_list(COMA, expression) RPAR { MethCall(e,id,l) }
;

instruction:
| WHILE LPAR e=expression RPAR BEGIN l=list(instruction) END { While(e,l) }
| RETURN e=expression SEMI { Return(e) }
| e = expression SEMI { Expr(e) }
| PRINT LPAR e=expression RPAR SEMI { Print(e) }
| m = mem AFFECT e=expression SEMI { Set(m,e) }
| IF LPAR e = expression RPAR BEGIN l_if=list(instruction) END ELSE BEGIN l_else=list(instruction) END { If(e,l_if,l_else) }
;

var_decl:
| VAR e=types s=separated_list(COMA,IDENT) SEMI { let rec comb s e = match s with
                                                    | [] -> []
                                                    | x :: s' -> (x, e) :: comb s' e
                                                  in
                                                comb s e
                                                }
;

param:
| e=types id=IDENT {id,e}
;

attr_decl:
| ATTRIBUTE e=types s=IDENT SEMI { (s,e)}
;

method_def:
| METHOD e=types id=IDENT LPAR l_args=separated_list(COMA,param) RPAR BEGIN l_varLocals=list(var_decl) l_instr=list(instruction) END 
     {{method_name=id ;
      code=l_instr ;
      params=l_args ;
      locals=List.concat l_varLocals ;
      return=e ;
      }}
;

class_def:
| CLASS name=IDENT BEGIN l1=list(attr_decl) l2=list(method_def)  END { { class_name = name;
                                                   attributes = l1;
                                                   methods = l2;
                                                   parent = None;
                                                   } }
| CLASS name=IDENT EXTENDS name_parent=IDENT BEGIN l1=list(attr_decl) l2=list(method_def) END { { class_name = name;
                                                                                        attributes = l1;
                                                                                        methods = l2;
                                                                                        parent = Some name_parent
                                                                                      } }
;

types:
| TINT { TInt }
| TBOOL { TBool }
| TVOID { TVoid }
| s=IDENT { TClass(s) }
;

program:
|  globals=list(var_decl) classes=list(class_def)   MAIN BEGIN main=list(instruction) END EOF
    { {classes = classes; globals = (List.concat globals) ; main} }
;



