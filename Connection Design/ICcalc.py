# Determining the Weld Instantaneous Center
import csv
import math as m
import statistics as s


# Assumptions
# ===========
# all weld lines are horizontal or vertical
# Force, IC, and CG are all y=0
# initial coordinates are based off of CG x = 0
# calculating a symmetric weld for only the top half where y >= 0

# Define Variables
# ================
params = { }
params['sgmt_size'] = .25 # size to be used for segments, inch
params['precision'] = 0.001
params['IC_x'] = 1 # 20 # IC guess x coordinate (distance from CG)

# Given
# -----
params['F_exx'] = 70 # ksi
params['C1'] = 1

# Chosen
# ------
params['w'] = 1/4 # weld leg size, inch
params['D'] = 4 # size of weld leg in "sixteenths", this probably could get auto calculated
params['L'] = 6 # Characteristic length of weld group, in. (height)

# Calculated
# ----------
params['A_w'] = (m.sqrt(2)/2) * (params['D']/16) # need to multiply by sgmt_size later
params['kL'] = 12 # width

params['e'] = 12
params['weld_lines'] = {
    1:{'start':(-3, 6),
       'end': (3,6)},
    }


data = { }

# Create Segments for Analysis
# ============================

def segmentize(weld_lines, sgmt_size, IC_x, **kwargs):
    # passed a weld line with start and stop coordinate.
    segments = { }
    seg = {'number': 1}
    for line in weld_lines:
        start_x = weld_lines[line]['start'][0]
        start_y = weld_lines[line]['start'][1]
        end_x = weld_lines[line]['end'][0]
        end_y = weld_lines[line]['end'][1]
        len_x = abs(end_x - start_x)
        len_y = abs(end_y - start_y)

        if len_x == 0 and len_y != 0:
            seg['orientation'] = 'V'
            qty = m.floor(abs(len_y) / sgmt_size)
            seg['size'] = abs(len_y/qty)
            if start_y > end_y:
                start_y, end_y = end_y, start_y
            seg['x'] = start_x
            y_start = start_y + seg['size']/2
            for s in range(1, qty + 1):
                seg['y'] = y_start + ((s-1) * seg['size'])
                segments[seg['number']] = seg.copy()
                seg['number'] = seg['number'] + 1
        elif len_y == 0 and len_x != 0:
            seg['orientation'] = 'H'
            qty = m.floor(abs(len_x) / sgmt_size)
            seg['size'] = abs(len_x/qty)
            seg['y'] = start_y
            x_start = start_x + seg['size']/2
            for s in range(1, qty + 1):
                seg['x'] = x_start + ((s-1) * seg['size'])
                segments[seg['number']] = seg.copy()
                seg['number'] = seg['number'] + 1

    return segments


def calculateData(params):
    data = segmentize(**params)

    def shift_for_ICx(d, IC_x, w):
        x = d['x']
        d['x'] = x + IC_x
        if d['orientation'] == 'V':
            d['r'] = m.sqrt((d['x']**2)+(d['y']**2))
            d['theta_r'] = (m.atan(abs(d['y']/d['x'])))
        elif d['orientation'] == 'H':
            d['r'] = m.sqrt((d['x']**2)+(d['y']**2))
            d['theta_r'] = m.atan(abs(d['x']/d['y']))
        calc_deform(d, w)

    # function to calculate initial set of deformations
    def calc_deform(d, w):
        d['delta_max'] = 0.209 * m.pow((m.degrees(d['theta_r']) + 2), -0.32) * w
        d['delta_ult'] = min((0.17 * w ),
                        (1.087 * m.pow((m.degrees(d['theta_r']) + 6), -0.65) * w ))
        d['delta_u_r'] = d['delta_ult'] / d['r']
        return d

    # tell program to run calc_deform for each segment, d, in data
    for d in data:
        d = shift_for_ICx(data[d], params['IC_x'], params['w'])

    deltas_u_r = [ ]
    for n in range(1, len(data)+1): #verify this is the right count...
        deltas_u_r.append(data[n]['delta_u_r'])

    # find the minimum critical deformation and add to parameters
    params['min_cr'] = min(deltas_u_r)

    # use minimum critical deformation to calculate remaining forces
    def calc_forces(d, min_cr, F_exx, A_w, **kwargs):
        # need to calculate here 'delta_i', 'pi', 'Ri', 'Ri_x', 'Ri_y', 'Riri'
        d['delta_int'] = d['r'] * min_cr
        d['p'] = d['delta_int']/d['delta_max']
        r1 = 0.6 * F_exx * A_w * d['size'] # A_w did not account for length of segment
        r2 = 1 + (0.5 * m.pow((m.sin(d['theta_r'])),1.5))
        f_p =  m.pow(d['p'] * (1.9 - (0.9*d['p'])), 0.3)
        d['R'] = r1 * r2 * f_p
        d['R-r'] = d['R'] * d['r']
        d['R_x'] = d['R'] * (d['y']/d['r'])
        d['R_y'] = d['R'] * (d['x']/d['r'])
        return d

    # tell program to calculate forces for all segments
    for d in data:
        d = calc_forces(data[d], **params)

    # function for summing a variable within data
    def sumd(data, var):
        values = [ ]
        for n in range(1, len(data)+1):
            values.append(data[n][var])
        return sum(values)

    # sum the three needed variables
    params['sum_Rx'] = sumd(data, 'R_x')
    params['sum_Ry'] = sumd(data, 'R_y')
    params['sum_R-r'] = sumd(data, 'R-r')

    # adjust for symmetry
    params['Pnf'] =  2*params['sum_Ry']
    params['Pnm'] = (2*params['sum_R-r']) / (params['IC_x'] + params['e'])

    return data, params


