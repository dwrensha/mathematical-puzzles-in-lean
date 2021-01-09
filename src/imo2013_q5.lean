import data.rat.basic
import data.rat.order
import data.real.basic

/-
Direct translation of solution found in https://www.imo-official.org/problems/IMO2013SL.pdf
-/

theorem imo2013Q4
  (f: ℚ → ℝ)
  (f_i:  ∀ x y, 0 < x → 0 < y → f (x * y) ≤ f x * f y)
  (f_ii: ∀ x y, 0 < x → 0 < y → f x + f y ≤ f (x + y))
  (f_iii: ∃ a, 1 < a ∧ f a = a)
  : ∀ x, 0 < x → f x = x :=
begin
  obtain ⟨a, ha1, hae⟩ := f_iii,
  have ha1r : 1 < (a:ℝ),
  {
    rw ←rat.cast_one,
    exact rat.cast_lt.mpr ha1,
  },
  have hf1: 1 ≤ f 1,
  {
    have := (f_i a 1) (lt_trans zero_lt_one ha1) zero_lt_one,
    rw [mul_one, hae] at this,
    have haz := calc 0 < 1     : zero_lt_one
                   ... < (a:ℝ) : ha1r,

    have h11 : ↑a * 1 ≤ ↑a * f 1 := by simpa only [mul_one],
    exact (mul_le_mul_left haz).mp h11,
  },
  have hfn: ∀x: ℚ, (0 < x → ∀ n: ℕ, (↑n + 1) * f x ≤ f ((n + 1) * x)),
  {
    intros x hx n,
    induction n with pn hpn,
    { simp only [one_mul, nat.cast_zero, zero_add], },
    rw nat.cast_succ,
    calc (↑pn + 1 + 1) * f x = ((pn : ℝ) + 1) * f x + 1 * f x : add_mul (↑pn + 1) 1 (f x)
        ... = (↑pn + 1) * f x + f x : by rw one_mul
        ... ≤ f ((↑pn + 1) * x) + f x : add_le_add_right hpn (f x)
        ... ≤ f ((↑pn + 1) * x + x) : f_ii ((↑pn + 1) * x) x (mul_pos (nat.cast_add_one_pos pn) hx) hx
        ... = f ((↑pn + 1) * x + 1 * x) : by rw one_mul
        ... = f ((↑pn + 1 + 1) * x) : congr_arg f (add_mul (↑pn + 1) 1 x).symm
  },
  have hfn': ∀x: ℚ, (0 < x → ∀ n: ℕ, 0 < n → ↑n * f x ≤ f (n * x)),
  {
    intros x hx n hn,
    cases n,
    { linarith }, -- hn: 0 < 0
    have := hfn x hx n,
    rwa [nat.cast_succ n],
  },
  have hn: (∀ n : ℕ, 0 < n → (n: ℝ) ≤ f n),
  {
    intros n hn,
    calc (n: ℝ) = (n: ℝ) * 1 : by simp only [mul_one]
                  ... ≤ (n: ℝ) * f 1 : (mul_le_mul_left (nat.cast_pos.mpr hn)).mpr hf1
                  ... ≤ f (n * 1) : hfn' 1 zero_lt_one n hn
                  ... = f n : by simp only [mul_one]
  },
  have hqp: ∀ q: ℚ, 0 < q → 0 < f q,
  {
    intros q hq,
    have hqn : (q.num: ℚ) = q * (q.denom : ℚ) := rat.mul_denom_eq_num.symm,
    have hfqn : f q.num ≤ f q * f q.denom,
    {
      have := f_i q q.denom hq (nat.cast_pos.mpr q.pos),
      rwa hqn,
    },
    have hqd: (q.denom: ℝ) ≤ f q.denom := hn q.denom q.pos,
    have hqnp: 0 < q.num := rat.num_pos_iff_pos.mpr hq,
    have hqna: ((int.nat_abs q.num):ℤ) = q.num := int.nat_abs_of_nonneg (le_of_lt hqnp),
    have hqfn': (q.num: ℝ) ≤ f q.num,
    {
      rw ←hqna at hqnp,
      have := hn q.num.nat_abs (int.coe_nat_pos.mp hqnp),
      rw ←hqna,
      rwa [int.cast_coe_nat q.num.nat_abs],
    },
    have hqnz := calc (0:ℝ) < q.num : int.cast_pos.mpr hqnp
                        ... ≤ f q.num : hqfn',
    have hqdz :=
      calc (0:ℝ) < q.denom : nat.cast_pos.mpr q.pos
         ... ≤ f q.denom : hqd,
    nlinarith,
  },
  have : (∀x:ℚ, 1 ≤ x → ((x - 1):ℝ) < f x),
  {
     intros x hx,

     have hx0 := calc ((x - 1):ℝ) < ⌊x⌋ : sorry -- basic property of floor
                              ... ≤ f ⌊x⌋ : sorry, -- hn

     have ho: (⌊x⌋:ℚ) = x ∨ (⌊x⌋:ℚ) < x := eq_or_lt_of_le (floor_le x),
     cases ho,
     { rwa ho at hx0 },

     have hxmfx : 0 < (x - ⌊x⌋) := by linarith,
     have h0fx : 0 < (⌊x⌋:ℚ),
     {
       calc (0:ℚ) < 1 : zero_lt_one
              ... = (int.has_one.one : ℚ) : by simp only [int.cast_one]
              ... ≤ ⌊x⌋ : int.cast_le.mpr (le_floor.mpr hx),
     },

     calc ((x - 1):ℝ) <  f ⌊x⌋ : hx0
                  ... < f (x - ⌊x⌋) + f ⌊x⌋ : lt_add_of_pos_left (f ↑⌊x⌋) (hqp (x - ↑⌊x⌋) hxmfx)
                  ... ≤ f ((x - ⌊x⌋) + ⌊x⌋) : f_ii (x - ⌊x⌋) ⌊x⌋ hxmfx h0fx
                  ... = f x : by simp only [sub_add_cancel]
  },
  sorry,
end


