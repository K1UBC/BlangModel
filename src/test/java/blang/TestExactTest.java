package blang;

import org.junit.Assert;
import org.junit.Test;

import blang.types.StaticUtils;
import blang.validation.ExactTest;
import blang.validation.internals.Helpers;
import blang.validation.internals.fixtures.BadNormal;
import blang.validation.internals.fixtures.RealRealizationSquared;

/**
 * A test for the exact test, to make sure it catches some common types of errors.
 */
public class TestExactTest 
{
  @Test
  public void checkBadNormalDetected()
  {
    Helpers.setOkToUseDefectiveImplementation();
    
    ExactTest exact = new ExactTest();
    
    exact.add(
        new BadNormal.Builder().setMean(() -> 0.2).setVariance(() -> 0.1).setRealization(StaticUtils.realVar(1.0)).build(), 
        new RealRealizationSquared() 
    );
    
    Assert.assertTrue(exact.nTests() > 0);
    Assert.assertEquals(exact.failedTests().size(), exact.nTests());
  }
}