package blang.runtime.internals.doc.contents

import blang.runtime.internals.doc.components.Document
import blang.runtime.internals.doc.Categories

class InferenceAndRuntime {
  
  public val static Document page = new Document("Inference and runtime") [
    category = Categories::reference
    section("Inference and runtime: overview") [
      it += '''
        The runtime system is responsible for loading data and performing Bayesian inference 
        based on that data. We seek to make inference correct, general, automated and efficient 
        (prioritized in that order): 
      '''
      orderedList[
        it += '''
          «EMPH»correctness«ENDEMPH» is approached using a comprehensive suite of tests«ENDLINK» based on 
          Monte Carlo theory combined with software engineering methodology;
        '''
        it += '''
          «EMPH»generality«ENDEMPH» is provided with an open type system and facilities to 
          quickly develop and test sampling algorithms for new types;
        '''
        it += '''
          «EMPH»automation«ENDEMPH» is based on inference algorithms that remove the need for 
          careful initialization of models as well as an injection framework to ease data loading 
          and conditioning;
        '''
        it += '''
          «EMPH»efficiency«ENDEMPH» is addressed by built-in support for correct and reproducible 
          parallel execution, automatic detection of sparsity structure, and innovative sampling 
          engines bases on non-reversible Monte Carlo methods. 
        '''
      ]
      it += '''
        The tools for «LINK(Testing::page)»testing«ENDLINK» and 
        «LINK(CreatingTypes::page)»creating new types«ENDLINK» are described in their own pages. 
        We describe here the inner workings of Blang's automatic, efficient inference machinery in 
        this page. This can be skipped at first reading. 
      '''
    ]
    
    section("Automatic discovery of sparsity patterns") [
      it += '''
        After instantiation of the model variables (which includes executing the default initialization 
        blocks of unspecified variables), the Blang runtime performs the following tasks: 
      '''
      unorderedList[
        it += '''
          Instantiation of a list «MATH»l«ENDMATH» of «SYMB»blang.core.Factor«ENDSYMB»s. The list «MATH»l«ENDMATH» 
          is populated recursively as follows:
        ''' 
        unorderedList[
          it += '''
            For each «SYMB»blang.core.Model«ENDSYMB» encountered (starting at the root model), execute the code generated by the 
            laws block of the Blang model.
            The code is in a method called «SYMB»components«ENDSYMB», which returns a collection «MATH»c«ENDMATH» of 
            «SYMB»blang.core.ModelComponent«ENDSYMB»s an interface that encompasses 
            «SYMB»blang.core.Model«ENDSYMB» and «SYMB»blang.core.Factor«ENDSYMB».
            
            For each item «MATH»i«ENDMATH» in this collection «MATH»c«ENDMATH»,
          '''
          unorderedList[
            it += '''
              If «MATH»i«ENDMATH» is of type «SYMB»blang.core.Factor«ENDSYMB», add «MATH»i«ENDMATH» 
              to «MATH»l«ENDMATH». 
              This case usually corresponds to the code generated by 
              a «SYMB»logf(...) { ... }«ENDSYMB» or «SYMB»indicator(...)  { ... }«ENDSYMB» block, 
              in both cases the generated factor will be a 
              subtype of the subinterface «SYMB»blang.core.LogScaleFactor«ENDSYMB». 
              It may also occur by a statement of the form «SYMB»variable is Constrained«ENDSYMB», 
              in which case the instantiated object is «SYMB»blang.core.Constrained«ENDSYMB».
            '''
            it += '''
              If «MATH»i«ENDMATH» is of type «SYMB»blang.core.Model«ENDSYMB», the present procedure 
              is invoked to obtained a list «MATH»l'«ENDMATH», the elements of which are all added 
              to the present list «MATH»l«ENDMATH».
            '''
          ]
        ]
        it += '''
          Identification of the «EMPH»latent variables«ENDEMPH» (unobserved random variables);
        '''
        it += '''
          
        '''
      ]
      it += '''
        Collectively, we call these tasks the «EMPH»graph analysis«ENDEMPH» of the Blang model. 
      
          (RE)MOVE THE FOLLOWING - FACTOR GRAPH NOT USEFUL
        
        Recall that the factor graph is a bipartite graph where vertices are either 
        , or «EMPH»factors«ENDEMPH».
        The posterior probability of interest is proportional to the product of the probabilities 
        across all the factors (in log scale for numerical reasons).         
        
        As a first step towards constructing the factor graph, the Blang runtime builds an «EMPH»accessibility graph«ENDEMPH» 
        from the instantiated Blang model. In an accessibility graph, vertices are defined as the union of objects 
        and of the constituents of these objects.
        Constituents are fields in the case of objects and integer indices in the 
        case of arrays. 
        A field can be skipped in the construction of the accessibility graph 
        using the annotation «SYMB»@SkipDependency«ENDSYMB».
        Constitutents can also be custom constituents, as we describe later. 
        The (directed) edges of the accessibility graph connect  
        objects to their constituents, and constituents to the object they resolve 
        to, if any. For example, a field might resolve to another object, or to null or a primitive in 
        which case no edge is created. We say that an object «SYMB»o2«ENDSYMB» is «EMPH»accessible«ENDEMPH» 
        from «SYMB»o1«ENDSYMB» if there is a directed path from «SYMB»o1«ENDSYMB» to «SYMB»o2«ENDSYMB».
        
        The latent variables are extracted from the vertex set of the accessibility graph as the intersection 
        of:
      '''
      unorderedList[
        it += '''
          objects of a type annotated with «SYMB»@Samplers«ENDSYMB» (more precisely, object where the class 
          itself, a superclass, or 
          an implemented interface has the annotation «SYMB»@Samplers«ENDSYMB»); 
        '''
        it += '''
          objects that are «EMPH»mutable«ENDEMPH», or have an accessible mutable children. 
          Mutability is defined as follows.
        '''
        unorderedList[          
          it += '''
            By default, 
            mutability corresponds to accessibility of non-final fields (in Java, fields not marked with the 
            «SYMB»final«ENDSYMB» keyword, in Xtend, fields marked with «SYMB»var«ENDSYMB») or arrays. 
            This behaviour can be overwritten with the annotation «SYMB»@Immutable«ENDSYMB»;
          '''
          it += '''
            To get finer control on mutability, a designated «SYMB»Observations«ENDSYMB» object can be used 
            to mark individual as observed. For example, this can be used to mark an individual entry 
            of a matrix as observed, using «SYMB»observationsObject.markAsObserved(matrix.getRealVar(i, j))«ENDSYMB». 
            An instance of the Observations object is typically obtained via injection, as described in the 
            «LINK(InputOutput::page)»input output page«ENDLINK». When a node is marked as observed, so is all 
            of its accessible children.
          '''
        ]
      ]
      it += '''
        TODO: conn between factor and variables
        TODO: make clear factors are all the logf  or 'is X'
        TODO: construction of the seqeuence of measures
        TODO: matching samplers
      '''
    ]
    
    // basic graph analysis
    
    // how tempering is done (finding prior, likelihood, support, etc)
    
    // sequential change of measure
    
    // advanced graph analysis   
  ]
  
}