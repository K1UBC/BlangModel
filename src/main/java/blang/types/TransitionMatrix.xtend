package blang.types

import org.eclipse.xtend.lib.annotations.Data
import xlinear.DenseMatrix
import org.eclipse.xtend.lib.annotations.Delegate

@Data class TransitionMatrix implements DenseMatrix {
  
  @Delegate
  val DenseMatrix probabilities
  
  override Simplex row(int i) {
    return new Simplex(probabilities.row(i))
  }
  
}