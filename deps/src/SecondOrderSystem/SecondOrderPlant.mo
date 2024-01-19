model SecondOrderPlant
  Modelica.Blocks.Interfaces.RealInput u annotation(
    Placement(transformation(origin = {-106, 0}, extent = {{-20, -20}, {20, 20}}), iconTransformation(origin = {-96, 0}, extent = {{-20, -20}, {20, 20}})));
  Modelica.Blocks.Interfaces.RealOutput y annotation(
    Placement(transformation(origin = {106, 0}, extent = {{-10, -10}, {10, 10}}), iconTransformation(origin = {100, 2}, extent = {{-10, -10}, {10, 10}})));

  parameter Real A[2,2] = [0.0, 1.0;0.0, -1.0];
  parameter Real B[2,1] = [0.0; 1.0];
  parameter Real C[1,2] = [1.0, 0.0];
  parameter Real D[1,1] = [0.0];

  parameter Real x10 = 0.0;
  parameter Real x20 = 0.0;
  
  Real x1;
  Real x2;
  Real[1,1] yy;
initial equation
x1 = x10;
x2 = x20;

equation

  [der(x1); der(x2)] = A * [x1; x2] + B * u;
  yy = C * [x1; x2] + D * u;
  y = yy[1,1];

annotation(
    uses(Modelica(version = "4.0.0")));
end SecondOrderPlant;