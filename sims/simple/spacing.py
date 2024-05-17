import numpy as np 

nx = 40 
xl = 2000

dxi = xl/nx
bias=1.2
xloc=0.0

for i in range(1,nx):
    xloc=xloc+dxi*bias**(i-1)
    print(i, xloc/4000)    
