import defs.var
import util.option

theorem lookup_mem_entries {t: Type} [has_le t] {Γ: cx t} {x: var} {v: t}:
  cx_elem.mk x v ∈ Γ.entries ↔
  cx.lookup Γ x = some v :=
begin
  cases Γ,
  simp,
  split,
  intro h,
  induction Γ_entries,
  exfalso,
  exact list.not_mem_nil (cx_elem.mk x v) h,
  cases h,
  cases Γ_entries_hd,
  simp [cx.lookup],
  cases cx_elem.mk.inj h,
  simp [left],
  exact symm right,
  cases Γ_nodupkeys,
  cases Γ_sorted,
  let a := Γ_nodupkeys_a (cx_elem.mk x v) h,
  simp [ne_var] at a,
  let a' := fun x, a (symm x),
  simp [cx.lookup],
  simp [a'],
  exact Γ_entries_ih Γ_nodupkeys_a_1 Γ_sorted_a_1 h,
  intro h,
  induction Γ_entries,
  simp [cx.lookup] at h,
  exact h,
  simp [cx.lookup] at h,
  cases decidable.em (x = Γ_entries_hd.x),
  simp [h_1] at h,
  left,
  cases Γ_entries_hd,
  simp at h h_1,
  rw h_1,
  rw symm h,
  simp [h_1] at h,
  cases Γ_nodupkeys,
  cases Γ_sorted,
  right,
  exact Γ_entries_ih Γ_nodupkeys_a_1 Γ_sorted_a_1 h,
end

theorem lookup_mem_entries_ne {t: Type} [has_le t]
  {Γ: cx t} {x y: var} {vx vy: t}:
  x ≠ y ->
  (cx_elem.mk x vx ∈ Γ.entries ↔
  cx_elem.mk x vx ∈ (cx.insert y vy Γ).entries) :=
begin
  intro xy_ne,
  let p := fun (a: cx_elem t), ¬y = a.x,
  let elem := cx_elem.mk x vx,
  let p_elem: p elem := begin
    simp [p],
    simp [elem],
    exact fun b, xy_ne (symm b),
  end,
  cases Γ,
  simp,
  split,
  intro h,
  let a: elem ∈ list.filter p Γ_entries :=
    iff.elim_left filter_spec (and.intro h p_elem),
  exact iff.elim_left insertion_sort_mem (or.inr a),
  intro h,
  cases iff.elim_right insertion_sort_mem h,
  cases cx_elem.mk.inj h_1,
  exfalso,
  exact xy_ne left,
  exact (iff.elim_right filter_spec h_1).left,
end

theorem lookup_insert {t: Type} [has_le t] (Γ: cx t) (x: var) (v: t):
  cx.lookup (cx.insert x v Γ) x = some v :=
begin
  cases Γ,
  let elem := cx_elem.mk x v,
  let p: cx_elem t -> Prop := fun a, x ≠ a.x,
  let ys := (elem :: list.filter p Γ_entries),
  let h: elem ∈ ys := or.inl rfl,
  let ys' := insertion_sort ys,
  let h': elem ∈ ys' := iff.elim_left insertion_sort_mem h,
  simp [cx.insert],
  exact iff.elim_left lookup_mem_entries h',
end

theorem useless_insert_ne {t: Type} [has_le t] (Γ: cx t) (x y: var) (v: t):
  x ≠ y ->
  cx.lookup (cx.insert y v Γ) x =
  cx.lookup Γ x :=
begin
  intro h,
  cases option_em (cx.lookup Γ x),
  let a := fun h, option_not_both (cx.lookup Γ x) (and.intro h_1 h),
  let b: ∀ (vx: t), cx_elem.mk x vx ∉ Γ.entries := fun vx, fun h, a begin
    existsi vx,
    exact iff.elim_left lookup_mem_entries h,
  end,
  let c: ∀ (vx: t), cx_elem.mk x vx ∉ (cx.insert y v Γ).entries := fun vx,
    iff.elim_left (not_iff_not_of_iff (lookup_mem_entries_ne h)) (b vx),
  let d := fun vx, iff.elim_left (not_iff_not_of_iff lookup_mem_entries) (c vx),
  rw h_1,
  exact not_some_is_none d,
  cases h_1,
  let a := iff.elim_right lookup_mem_entries h_1_h,
  let b: cx_elem.mk x h_1_w ∈ (cx.insert y v Γ).entries :=
    iff.elim_left (lookup_mem_entries_ne h) a,
  rw h_1_h,
  exact iff.elim_left lookup_mem_entries b,
end

theorem ne_var_ne {t: Type} (a b: cx_elem t): ne_var a b -> a ≠ b :=
begin
  intro h,
  simp [ne_var] at h,
  intro bad,
  rw bad at h,
  exact h rfl,
end

theorem entries_same_eq {t: Type} [has_le t] {Γ Γ': cx t}:
  Γ.entries = Γ'.entries -> Γ = Γ' :=
begin
  cases Γ,
  cases Γ',
  simp,
  intro h,
  exact h,
end

theorem lookup_same_mem_entries_one {t: Type} [has_le t] {Γ Γ': cx t}:
  (∀ (x: var), cx.lookup Γ x = cx.lookup Γ' x) ->
  (∀ (e: cx_elem t), e ∈ Γ.entries -> e ∈ Γ'.entries) :=
begin
  intros h e e_in,
  cases e,
  let a := iff.elim_left lookup_mem_entries e_in,
  let b := h e_x,
  rw a at b,
  exact iff.elim_right lookup_mem_entries (symm b),
end

theorem lookup_same_mem_entries {t: Type} [has_le t] {Γ Γ': cx t}:
  (∀ (x: var), cx.lookup Γ x = cx.lookup Γ' x) ->
  (∀ (e: cx_elem t), e ∈ Γ.entries ↔ e ∈ Γ'.entries) :=
begin
  intros h e,
  split,
  exact lookup_same_mem_entries_one h e,
  let h' := fun x, symm (h x),
  exact lookup_same_mem_entries_one h' e,
end

theorem cx_elem_lt_of_le_ne {t: Type} [has_le t] (x y: cx_elem t):
  x ≤ y -> x ≠ y -> x < y :=
begin
  sorry,
end

theorem cx_elem_lt_not_both {t: Type} (x y: cx_elem t):
  ¬ (x < y ∧ y < x) :=
begin
  sorry,
end

theorem lookup_same_eq_entries {t: Type} [has_le t] {Γ Γ': cx t}:
  (∀ (x: var), cx.lookup Γ x = cx.lookup Γ' x) -> Γ.entries = Γ'.entries :=
begin
  intro h,
  exact sorted_ne_eq
    cx_elem_lt_of_le_ne
    cx_elem_lt_not_both
    (lookup_same_mem_entries h)
    (pairwise_implies ne_var_ne Γ.nodupkeys)
    (pairwise_implies ne_var_ne Γ'.nodupkeys)
    Γ.sorted
    Γ'.sorted,
end

theorem lookup_same {t: Type} [has_le t] {Γ Γ': cx t}:
  (∀ (x: var), cx.lookup Γ x = cx.lookup Γ' x) -> Γ = Γ' :=
begin
  intro h,
  exact entries_same_eq (lookup_same_eq_entries h),
end

theorem lookup_insert' {t: Type} [has_le t] (Γ: cx t) (x y: var) (v: t):
  cx.lookup (cx.insert x v Γ) y = (if x = y then some v else cx.lookup Γ y) :=
begin
  cases decidable.em (x = y),
  simp [h],
  exact lookup_insert Γ y v,
  simp [h],
  exact useless_insert_ne Γ y x v (fun e, h (symm e)),
end

theorem useless_insert_twice {t: Type} [has_le t] (Γ: cx t) (x: var) (v v': t):
  cx.insert x v (cx.insert x v' Γ) = cx.insert x v Γ :=
lookup_same begin
  intro y,
  rw lookup_insert' (cx.insert x v' Γ) x y v,
  rw lookup_insert' Γ x y v',
  rw lookup_insert' Γ x y v,
  cases decidable.em (x = y),
  simp [h],
  simp [h],
end

theorem insert_comm {t: Type} [has_le t] (Γ: cx t) (x y: var) (vx vy: t) (h: x ≠ y):
  cx.insert x vx (cx.insert y vy Γ) =
  cx.insert y vy (cx.insert x vx Γ) :=
lookup_same begin
  intro z,
  rw lookup_insert' (cx.insert y vy Γ) x z vx,
  rw lookup_insert' (cx.insert x vx Γ) y z vy,
  rw lookup_insert' Γ x z vx,
  rw lookup_insert' Γ y z vy,
  cases decidable.em (x = z),
  cases decidable.em (y = z),
  rw symm h_2 at h_1,
  exfalso,
  exact h h_1,
  simp [h_1],
  simp [h_2],
  simp [h_1],
  cases decidable.em (y = z),
  simp [h_2],
  simp [h_2],
end
