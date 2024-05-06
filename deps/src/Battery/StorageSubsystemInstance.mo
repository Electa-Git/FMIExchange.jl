model StorageSubsystemInstance
  parameter Modelica.Units.SI.Voltage V_nominal=230 "Nominal voltage";
  parameter Modelica.Units.SI.Power PInvACRated=1000 "Inverter rated AC power";
  parameter Modelica.Units.SI.Power PBatRated=1000 "Battery rated power";
  parameter Modelica.Units.SI.Energy BatCap=200*3600 "Battery rated capacity";
  parameter Real SoCMin(min=0, max=1) = 0.15 "Minimum battery SoC";
  parameter Real SoCMax(min=0, max=1) = 0.95 "Maximum battery SoC";
  parameter Real SoCInit(min=0, max=1) = 0.5 "Initial battery SoC";
  parameter Modelica.Units.SI.Efficiency EffInvNominal=0.97 "Inverter nominal efficiency";
  parameter Modelica.Units.SI.Efficiency EffBatC=0.97 "Battery charging efficiency";
  parameter Modelica.Units.SI.Efficiency EffBatD=0.97 "Battery discharging efficiency";

  Modelica.Blocks.Interfaces.RealInput P_setpoint(final quantity="Power", final unit="W");
  Modelica.Blocks.Interfaces.RealOutput P_ac(final quantity="Power", final unit="W");
  Modelica.Blocks.Interfaces.RealOutput SoC;
  MoPED.Electrical.Storage.StorageSubsystem stoSub(
						   V_nominal=V_nominal,
						   PInvACRated=PInvACRated,
						   PBatRated=PBatRated,
						   BatCap=BatCap,
						   SoCMin=SoCMin,
						   SoCMax=SoCMax,
						   SoCInit=SoCInit,
						   EffInvNominal=EffInvNominal,
						   EffBatC=EffBatC,
						   EffBatD=EffBatD);
equation
  connect(P_setpoint, stoSub.P_setpoint);
  connect(P_ac, stoSub.P_ac);
  connect(SoC, stoSub.SoC);

end StorageSubsystemInstance;
