# AISC Calculation of Round HSS for Shear, Moment, and Torsion.

import math as m
import pandas as pd


# import set of HSS to be tested
data = pd.read_csv("roundhss.csv")

# Base Numbers not problem specific
in2ft = 1/12
ft2in = 12
mphi=.9
vphi = .9
tphi = .9

# Metal Properties
E = 29000
Fy = 46
Fu = 62

# Required Forces
Vr = 25 #kip
Mr = 200 #kip-ft
Tr = 150 #kip-ft

# Structure Properties
L = 8*12 #in

# Start of loop to check each HSS, once failure is found, next HSS is started
for d in range(data.shape[0]):
    Dt = data['Dt'].loc[d]
    Wt = data['W'].loc[d]
    D = data['OD'].loc[d]
    S = data['S'].loc[d]
    A = data['A'].loc[d]
    C = data['C'].loc[d]
    Z = data['Z'].loc[d]

    # data is not currently saved, but printed for manual analysis
    print(f'Shape: {data["Shape"].loc[d]}')

    # Moment Calculations AISC Spec F8 Round HSS 16.1-59
    test = 0.45*E/Fy
    if Dt <= test:

        # lambda p - compact < non-compact
        lp = 0.07*(E/Fy)
        # lambda r - non-compact < slender
        lr = 0.31*(E/Fy)
        # F8-1
        Mn1 = abs((Fy*Z) * in2ft * mphi)

        if Dt < lp:
            Mn = Mn1
        elif Dt < lr:
            # F8-2
            Mn2 = abs(((0.021*E / Dt) + Fy) * S * in2ft * mphi)
            Mn = min(Mn1, Mn2)
        else:
            # F8-4
            mFcr = 0.33*E/Dt
            # F8-3
            Mn3 = mFcr * S
            Mn = min(Mn1, Mn2, Mn3)

        # Test Moment and then proceed if Acceptable
        print(f'Mn = {Mn:.3f} > Mr = {Mr}')
        if Mn >= Mr:

            # Shear Calculations AISC Spec G5 Round HSS 16.1-75
            # From User Note: Eq. G5.2a, G5.2b will not apply for standard sections
            vFcr = 0.6*Fy
            # G5-1
            Vn = abs(vFcr * A / 2 * vphi)

            # Test Shear and then proceed if Acceptable
            print(f'Vn = {Vn:.3f} > Vr = {Vr}')
            if Vn >= Vr:

                # Torsion Calculations AISC Spec H3 Round HSS 16.1-81
                # H3-2a
                tFcr1 = 1.23*E / (m.sqrt(L/D)*(Dt**(5/4)))

                # H3.2b
                tFcr2 = 0.6*E / (Dt**(3/2))

                tFcr3 = 0.6 * Fy

                tFcr = min(tFcr3, max(tFcr1, tFcr2))

                print(f'F1 = {tFcr1:.3f}')

                print(f'F2 = {tFcr2:.3f}')

                print(f'F3 = {tFcr3:.3f}')

                # H3-1
                Tn = abs(tFcr * C * tphi * in2ft)


                # Test Torsion and then proceed if Acceptable
                print(f'Tn = {Tn:.3f} > Tr = {Tr}')
                if Tn >= Tr:
                    # H3-6
                    interaction = (Mr/Mn)+(Vr/Vn+Tr/Tn)**2
                    if interaction <= 1.0:
                        eff = Mr/Mn
                        print(f'eff: {interaction:.3f}, weight: {Wt}')
    print(f'---------')
