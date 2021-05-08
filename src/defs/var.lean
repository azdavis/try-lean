import util.list.filter
import util.list.sort

-- variables. any type with infinite values and a well-behaved ≤ would work
@[reducible]
def var: Type := ℕ

structure cx_elem (t: Type): Type :=
  (x: var)
  (v: t)

def ne_var {t: Type} (a: cx_elem t) (b: cx_elem t): Prop :=
  a.x ≠ b.x

def le_var {t: Type} (a: cx_elem t) (b: cx_elem t): Prop :=
  a.x ≤ b.x

instance cx_elem_has_le {t: Type}: has_le (cx_elem t) := has_le.mk le_var

instance ne_var_symm {t: Type}: is_symm (cx_elem t) ne_var := is_symm.mk
begin
  intros a b ab,
  simp [ne_var] at *,
  exact ne.symm ab,
end

instance le_var_decidable {t: Type}: @decidable_rel (cx_elem t) le_var :=
begin
  intros a b,
  simp [le_var],
  exact nat.decidable_le a.x b.x,
end

instance le_var_trans {t: Type}: is_trans (cx_elem t) le_var := is_trans.mk
begin
  intros a b c ha hb,
  simp [le_var] at *,
  exact is_trans.trans a.x b.x c.x ha hb,
end

instance le_var_total {t: Type}: is_total (cx_elem t) le_var := is_total.mk
begin
  intros a b,
  simp [le_var],
  exact linear_order.le_total a.x b.x,
end

structure cx (t: Type): Type :=
  (entries: list (cx_elem t))
  (nodupkeys: pairwise ne_var entries)

def cx.empty {t: Type}: cx t := cx.mk [] (pairwise.nil ne_var)

def cx.lookup {t: Type} (Γ: cx t) (x: var): option t :=
begin
  cases Γ,
  induction Γ_entries,
  exact none,
  exact (if x = Γ_entries_hd.x then
    some Γ_entries_hd.v
  else
    -- avoid weird 'can only eliminate into Prop' error when trying to use cases
    Γ_entries_ih (pairwise_inversion Γ_nodupkeys)
  ),
end

@[reducible]
def cx.insert {t: Type} (x: var) (v: t) (Γ: cx t): cx t :=
begin
  cases Γ,
  let elem := cx_elem.mk x v,
  let p: cx_elem t -> Prop := fun a, x ≠ a.x,
  let entries' := insertion_sort (elem :: list.filter p Γ_entries),
  let f := fun (a: cx_elem t), fun (b: a ∈ list.filter p Γ_entries),
    (iff.elim_left (filter_spec p Γ_entries a) b).right,
  let nodupkeys' := insertion_sort_pairwise (@pairwise.cons
    (cx_elem t) ne_var elem (list.filter p Γ_entries) f
    (filter_pairwise p Γ_nodupkeys)),
  exact cx.mk entries' nodupkeys',
end

instance cx_has_insert {t: Type}: has_insert (prod var t) (cx t) :=
  has_insert.mk begin
    intros a Γ,
    cases a,
    exact cx.insert a_fst a_snd Γ
  end
