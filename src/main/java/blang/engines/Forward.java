package blang.engines;

import org.eclipse.xtext.xbase.lib.Pair;

import bayonet.distributions.Random;
import blang.inits.Arg;
import blang.inits.DefaultValue;
import blang.inits.GlobalArg;
import blang.inits.experiments.ExperimentResults;
import blang.runtime.BlangTidySerializer;
import blang.runtime.SampledModel;
import blang.runtime.objectgraph.GraphAnalysis;

public class Forward implements PosteriorInferenceEngine
{
  @Arg               @DefaultValue("1")
  public Random random = new Random(1);
  
  @Arg   @DefaultValue("1_000")
  public int nSamples = 1_000;
  
  @GlobalArg ExperimentResults results;
  
  SampledModel model;

  @Override
  public void setSampledModel(SampledModel model) 
  {
    this.model = model;
  }

  @Override
  public void performInference() 
  {
    BlangTidySerializer tidySerializer = new BlangTidySerializer(results);
    for (int i = 0; i < nSamples; i++) 
    {
      model.forwardSample(random);
      model.getSampleWriter(tidySerializer).write(Pair.of("sample", i++)); 
    }
  }

  @Override
  public void check(GraphAnalysis analysis) 
  {
    if (analysis.hasObservations())
      throw new RuntimeException();
  }

}
