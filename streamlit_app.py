import numpy as np
import pandas as pd
import math as m
import streamlit as st
import plotly.graph_objects as go

'# Dynamic Force Analysis'
'## Single Degree of Freedom'

'---'

with st.sidebar.beta_container():
    '__Structural Properties Input__'
    stiffness = st.number_input(
        'stiffness, k, kip/in',
        min_value = 0.0,
        value = 400.00,
        step=25.0
        )   
    mass = st.number_input('mass, m, kip s^2/in', value  = 0.7619, step=.1)
    zeta = st.number_input('fraction of critical damping, zeta', value = .05, step=.01)

    '__Initial Conditions Input__'
    u_t0 = st.number_input('displacement, u0, at time = 0', value = 0.0, step=.1)
    ud_t0 = st.number_input('velocity, ud0, at time = 0', value = 5.0, step=.1)


    '__Time Input__'
    delta_time = st.number_input('length of each step of time, delta_time', value = 0.01, step=.01)
    max_time = st.number_input('total length of time to be evaluated, max_time', value = 1.5, step=.1)



with st.beta_expander("Calculation of Additional Parameters"):
    p1, p2 = st.beta_columns(2)
    with p1:
        '__Calculated Structure Parameters__'
        with st.echo():
            # structures natural frequency
            Omega = m.sqrt(stiffness/mass) 
            # damped natural frequency
            OmegaD = Omega * m.sqrt(1-zeta**2)
            # time for one full cycle
            T = 2*np.pi/Omega

    with p2:
        '__Calculated Response Parameters__'
        with st.echo():
            A = u_t0
            B = (ud_t0+(u_t0*zeta*Omega))/OmegaD

with st.beta_expander("Setup of the Data"):
    '__Define Range for Time Steps__'
    with st.echo():
        time_steps = np.arange(0, max_time, delta_time)

    '__Creation of Data Frame__'
    with st.echo():
        df = pd.DataFrame(data=time_steps, columns=['time'])

with st.beta_expander("Displacement Calculations"):
    '__Define u(t) Calculation and apply to data__'
    with st.echo():
        def determineDisplacementForTime(x):
            return (
                (m.exp(-zeta * Omega * x.time))
                * (
                    A * m.cos(OmegaD * x.time) 
                    + B * m.sin(OmegaD * x.time)
                    )
                )

        df['u'] = df.apply(determineDisplacementForTime, axis=1)

plt = go.Figure(
    layout=go.Layout(
        # height=300,
        # width=500,
        template='plotly_white',
        # showlegend=False,
        # yaxis_range=[0,10],
        # xaxis_range=[0,60],
    ))
plt.add_trace(go.Scatter(x=df.time, y=df.u, name='Displacement per... Time'))
plt.update_yaxes(title_text='displacement (in)')
plt.update_xaxes(title_text='time (d)')
plt.update_layout({'margin':dict(l=40, r=40, t=40, b=40)})
    
st.write(plt)
