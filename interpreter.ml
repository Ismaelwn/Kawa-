open Kawa

type value =
  | VInt  of int
  | VBool of bool
  | VObj  of obj
  | Null
and obj = {
  cls:    string;
  fields: (string, value) Hashtbl.t;
}

exception Error of string
exception Return of value

let exec_prog (p: program): unit =

  let locate_method (class_name:string) (method_name:string) =
    match List.find_opt (fun cls -> cls.class_name = class_name) p.classes with
    | Some cls ->
        ( try
          let found_method = List.find (fun m -> m.method_name = method_name) cls.methods in
          found_method
        with
          | Not_found -> failwith (Printf.sprintf "La méthode %s est inexistante pour la classe %s" method_name class_name)
       )
    | None -> let err_msg = Printf.sprintf "La classe %s est inexistante" class_name in
              failwith err_msg
  in

  let global_env = Hashtbl.create 16 in
  List.iter (fun (var, _) -> Hashtbl.add global_env var Null) p.globals;
  
  let rec eval_function func obj args =
    let local_env = Hashtbl.create 16 in
      Hashtbl.add local_env "this" obj;
      List.iter (fun (local_var,_) -> Hashtbl.add local_env local_var Null) func.locals;
      List.iter (fun ((param,_),arg_val) -> Hashtbl.add local_env param arg_val) (List.combine (func.params) args);
      process_seq (func.code) local_env;
      match Hashtbl.find_opt local_env "return" with
      | Some ret_val -> ret_val
      | None -> match func.method_name with
        | "constructor" -> obj
        | _ -> Null

  and process_seq instr_list local_env =
    let rec eval_to_int expr = match evaluate expr with
      | VInt num -> num
      | _ -> assert false
    and eval_to_bool expr = match evaluate expr with
      | VBool bool_val -> bool_val
      | _ -> assert false
    and eval_to_obj expr = match evaluate expr with
      | VObj obj_val -> obj_val
      | _ -> assert false
        
    and evaluate (expr: expr): value = match expr with
      | Int num  -> VInt num
      | Bool bool_val -> VBool bool_val
      | Binop(Add, lhs, rhs) -> VInt(eval_to_int lhs + eval_to_int rhs)
      | Binop(Sub, lhs, rhs) -> VInt(eval_to_int lhs - eval_to_int rhs)
      | Binop(Mul, lhs, rhs) -> VInt(eval_to_int lhs * eval_to_int rhs)
      | Binop(Div, lhs, rhs) -> VInt(eval_to_int lhs / eval_to_int rhs)
      | Binop (Rem,lhs,rhs) -> ( match eval_to_int rhs with
                            | 0 -> failwith("Division par zero impossible")
                            | divisor -> let remainder = eval_to_int lhs mod divisor in VInt remainder
                            )
      | Binop(Lt, lhs, rhs) -> VBool(eval_to_int lhs < eval_to_int rhs)
      | Binop(Le, lhs, rhs) -> VBool(eval_to_int lhs <= eval_to_int rhs)
      | Binop(Gt, lhs, rhs) -> VBool(eval_to_int lhs > eval_to_int rhs)
      | Binop(Ge, lhs, rhs) -> VBool(eval_to_int lhs >= eval_to_int rhs)

      | Binop(Eq, lhs, rhs) -> ( match (evaluate lhs, evaluate rhs) with 
                           | (VInt n, VInt m) -> let is_equal = (n=m) in VBool is_equal
                           | (VBool b1, VBool b2) -> let is_equal = (b1=b2) in VBool is_equal
                           | (VObj o1, VObj o2) -> let is_equal = (o1=o2) in VBool is_equal
                           | _ -> assert false
      )
      
        | Binop (Neq,lhs,rhs) -> ( match (evaluate lhs,evaluate rhs) with
                            | (VInt n,VInt m) -> let not_equal = (n<>m) in VBool not_equal
                            | (VBool b1,VBool b2) -> let not_equal = (b1<>b2) in VBool not_equal
                            | (VObj o1, VObj o2) -> let not_equal = (o1<>o2) in VBool not_equal
                            | _ -> assert false
                            )
         
       | Binop (Eqs,lhs,rhs) -> ( let get_values hash_tbl =
                                let add_value_to_list key value acc = value :: acc in
                                Hashtbl.fold add_value_to_list hash_tbl []
                              in

                              let rec compare_structures val1 val2 =
                                match (val1,val2) with
                                | (VInt n,VInt m) -> let is_equal = (n=m) in is_equal
                                | (VBool b1,VBool b2) -> let is_equal = (b1=b2) in is_equal
                                | (VObj o1,VObj o2) -> let equal_cls = (o1.cls=o2.cls) in
                                                       let val_list1 = get_values o1.fields in
                                                       let val_list2 = get_values o2.fields in
                                                       let equal_fields = List.for_all2 (fun v1 v2 -> compare_structures v1 v2) val_list1 val_list2 in
                                                       equal_cls && equal_fields
                                | _ -> assert false
                              in
                              VBool (compare_structures (evaluate lhs) (evaluate rhs))
                            )
                             
        | Binop (Neqs,lhs,rhs) -> ( let get_values hash_tbl =
                                let add_value_to_list key value acc = value :: acc in
                                Hashtbl.fold add_value_to_list hash_tbl []
                              in
        
                              let rec compare_inequalities val1 val2 =
                              match (val1,val2) with
                              | (VInt n,VInt m) -> let not_equal = (n<>m) in not_equal
                              | (VBool b1,VBool b2) -> let not_equal = (b1<>b2) in not_equal
                              | (VObj o1,VObj o2) -> let diff_cls = (o1.cls<>o2.cls) in
                                                     let val_list1 = get_values o1.fields in
                                                     let val_list2 = get_values o2.fields in
                                                     let diff_fields = List.exists2 (fun v1 v2 -> compare_inequalities v1 v2) val_list1 val_list2 in
                                                     diff_cls || diff_fields
                              | _ -> assert false
                              in
                              VBool (compare_inequalities (evaluate lhs) (evaluate rhs))
                            )
        
      | Binop(And, lhs, rhs) -> VBool(eval_to_bool lhs && eval_to_bool rhs )
      | Binop(Or, lhs, rhs) -> VBool(eval_to_bool lhs || eval_to_bool rhs)

      | Get accessor -> begin
        match accessor with
        | Var id -> (
            match (Hashtbl.find_opt local_env id, Hashtbl.find_opt global_env id) with
                | (Some local_val, _) -> local_val
                | (_, Some global_val) -> global_val
                | (None, None) -> failwith (Printf.sprintf "La variable %s n'est pas déclarée" id)
        )
        | Field (obj_expr,id) -> try
            Hashtbl.find (eval_to_obj obj_expr).fields id
        with
             | Not_found -> failwith (Printf.sprintf "L'attribut %s n'existe pas" id)
        end

      | New class_id -> ( match List.find_opt (fun cls -> cls.class_name = class_id) p.classes with
                | Some cls ->
                    let obj_fields = Hashtbl.create 0 in
                    let () = List.iter (fun (field,_) -> Hashtbl.add obj_fields field Null) cls.attributes in
                    VObj {cls = cls.class_name ; fields = obj_fields}
                | None -> let err_msg = Printf.sprintf "La classe %s est inexistante" class_id in
                        failwith err_msg
                )
      | NewCstr (class_id,arg_list) -> ( match List.find_opt (fun cls -> cls.class_name = class_id) p.classes with
                           | Some cls ->
                                  let obj_instance = {cls = cls.class_name ; fields = Hashtbl.create 0} in
                                  let evaluated_args = List.map (fun arg -> evaluate arg) arg_list in
                                  eval_function (locate_method obj_instance.cls "constructor") (VObj obj_instance) evaluated_args
                           | None -> let err_msg = Printf.sprintf "La classe %s est inexistante" class_id in
                                     failwith err_msg
                           )
      | MethCall (obj_expr,method_id,arg_list) -> ( match evaluate obj_expr with
                           | VObj obj_instance ->
                               let method_ = locate_method obj_instance.cls method_id in
                               let evaluated_args = List.map (fun arg -> evaluate arg) arg_list in
                               eval_function method_ (VObj obj_instance) evaluated_args
                           | _ -> assert false
                            )
      | InstanceOf(expr, target_type) -> (
                              match evaluate expr with
                                              | VObj obj_instance -> VBool (obj_instance.cls = typ_to_string target_type)
                                              | _ -> VBool false
                          )
      
      | _ -> failwith "case not implemented in evaluate"
    in
  
    let rec execute_instruction (instr: instr): unit = match instr with
      | Print expr -> Printf.printf "%d\n" (eval_to_int expr)
      | Set (accessor,expr) -> let value = evaluate expr in
                    begin
                     match accessor with
                     | Var var_name  -> Hashtbl.replace local_env var_name value
                     | Field (obj_expr,field_name) -> Hashtbl.replace (eval_to_obj obj_expr).fields field_name value
                    end
      |If(cond_expr,then_instr_list,else_instr_list) -> if (eval_to_bool cond_expr) then (process_seq then_instr_list)
                            else (process_seq else_instr_list)
      |While(cond_expr,loop_instr_list) -> if (eval_to_bool cond_expr) then begin process_seq loop_instr_list ; execute_instruction (While(cond_expr,loop_instr_list)) end
      |Return(expr) -> Hashtbl.add local_env "return" (evaluate expr)  

      | _ -> failwith "case not implemented in execute_instruction"
    and process_seq instr_list = 
      List.iter execute_instruction instr_list
    in

    process_seq instr_list
  in
  
  process_seq p.main (Hashtbl.create 1)

