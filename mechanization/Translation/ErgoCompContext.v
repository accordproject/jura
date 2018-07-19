(*
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 *)

Require Import String.
Require Import List.

Require Import ErgoSpec.Common.Utils.EResult.
Require Import ErgoSpec.Common.Utils.ENames.
Require Import ErgoSpec.Backend.ErgoBackend.
Require Import ErgoSpec.ErgoC.Lang.ErgoC.
Require Import ErgoSpec.Translation.ErgoNameResolve.

Section ErgoCompContext.

  (* XXX For typing, might be better to keep clauses for the same contract together
         i.e., to have clause_env be: list (string * list (string ergoc_function)) *)
  Record compilation_context : Set :=
    mkCompCtxt {
        compilation_context_namespace: namespace_ctxt;                             (**r for name resolution *)
        compilation_context_function_env : list (string * ergoc_function);         (**r functions in scope *)
        compilation_context_clause_env : list (string * string * ergoc_function);  (**r clauses in scope with contract/clause name *)
        compilation_context_global_env : list (string * ergoc_expr);               (**r global variables in scope *)
        compilation_context_local_env : list (string * ergoc_expr);                (**r local variables in scope *)
      }.

  Definition namespace_ctxt_of_compilation_context (ctxt:compilation_context) : namespace_ctxt :=
    ctxt.(compilation_context_namespace).

  Definition compilation_context_update_namespace
             (ctxt:compilation_context) (nsctxt:namespace_ctxt) : compilation_context :=
    mkCompCtxt nsctxt
               ctxt.(compilation_context_function_env)
               ctxt.(compilation_context_clause_env)
               ctxt.(compilation_context_global_env)
               ctxt.(compilation_context_local_env).

  Definition compilation_context_update_function_env
             (ctxt : compilation_context)
             (name : string)
             (value : ergoc_function) : compilation_context :=
    mkCompCtxt ctxt.(compilation_context_namespace)
               ((name, value)::ctxt.(compilation_context_function_env))
               ctxt.(compilation_context_clause_env)
               ctxt.(compilation_context_global_env)
               ctxt.(compilation_context_local_env).

  Definition compilation_context_update_clause_env
             (ctxt : compilation_context)
             (coname : string)
             (clname : string)
             (value : ergoc_function) : compilation_context :=
    mkCompCtxt ctxt.(compilation_context_namespace)
               ctxt.(compilation_context_function_env)
               ((coname,clname,value)::ctxt.(compilation_context_clause_env))
               ctxt.(compilation_context_global_env)
               ctxt.(compilation_context_local_env).

  Definition compilation_context_update_global_env
             (ctxt : compilation_context)
             (name : string)
             (value : ergoc_expr) : compilation_context :=
    mkCompCtxt ctxt.(compilation_context_namespace)
               ctxt.(compilation_context_function_env)
               ctxt.(compilation_context_clause_env)
               ((name, value)::ctxt.(compilation_context_global_env))
               ctxt.(compilation_context_local_env).

  Definition compilation_context_update_local_env
             (ctxt : compilation_context)
             (name : string)
             (value : ergoc_expr) : compilation_context :=
    mkCompCtxt ctxt.(compilation_context_namespace)
               ctxt.(compilation_context_function_env)
               ctxt.(compilation_context_clause_env)
               ctxt.(compilation_context_global_env)
               ((name, value)::ctxt.(compilation_context_local_env)).

  Definition compilation_context_set_local_env
             (ctxt : compilation_context)
             (new_local_env : list (string * ergoc_expr)) : compilation_context :=
    mkCompCtxt ctxt.(compilation_context_namespace)
               ctxt.(compilation_context_function_env)
               ctxt.(compilation_context_clause_env)
               ctxt.(compilation_context_global_env)
               new_local_env.

  Definition set_namespace_in_compilation_context
             (ns:namespace_name)
             (ctxt:compilation_context)
    : eresult compilation_context :=
    elift
      (compilation_context_update_namespace
         ctxt)
      (new_ergo_module_namespace
         (namespace_ctxt_of_compilation_context ctxt)
         ns).

  Definition init_compilation_context nsctxt : compilation_context :=
    mkCompCtxt nsctxt nil nil nil nil.
  
End ErgoCompContext.