def check_completion(percent_diff, precision):
    if percent_diff != None:
        diff = abs(1-percent_diff)
        if  diff <= precision:
            return True
    return False

def pause(limits, data, percent_diff, IC_x, count, Pnf, Pnm, **kwargs):
    print(f'Iteration {count}: ICx:{IC_x:.4f}, Pnf: {Pnf:.3f}, Pnm: {Pnm:.3f}, '
          f'{percent_diff:.4f}% diff')

def iterate(params):
    p = params
    limits = [None, None]
    data = { }
    p['percent_diff'] = None
    p['count'] = 0
    while check_completion(p['percent_diff'], p['precision']) == False:
        p['count'] += 1
        results = calculateData(p)
        data = results[0]
        p = results[1]
        p['percent_diff'] = p['Pnf']/p['Pnm']
        if p['percent_diff'] <= 1:
            limits[0] = p['IC_x']
            if limits[1] == None:
                p['IC_x'] *= 2
            else:
                p['IC_x'] = s.fmean(limits)
        else:
            limits[1] = p['IC_x']
            if limits[0] == None:
                p['IC_x'] /= 2
            else:
                p['IC_x'] = s.fmean(limits)
        pause(limits, data, **p)
    return data, p

results = iterate(params)
data = results[0]
params = results[1]


# # saving the final set of data to a CSV file
# with open('sleep.csv', 'w', newline='') as csvfile:
#     labels = ['number', 'orientation', 'size', 'x', 'y', 'r', 'theta_r', 'delta_max',
#               'delta_ult', 'deltas_u_r', 'delta_int', 'p', 'R', 'R_x', 'R_y', 'R-r'
#               ]
#     dw = csv.DictWriter(csvfile, fieldnames=labels, dialect='excel')
#     dw.writeheader()

#     for d in data:
#         dw.writerow({'number': data[d]['number'], 'orientation': data[d]['orientation'],
#                     'size': data[d]['size'], 'x': data[d]['x'], 'y': data[d]['y'],
#                     'r': data[d]['r'], 'theta_r': data[d]['theta_r'],
#                     'delta_max': data[d]['delta_max'], 'delta_ult': data[d]['delta_ult'],
#                     'deltas_u_r': data[d]['delta_u_r'], 'delta_int': data[d]['delta_int'],
#                     'p': data[d]['p'], 'R': data[d]['R'], 'R_x': data[d]['R_x'],
#                     'R_y': data[d]['R_y'], 'R-r': data[d]['R-r']
#                     })

# # writing appending a line to the csv file each time the program is run
# with open('new.csv', 'a+', newline='') as csvfile:
#     pLabels = ['sgmt_size', 'precision', 'IC_x', 'Pnf', 'Pnm', 'percent_diff', 'iterations']
#     dw = csv.DictWriter(csvfile, fieldnames=pLabels, dialect='excel')
#     # dw.writeheader
#     dw.writerow({'sgmt_size': params['sgmt_size'], 'precision': params['precision'],
#                 'IC_x': params['IC_x'], 'Pnf': params['Pnf'], 'Pnm': params['Pnm'],
#                 'percent_diff': params['Pnf']/params['Pnm']})
