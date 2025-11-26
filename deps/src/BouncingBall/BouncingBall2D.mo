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
  parameter Modelica.Units.SI.Velocity dx0 = 1.0;
  parameter Modelica.Units.SI.Velocity dy0 = 0.0;
  parameter Modelica.Units.SI.Position xmax = 1.0;
  parameter Modelica.Units.SI.Position eps = 1e-2;
  parameter Real stopFrac = 0.05 "Fraction of velocity left before stopping movement";
  parameter Modelica.Units.SI.Acceleration g = 9.81 "Gravitational acceleration";
protected
  Real active_y;
  Real active_x;
initial equation
  x = x0;
  y = y0;
  dx = dx0;
  dy = dy0;
  active_y = 1.0;
  active_x = 1.0;
equation
  der(x) = dx * active_x;
  der(y) = dy * active_y;
  m*der(dx) = 0.0;
  m*der(dy) = -g*m*active_y;
  der(active_y) = 0.0;
  der(active_x) = 0.0;
  when (y <= r and dy < 0 and active_y == 1.0) then
    reinit(dy, if abs(pre(dy) * e) < sqrt(2 * (y0-r) * g) * stopFrac then 0 else -pre(dy)*e);
    reinit(active_y, if abs(pre(dy) * e) < sqrt(2 * (y0-r) * g) * stopFrac then 0.0 else pre(active_y));
  end when;
  when {x < r, (xmax - x) < r} then
    reinit(dx, if abs(pre(dx) * e) < eps then 0.0 else -pre(dx)*e);
    reinit(active_x, if abs(pre(dx) * e) < eps then 0.0 else pre(active_x));
  end when;
  annotation(
    Icon(coordinateSystem(preserveAspectRatio = false)),
    Diagram(coordinateSystem(preserveAspectRatio = false)),
    uses(Modelica(version = "4.0.0")),
    version = "1",
    experiment(StartTime = 0, StopTime = 60, Tolerance = 1e-06, Interval = 0.12));
end BouncingBall2D;