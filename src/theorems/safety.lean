import lemmas.canonical_forms
import lemmas.fv
import lemmas.subst
import lemmas.inversion

theorem progress
  {Γ: cx typ}
  {e: exp}
  {τ: typ}
  (fv_e: fv e = [])
  (et: has_typ Γ e τ)
  : val e ∨ (∃ (e': exp), steps e e') :=
begin
  induction et,
  left,
  exact val.int et_n,
  left,
  exact val.true,
  left,
  exact val.false,
  right,
  let emp := iff.elim_left (if_fv_empty et_e1 et_e2 et_e3) fv_e,
  cases et_ih_a emp.left,
  cases bool_canonical_forms h et_a,
  rw h_1,
  existsi et_e2,
  exact steps.if_true,
  rw h_1,
  existsi et_e3,
  exact steps.if_false,
  cases h,
  existsi exp.if_ h_w et_e2 et_e3,
  exact steps.if_e1 h_h,
  simp [fv] at fv_e,
  exfalso,
  exact fv_e,
  left,
  exact val.fn et_x et_τ1 et_e,
  let emp := iff.elim_left (app_fv_empty et_e1 et_e2) fv_e,
  cases et_ih_a emp.left,
  cases et_ih_a_1 emp.right,
  cases arrow_canonical_forms h et_a,
  cases h_2,
  right,
  existsi subst et_e2 w emp.right h_2_w,
  let d := steps.app_done emp.right h_1,
  -- avoid weird 'motive is not type correct' error
  rw symm h_2_h at d,
  exact d,
  right,
  cases h_1,
  existsi exp.app et_e1 h_1_w,
  exact steps.app_e2 h h_1_h,
  right,
  cases h,
  existsi exp.app h_w et_e2,
  exact steps.app_e1 h_h,
  left,
  exact val.unit,
  let emp := iff.elim_left (pair_fv_empty et_e1 et_e2) fv_e,
  cases et_ih_a emp.left,
  cases et_ih_a_1 emp.right,
  left,
  exact val.pair h h_1,
  cases h_1,
  right,
  existsi exp.pair et_e1 h_1_w,
  exact steps.pair_e2 h h_1_h,
  cases h,
  right,
  existsi exp.pair h_w et_e2,
  exact steps.pair_e1 h_h,
  simp [pair_left_fv] at fv_e,
  right,
  cases et_ih fv_e,
  cases pair_canonical_forms h et_a,
  cases h_1,
  rw h_1_h at h ⊢,
  existsi w,
  exact steps.pair_left_done h,
  cases h,
  existsi exp.pair_left h_w,
  exact steps.pair_left_arg h_h,
  simp [pair_right_fv] at fv_e,
  right,
  cases et_ih fv_e,
  cases pair_canonical_forms h et_a,
  cases h_1,
  rw h_1_h at h ⊢,
  existsi h_1_w,
  exact steps.pair_right_done h,
  cases h,
  existsi exp.pair_right h_w,
  exact steps.pair_right_arg h_h,
  simp [either_left_fv] at fv_e,
  cases et_ih fv_e,
  left,
  exact val.either_left h,
  right,
  cases h,
  existsi exp.either_left et_τ2 h_w,
  exact steps.either_left_arg h_h,
  simp [either_right_fv] at fv_e,
  cases et_ih fv_e,
  left,
  exact val.either_right h,
  right,
  cases h,
  existsi exp.either_right et_τ1 h_w,
  exact steps.either_right_arg h_h,
  simp [case_never_fv] at fv_e,
  cases et_ih fv_e,
  exfalso,
  exact never_canonical_forms h et_a,
  right,
  cases h,
  existsi exp.case_never et_τ h_w,
  exact steps.case_never_arg h_h,
  right,
  simp [case_fv] at fv_e,
  let fv' := iff.elim_left append_nil_both fv_e,
  cases et_ih_a fv'.left,
  cases either_canonical_forms h et_a,
  cases h_1,
  rw h_1 at fv' h ⊢,
  rw either_left_fv w at fv',
  existsi subst w et_x1 fv'.left et_e1,
  exact steps.case_done_left fv'.left h,
  rw h_1 at fv' h ⊢,
  rw either_right_fv w at fv',
  existsi subst w et_x2 fv'.left et_e2,
  exact steps.case_done_right fv'.left h,
  cases h,
  existsi exp.case h_w et_x1 et_e1 et_x2 et_e2,
  exact steps.case_arg h_h,
end

theorem preservation
  {Γ: cx typ}
  {e e': exp}
  {τ: typ}
  (fv_e: fv e = [])
  (et: has_typ Γ e τ)
  (st: steps e e')
  : has_typ Γ e' τ ∧ fv e' = [] :=
begin
  induction st generalizing Γ τ,
  let inv := inversion_if et,
  let emp := iff.elim_left (if_fv_empty st_e1 st_e2 st_e3) fv_e,
  let e1'_ih := st_ih emp.left inv.left,
  split,
  exact has_typ.if_ e1'_ih.left inv.right.left inv.right.right,
  exact iff.elim_right (if_fv_empty st_e1' st_e2 st_e3) (and.intro e1'_ih.right emp.right),
  let inv := inversion_if et,
  let emp := iff.elim_left (if_fv_empty exp.true st_e2 st_e3) fv_e,
  exact and.intro inv.right.left emp.right.left,
  let inv := inversion_if et,
  let emp := iff.elim_left (if_fv_empty exp.false st_e2 st_e3) fv_e,
  exact and.intro inv.right.right emp.right.right,
  cases inversion_app et,
  let emp := iff.elim_left (app_fv_empty st_e1 st_e2) fv_e,
  let e1'_ih := st_ih emp.left h.left,
  split,
  exact has_typ.app e1'_ih.left h.right,
  exact iff.elim_right (app_fv_empty st_e1' st_e2) (and.intro e1'_ih.right emp.right),
  cases inversion_app et,
  let emp := iff.elim_left (app_fv_empty st_e1 st_e2) fv_e,
  let e2'_ih := st_ih emp.right h.right,
  split,
  exact has_typ.app h.left e2'_ih.left,
  exact iff.elim_right (app_fv_empty st_e1 st_e2') (and.intro emp.left e2'_ih.right),
  split,
  cases inversion_app et,
  cases inversion_fn h.left,
  let a := typ.arrow.inj h_1.left,
  rw a.left at h,
  rw a.right,
  exact subst_preservation rfl st_fv_e2 h_1.right h.right,
  rw subst_fv st_e2 st_x st_fv_e2 st_e,
  let emp := iff.elim_left (app_fv_empty (exp.fn st_x st_τ st_e) st_e2) fv_e,
  rw fn_fv st_x st_τ st_e at emp,
  exact emp.left,
  cases inversion_prod et,
  cases h,
  simp [pair_fv_empty] at fv_e,
  let a := st_ih fv_e.left h_h.right.left,
  split,
  rw h_h.left,
  exact has_typ.pair a.left h_h.right.right,
  exact iff.elim_right (pair_fv_empty st_e1' st_e2) (and.intro a.right fv_e.right),
  cases inversion_prod et,
  cases h,
  simp [pair_fv_empty] at fv_e,
  let a := st_ih fv_e.right h_h.right.right,
  split,
  rw h_h.left,
  exact has_typ.pair h_h.right.left a.left,
  exact iff.elim_right (pair_fv_empty st_e1 st_e2') (and.intro fv_e.left a.right),
  cases inversion_prod_left et,
  simp [pair_left_fv] at fv_e,
  let a := st_ih fv_e h,
  split,
  exact has_typ.pair_left a.left,
  simp [pair_left_fv],
  exact a.right,
  cases inversion_prod_left et,
  cases inversion_prod h,
  cases h_1,
  let a := typ.pair.inj h_1_h.left,
  rw a.left,
  split,
  exact h_1_h.right.left,
  simp [pair_left_fv] at fv_e,
  simp [pair_fv_empty] at fv_e,
  exact fv_e.left,
  cases inversion_prod_right et,
  simp [pair_right_fv] at fv_e,
  let a := st_ih fv_e h,
  split,
  exact has_typ.pair_right a.left,
  simp [pair_right_fv],
  exact a.right,
  cases inversion_prod_right et,
  cases inversion_prod h,
  cases h_1,
  let a := typ.pair.inj h_1_h.left,
  rw a.right,
  split,
  exact h_1_h.right.right,
  simp [pair_right_fv] at fv_e,
  simp [pair_fv_empty] at fv_e,
  exact fv_e.right,
  simp [either_left_fv] at fv_e,
  cases inversion_sum_left et,
  let a := st_ih fv_e h.right,
  rw h.left,
  split,
  exact has_typ.either_left a.left,
  simp [either_left_fv],
  exact a.right,
  simp [either_right_fv] at fv_e,
  cases inversion_sum_right et,
  let a := st_ih fv_e h.right,
  rw h.left,
  split,
  exact has_typ.either_right a.left,
  simp [either_right_fv],
  exact a.right,
  simp [case_never_fv] at fv_e,
  let h := inversion_case_never et,
  let a := st_ih fv_e h.right,
  rw h.left,
  split,
  exact has_typ.case_never a.left,
  simp [case_never_fv],
  exact a.right,
  simp [case_fv] at fv_e,
  cases inversion_case et,
  cases h,
  let fv' := iff.elim_left append_nil_both fv_e,
  let a := st_ih fv'.left h_h.left,
  split,
  exact has_typ.case a.left h_h.right.left h_h.right.right,
  simp [case_fv],
  rw a.right,
  rw fv'.left at fv_e,
  exact fv_e,
  simp [subst_fv],
  cases inversion_case et,
  cases h,
  cases inversion_sum_left h_h.left,
  let ty_eq := typ.either.inj h.left,
  rw symm ty_eq.left at h,
  split,
  exact subst_preservation rfl st_fv_e h_h.right.left h.right,
  simp [case_fv] at fv_e,
  let a := iff.elim_left append_nil_both fv_e,
  exact (iff.elim_left append_nil_both a.right).left,
  simp [subst_fv],
  cases inversion_case et,
  cases h,
  cases inversion_sum_right h_h.left,
  let ty_eq := typ.either.inj h.left,
  rw symm ty_eq.right at h,
  split,
  exact subst_preservation rfl st_fv_e h_h.right.right h.right,
  simp [case_fv] at fv_e,
  let a := iff.elim_left append_nil_both fv_e,
  exact (iff.elim_left append_nil_both a.right).right,
end

-- the big one
theorem safety
  {Γ: cx typ}
  {e: exp}
  {τ: typ}
  (fv_e: fv e = [])
  (et: has_typ Γ e τ)
  : val e ∨ (∃ (e': exp), steps e e' ∧ has_typ Γ e' τ ∧ fv e' = []) :=
begin
  cases progress fv_e et,
  left,
  exact h,
  cases h,
  right,
  existsi h_w,
  split,
  exact h_h,
  exact preservation fv_e et h_h,
end

theorem uniqueness {Γ: cx typ} {e: exp} {τ τ': typ}:
  has_typ Γ e τ ->
  has_typ Γ e τ' ->
  τ = τ' :=
begin
  intros h1 h2,
  induction h1 generalizing τ',
  cases h2,
  refl,
  cases h2,
  refl,
  cases h2,
  refl,
  cases h2,
  exact h1_ih_a_1 h2_a_1,
  cases h2,
  exact lookup_uniq h1_a h2_a,
  cases h2,
  rw h1_ih h2_a,
  cases h2,
  exact (typ.arrow.inj (h1_ih_a h2_a)).right,
  cases h2,
  refl,
  cases h2,
  rw h1_ih_a h2_a,
  rw h1_ih_a_1 h2_a_1,
  cases h2,
  exact (typ.pair.inj (h1_ih h2_a)).left,
  cases h2,
  exact (typ.pair.inj (h1_ih h2_a)).right,
  cases h2,
  rw h1_ih h2_a,
  cases h2,
  rw h1_ih h2_a,
  cases h2,
  refl,
  cases h2,
  rw (typ.either.inj (h1_ih_a h2_a)).left at h1_ih_a_1,
  exact h1_ih_a_1 h2_a_1,
end
