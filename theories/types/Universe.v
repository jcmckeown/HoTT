(* -*- mode: coq; mode: visual-line -*- *)
(** * Theorems about the universe, including the Univalence Axiom. *)

Require Import Overture PathGroupoids Equivalences.
Require Import HProp EquivalenceVarieties.
Local Open Scope path_scope.
Local Open Scope equiv_scope.

Generalizable Variables A B f.

(** *** Paths *)

Instance isequiv_path {A B : Type} (p : A = B)
  : IsEquiv (transport (fun X:Type => X) p)
  := BuildIsEquiv _ _ _ (transport (fun X:Type => X) p^)
  (fun b => ((transport_pp idmap p^ p b)^ @ transport2 idmap (concat_Vp p) b))
  (fun a => ((transport_pp idmap p p^ a)^ @ transport2 idmap (concat_pV p) a))
  (fun a => match p in _ = C return
              (transport_pp idmap p^ p (transport idmap p a))^ @
                 transport2 idmap (concat_Vp p) (transport idmap p a) =
              ap (transport idmap p) ((transport_pp idmap p p^ a) ^ @
                transport2 idmap (concat_pV p) a) with idpath => 1 end).

Definition equiv_path (A B : Type) (p : A = B) : A <~> B
  := BuildEquiv _ _ (transport (fun X:Type => X) p) _.

Definition equiv_path_V `{Funext} (A B : Type) (p : A = B) :
  equiv_path B A (p^) = equiv_inverse (equiv_path A B p).
Proof.
  destruct p. simpl. unfold equiv_path, equiv_inverse. simpl. apply ap.
  refine (@allpath_hprop _ (hprop_isequiv _) _ _).
Defined.

Class Univalence := {
  isequiv_equiv_path :> forall (A B : Type), IsEquiv (equiv_path A B)
}.

Section Univalence.
Context `{Univalence}.

Definition path_universe_uncurried {A B : Type} (f : A <~> B) : A = B
  := (equiv_path A B)^-1 f.

Definition path_universe {A B : Type} (f : A -> B) {feq : IsEquiv f} : (A = B)
  := path_universe_uncurried (BuildEquiv _ _ f feq).

Definition transport_path_universe {A B : Type} (f : A -> B) {feq : IsEquiv f} (z : A)
  : transport (fun X:Type => X) (path_universe f) z = f z
  := ap10 (ap (equiv_fun A B) (eisretr (equiv_path A B) (BuildEquiv _ _ f feq))) z.

(* This somewhat fancier version is useful when working with HITs. *)
Definition transport_path_universe'
  {A : Type} (P : A -> Type) {x y : A} (p : x = y)
  (f : P x <~> P y) (q : ap P p = path_universe f) (u : P x)
  : transport P p u = f u
  := transport_compose idmap P p u
   @ ap10 (ap (transport idmap) q) u
   @ transport_path_universe f u.

Definition eta_path_universe {A B : Type} (p : A = B)
  : path_universe (equiv_path A B p) = p
  := eissect (equiv_path A B) p.

Definition isequiv_path_universe {A B : Type}
  : IsEquiv (@path_universe_uncurried A B)
 := _.

Definition equiv_path_universe (A B : Type) : (A <~> B) <~> (A = B)
  := BuildEquiv _ _ (@path_universe_uncurried A B) isequiv_path_universe.

Definition path_universe_V_uncurried `{Funext} {A B : Type} (f : A <~> B)
  : path_universe_uncurried (equiv_inverse f) = (path_universe_uncurried f)^.
Proof.
  revert f. equiv_intro ((equiv_path_universe A B)^-1) p. simpl.
  path_via (p^).
    2: exact (inverse2 (eisretr (equiv_path_universe A B) p)^).
  unfold compose. path_via (path_universe_uncurried (equiv_path B A p^)).
    by refine (ap _ (equiv_path_V A B p)^).
  by refine (eissect (equiv_path B A) p^).
Defined.

Definition path_universe_V `{Funext} `(f : A -> B) `{IsEquiv A B f}
  : path_universe (f^-1) = (path_universe f)^
  := path_universe_V_uncurried (BuildEquiv A B f _).

End Univalence.
