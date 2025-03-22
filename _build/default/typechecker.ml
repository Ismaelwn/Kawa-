open Kawa

exception Error of string
let error s = raise (Error s)
let type_error ty_actual ty_expected =
  error (Printf.sprintf "expected %s, got %s"
           (typ_to_string ty_expected) (typ_to_string ty_actual))

module Env = Map.Make(String)
type tenv = typ Env.t

let add_env l tenv =
  List.fold_left (fun env (x, t) -> Env.add x t env) tenv l

let typecheck_prog p =
  let actual_class = ref "main" in
  let actual_method = ref "main" in
  (*let () = Fonctions.print_classes p  in*)
  let levenshtein s t =
    (*Algorithm de levenshtein en algorithmique dynamique, calcule en O(|s| |t|)
      utilisé dans l'extension de correction 'Did you mean recursion?'
    *)
    let m = String.length s in
    let n = String.length t in

    let d = Array.make_matrix (m + 1) (n + 1) 0 in

    for i = 1 to m do
      d.(i).(0) <- i
    done;

    for j = 1 to n do
      d.(0).(j) <- j
    done;

    for i = 1 to m do
      for j = 1 to n do
        let substitution_cost = if s.[i - 1] = t.[j - 1] then 0 else 1 in
        d.(i).(j) <- min (min (d.(i - 1).(j) + 1)
                          (d.(i).(j - 1) + 1)) 
                          (d.(i - 1).(j - 1) + substitution_cost)
      done
    done;

    d.(m).(n)
  in
  (*Trouve la classe de nom [cname] parmi les classes de [p] et lève une exception sinon*)
  let find_class cname =
    match List.find_opt (fun cdef -> cdef.class_name = cname) p.classes with
    | Some v -> v
    | None -> failwith (Printf.sprintf"La classe %s est inexsistante" cname)
  in

    (*Trouve la méthode de nom [name] de la classe [cl] et lève une exception sinon*)
    let find_meth name cl =
      let plusproche_meth = ref (3,"") in
      match List.find_opt (fun cmet -> 
          let lev = levenshtein name cmet.method_name in
          let min, meth_name = !plusproche_meth in
          if lev < min then plusproche_meth := (lev, cmet.method_name);
          cmet.method_name = name
        ) 
          cl.methods with
      | Some v -> v
      | None ->  let _,n = !plusproche_meth in
      if  n <> "" then error("did u mean " ^ n ) 
      else failwith (Printf.sprintf "La methode %s est inexistante pour la classe %s" name cl.class_name)
    in
  (*Trouve l'argument de nom [s] de la classe [c] et lève une exception sinon*)
  let find_arg s cl =
    match List.find_opt (fun (aname,_) -> aname = s) cl.attributes with 
    | Some v -> v     
    | None -> failwith (Printf.sprintf "Attribut %s inexistant pour la classe %s" s cl.class_name)      
    in
  (*Regarde si la classe c1 est une classe fille de la classe c2*)
  let check_subclass c1 c2 =
    let rec check_class_loop cl =
      if cl.class_name <> c2.class_name then 
        match cl.parent with
        | None -> let errorMessage = "La classe " ^ cl.class_name ^ " n'est pas une sous-classe de " ^ c2.class_name in
        failwith errorMessage
        | Some parent_class -> check_class_loop (find_class parent_class)
      in
    check_class_loop c1
  in

   (*Regarde si le type c1 est un sous-type du type c2*)
   let check_subtype t1 t2 =
    if t1 <> t2 then
      match t1, t2 with
      | TClass(s1), TClass(s2) -> let c1 = find_class s1 in
                                  let c2 = find_class s2 in
                                  check_subclass c1 c2
      | _ -> failwith("Les 2 types sont differents")
  in

  let tenv = add_env p.globals Env.empty in

  let rec check e typ tenv =
    let typ_e = type_expr e tenv in
    if typ_e <> typ then type_error typ_e typ

  and type_expr e tenv = match e with
    | Int _  -> TInt
    | Bool _ -> TBool
    | Binop(Add,e1,e2) ->
      let () = check e1 TInt tenv in
      let () = check e2 TInt tenv in
      TInt
    | Binop(Sub,e1,e2) ->
      let () = check e1 TInt tenv in
      let () = check e2 TInt tenv in
      TInt
    | Binop(Mul,e1,e2) ->
      let () = check e1 TInt tenv in
      let () = check e2 TInt tenv in
      TInt
    | Binop(Div,e1,e2) ->
      let () = check e1 TInt tenv in
      let () = check e2 TInt tenv in
      TInt
    | Binop(Rem,e1,e2) ->
      let () = check e1 TInt tenv in
      let () = check e2 TInt tenv in
      TInt
    | Binop(Lt,e1,e2) ->
      let () = check e1 TInt tenv in
      let () = check e2 TInt tenv in
      TBool
    | Binop(Le,e1,e2) ->
      let () = check e1 TInt tenv in
      let () = check e2 TInt tenv in
      TBool
    | Binop(Gt,e1,e2) ->
        let () = check e1 TInt tenv in
        let () = check e2 TInt tenv in
        TBool
    | Binop(Ge,e1,e2) ->
        let () = check e1 TInt tenv in
        let () = check e2 TInt tenv in
        TBool

    | Binop(Eq,e1,e2) ->
          let t1 = type_expr e1 tenv in
          let t2 = type_expr e2 tenv in
          if t1 = t2 then
            TBool
          else
            failwith("Les deux expressions ne sont pas du meme type")
    | Binop(Neq,e1,e2) ->
          let t1 = type_expr e1 tenv in
          let t2 = type_expr e2 tenv in
          if t1 = t2 then
            TBool
          else
            failwith("Les deux expressions ne sont pas du meme type")
	 	
	 | Binop(Eqs,e1,e2) ->
      let t1 = type_expr e1 tenv in
      let t2 = type_expr e2 tenv in
      if t1 = t2 then
        TBool
      else
        failwith("Les deux expressions ne sont pas du meme type")
    | Binop(Neqs,e1,e2) ->
        let t1 = type_expr e1 tenv in
        let t2 = type_expr e2 tenv in
        if t1 = t2 then
          TBool
        else
          failwith("Les deux expressions ne sont pas du meme type") 
		  
    | Unop(Not,e) ->
      let () = check e TBool tenv in
      TBool
    | Unop(Opp,e) ->
        let () = check e TInt tenv in
        TInt
    | This -> ( match Env.find_opt "this" tenv with
      | Some v -> v
      | None -> failwith "Impossible de trouver le parametre implicite 'this'"
      )
    | InstanceOf(e, t) -> (
        let type_e = type_expr e tenv in
        match type_e with
                      | TClass _ -> TBool
                      | _ -> failwith "InstanceOf ne peut qu'etre utilise avec des classes."
        )
    | Get(e) -> type_mem_access e tenv
    | New(id) ->
      let _ = find_class id in
      TClass(id)

    | NewCstr(id, l) ->
      let c = find_class id in
      let constr = find_meth "constructor" c in
      let t_ret = if (constr.return = TVoid) then true else false in
      let typ_params = List.map (fun (x, y) -> y) constr.params in
      let typ_l = List.map (fun x -> type_expr x tenv) l in
      let () = List.iter2 (fun x y -> check_subtype x y) typ_l typ_params in
      if t_ret then
        TClass(id)
      else 
        failwith("Les types attendus du constructeur ne coincident pas avec les types donnees en argument ou le type de retour de la fonction n'est pas TVoid")

    | MethCall (e, id, l) ->
      let t0 = type_expr e tenv in
      match t0 with
      | TClass cname ->
          let c = find_class cname in
          
          let method_ = find_meth id c in
         
          let t = method_.return in
          let typ_params = List.map (fun (_, typ) -> typ) method_.params in
          let typ_l = List.map (fun x -> type_expr x tenv) l in
  
          (* Vérifie si les types des arguments correspondent aux paramètres *)
          if List.length typ_params <> List.length typ_l then
            failwith (Printf.sprintf "Nombre d'arguments incorrect pour la méthode %s" id);
  
          (* Vérification des sous-types entre arguments et paramètres *)
          (try
              List.iter2 (fun expected given -> check_subtype given expected) typ_l typ_params;
              t
            with
            | _ ->
                failwith
                  (Printf.sprintf
                    "Les types des arguments pour la méthode %s ne correspondent pas aux types attendus"
                    id))
    | _ -> failwith "case not implemented in type_expr"

  and type_mem_access m tenv = match m with
    | Var s ->  ( try
                  let var = Env.find s tenv in var
                with
                  | Not_found -> failwith (Printf.sprintf "La variable %s est inexistante dans l'environnement" s)                 
    )
    | Field (e,s) ->
      let t = type_expr e tenv in
       match t with
       
       | TClass n -> let c = find_class n in
                     ( match (find_arg s c) with
                     | (_,t) -> t
                                     
           )
       | _ -> failwith "[e] n'est pas de type TClass" 
    | _ -> failwith "case not implemented in type_mem_access"
  in

  let rec check_instr i ret tenv = match i with
    | Print e -> check e TInt tenv
    | Set (m,e) -> ( match m with 
                    | Field (e,s) ->  let t = type_expr e tenv in 
                                  ( match t with
                                  | TClass n -> let c = find_class n in
                                            ( match (find_arg s c) with
                                            | (_,_) -> ()
                                            | (s,_) -> if !actual_method <> "constructor" || !actual_class <> n then
                                                        let error_message = ( Printf.sprintf "L'attribut %s ne peut pas etre modifie dans %s.%s"
                                                                  s !actual_class !actual_method) in
                                                        failwith(error_message)
                                            )
                                  | _ -> failwith "[e] n'est pas de type TClass" 
                                  ) 
                    | _ -> () 
                    );
                    let tG = type_mem_access m tenv in
                    let tD = type_expr e tenv in
                    check_subtype tD tG
    
    | Expr e -> check e TVoid tenv 
    | If (e,l_if,l_else) ->
      check e TBool tenv;
      check_seq l_if ret tenv;
      check_seq l_else ret tenv
    | While (e,l) ->
      check e TBool tenv;
      check_seq l ret tenv
    | Return (e) -> check e ret tenv
    | _ -> failwith "case not implemented in check_instr"
  and check_seq s ret tenv =
    List.iter (fun i -> check_instr i ret tenv) s
  in

  check_seq p.main TVoid tenv
