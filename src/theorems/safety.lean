import lemmas.helpers
import lemmas.canonical_forms
import lemmas.inversion

theorem progress
  {Γ: cx typ}
  {e: exp}
  {τ: typ}
  (no_fv_e: fv e = [])
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
  let emp := iff.elim_left (if_fv_empty et_e1 et_e2 et_e3) no_fv_e,
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
  simp [fv] at no_fv_e,
  exfalso,
  exact no_fv_e,
  left,
  exact val.fn et_x et_τ1 et_e,
  let emp := iff.elim_left (app_fv_empty et_e1 et_e2) no_fv_e,
  cases et_ih_a emp.left,
  cases et_ih_a_1 emp.right,
  cases arrow_canonical_forms h et_a,
  cases h_2,
  right,
  existsi subst et_e2 w h_2_w emp.right,
  let d := @steps.app_done w et_τ1 h_2_w et_e2 emp.right h_1,
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
end

theorem preservation
  {Γ: cx typ}
  {e e': exp}
  {τ: typ}
  (no_fv_e: fv e = [])
  (et: has_typ Γ e τ)
  (st: steps e e')
  : has_typ Γ e' τ ∧ fv e' = [] :=
begin
  induction st generalizing Γ τ,
  let inv := inversion_if et,
  let emp := iff.elim_left (if_fv_empty st_e1 st_e2 st_e3) no_fv_e,
  let e1'_ih := st_ih emp.left inv.left,
  split,
  exact has_typ.if_ e1'_ih.left inv.right.left inv.right.right,
  exact iff.elim_right (if_fv_empty st_e1' st_e2 st_e3) (and.intro e1'_ih.right emp.right),
  let inv := inversion_if et,
  let emp := iff.elim_left (if_fv_empty exp.true st_e2 st_e3) no_fv_e,
  exact and.intro inv.right.left emp.right.left,
  let inv := inversion_if et,
  let emp := iff.elim_left (if_fv_empty exp.false st_e2 st_e3) no_fv_e,
  exact and.intro inv.right.right emp.right.right,
  cases inversion_app et,
  let emp := iff.elim_left (app_fv_empty st_e1 st_e2) no_fv_e,
  let e1'_ih := st_ih emp.left h.left,
  split,
  exact has_typ.app e1'_ih.left h.right,
  exact iff.elim_right (app_fv_empty st_e1' st_e2) (and.intro e1'_ih.right emp.right),
  cases inversion_app et,
  let emp := iff.elim_left (app_fv_empty st_e1 st_e2) no_fv_e,
  let e2'_ih := st_ih emp.right h.right,
  split,
  exact has_typ.app h.left e2'_ih.left,
  exact iff.elim_right (app_fv_empty st_e1 st_e2') (and.intro emp.left e2'_ih.right),
  sorry,
end
