model BouncingBall2D
  Modelica.Units.SI.Position x;
  Modelica.Units.SI.Position y;
  Modelica.Units.SI.Velocity dx;
  Modelica.Units.SI.Velocity dy;
  parameter Modelica.Units.SI.Radius r = 0.1;
  parameter Modelica.Units.SI.Mass m = 1.0;
  parameter Real e = 0.9 "Coefficient of restitution";
  parameter Modelica.Units.SI.Position x0 = 0.5;
  parameter Modelica.Units.SI.Position y0 = 1.0;
  parameter Modelica.Units.SI.Position dx0 = 1.0;
  parameter Modelica.Units.SI.Position dy0 = 0.0;
  parameter Modelica.Units.SI.Position xmax = 1.0;
  parameter Modelica.Units.SI.Position eps = 1e-2;
protected
  Real y_done;
  Real x_done;
initial equation
  x = x0;
  y = y0;
  dx = dx0;
  dy = dy0;
  y_done = 1.0;
  x_done = 1.0;
equation
  der(x) = if (xmax - x) > r - eps and x > r - eps then dx else 0.0;
  der(y) = if y > r - eps then dy else 0.0;
  m*der(dx) = 0.0;
  m*der(dy) = -9.81*m*y_done;
  when (y < r and dy < 0 and y_done == 1.0) then
    reinit(dy, -pre(dy)*e);
  end when;
  when (y < r - eps) then
    y_done = 0.0;
    reinit(dy, 0.0);
  end when;
  when {x < r, (xmax - x) < r} then
    reinit(dx, -pre(dx)*e);
  end when;
  when (abs(dx) < eps) then
    reinit(dx, 0.0);
  end when;
  when {x < r - eps or (xmax - x) < r - eps} then
    x_done = 0.0;
    reinit(dx, 0.0);
  end when;
  annotation(
    Icon(coordinateSystem(preserveAspectRatio = false)),
    Diagram(coordinateSystem(preserveAspectRatio = false)),
    uses(Modelica(version = "4.0.0")),
    version = "1",
    experiment(StartTime = 0, StopTime = 60, Tolerance = 1e-06, Interval = 0.12));
end BouncingBall2D;