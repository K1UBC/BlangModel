package blang.engines.internals.schedules;

import bayonet.smc.ParticlePopulation;
import blang.inits.Arg;
import blang.inits.DefaultValue;
import blang.runtime.SampledModel;

public class FixedTemperatureSchedule implements TemperatureSchedule
{
  @Arg        @DefaultValue("100")
  public int nTemperatures = 100;

  @Override
  public double nextTemperature(ParticlePopulation<SampledModel> population, double temperature, double maxAnnealingParameter)
  {
    if (nTemperatures < 1)
      throw new RuntimeException("Number of temperatures should be positive: " + nTemperatures);
    return Math.min(maxAnnealingParameter, temperature + maxAnnealingParameter / ((double) nTemperatures));
  }
}