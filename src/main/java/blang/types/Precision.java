package blang.types;

import java.util.LinkedHashSet;
import java.util.Set;

import blang.core.RealVar;
import briefj.Indexer;
import briefj.collections.UnorderedPair;
import static xlinear.MatrixOperations.*;
import xlinear.SparseMatrix;



// TODO: move to separate package, generalize to GLMs, call package glm

// Examples: Time series, Spatial; abstract kernel based version
public interface Precision<K>  
{
  Plate<K> getPlate();
  
  Set<UnorderedPair<K,K>> support();
  
  double logDet();
  
  double get( UnorderedPair<K,K> pair);
  
  public static <K> SparseMatrix asMatrix(Precision<K> precision)
  {
    return asMatrix(precision, indexer(precision.getPlate()));
  }
  
  public static <K> SparseMatrix asMatrix(Precision<K> precision, Indexer<K> indexer)
  {
    int dim = precision.getPlate().indices().size();
    SparseMatrix result = sparse(dim, dim);
    for (UnorderedPair<K, K> pair : precision.support())
    {
      int 
        i0 = indexer.o2i(pair.getFirst()),
        i1 = indexer.o2i(pair.getSecond());
      double value = precision.get(pair);
      result.set(i0, i1, value);
      result.set(i1, i0, value); 
    }
    return result;
  }
  
  @SuppressWarnings("unchecked")
  public static <K> Indexer<K> indexer(Plate<K> plate)
  {
    Indexer<K> indexer = new Indexer<>();
    for (Index<K> index : plate.indices()) 
      indexer.addToIndex(index.key); 
    return indexer;
  }
  
  public static class Diagonal<K> implements Precision<K>
  {
    final RealVar diagonalPrecisionValue;
    final Plate<K> plate;
    final int dim;
    
    public Diagonal(RealVar diagonalPrecisionValue, Plate<K> plate) 
    {
      this.plate = plate;
      this.dim = plate.indices().size();
      this.diagonalPrecisionValue = diagonalPrecisionValue;
    }

    @Override
    public Set<UnorderedPair<K, K>> support() 
    {
      Set<UnorderedPair<K, K>> result = new LinkedHashSet<>();
      for (Index<K> index : plate.indices())
        result.add(UnorderedPair.of(index.key, index.key));
      return result;
    }

    @Override
    public double logDet() 
    {
      return dim * Math.log(diagonalPrecisionValue.doubleValue());
    }

    @Override
    public double get(UnorderedPair<K, K> entry) 
    {
      return diagonalPrecisionValue.doubleValue();
    }

    @Override
    public Plate<K> getPlate() {
      return plate;
    }
    
  }
}
