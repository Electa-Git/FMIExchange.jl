model SOPExample
  extends Modelica.Icons.Example;
  SecondOrderPlant secondOrderPlant annotation(
    Placement(transformation(origin = {2, 0}, extent = {{-10, -10}, {10, 10}})));
  Modelica.Blocks.Sources.Step step(startTime = 1)  annotation(
    Placement(transformation(origin = {-74, 0}, extent = {{-10, -10}, {10, 10}})));
equation
  connect(step.y, secondOrderPlant.u) annotation(
    Line(points = {{-62, 0}, {-8, 0}}, color = {0, 0, 127}));

annotation(
    uses(Modelica(version = "4.0.0")));
end SOPExample;