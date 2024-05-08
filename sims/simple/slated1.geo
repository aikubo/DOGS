xl = 2000;
yl = 2000;
yw = 100;
lc = 0.001; 

// Define Points
Point(1) = {0, yl, 0, lc};
Point(2) = {xl, yl, 0, lc};
Point(3) = {xl, 0, 0, lc};
Point(4) = {0, 0, 0, lc};

Point(5) = {yw, yw, 0, lc};  // Start at lower left
Point(6) = {yw + yw, yw, 0, lc}; // Second point in dike
Point(7) = {yw, yw + yw, 0, lc}; // Third point in dike

Point(8) = {xl - yw, yl - yw, 0, lc};
Point(9) = {xl - yw, yl - 2*yw, 0, lc};
Point(10) = {xl - 2*yw, yl - yw, 0, lc}; // Correcting Point(100) to Point(10)

// Define Lines
Line(1) = {4, 1};
Line(2) = {1, 2};
Line(3) = {2, 3};
Line(4) = {3, 4};

Line(5) = {6, 5};
Line(6) = {5, 7};
Line(7) = {7, 10}; 
Line(8) = {10, 8};
Line(9) = {8, 9};
Line(10) = {9, 6};

// Define Curve Loops
Curve Loop(21) = {5, 6, 7, 8, 9, 10};
Curve Loop(22) = {1, 2, 3, 4};

// Create Plane Surfaces
Plane Surface(24) = {22, 21};
