package blang.runtime.internals.doc.components

import java.io.File
import java.util.Collection
import briefj.BriefIO

class BootstrapHTMLRenderer {
  
  val String siteName
  val Collection<Document> documents
  
  new(String siteName, Collection<Document> documents) {
    this.siteName = siteName
    this.documents = documents
  }
  
  def void renderInto(File folder) {
    for (Document document : documents) {
      val File file = new File(folder, document.fileName)
      BriefIO.write(file, render(document))
    }
  } 
  
  def protected dispatch String render(Document document) {
    currentDepth = 1
    return '''
      <!DOCTYPE html>
      <!-- Warning This page was generated by «this.class.name». Do not edit directly! -->
      <html lang="en">
        «header(document)»
        <body>
          <div class="container">
            «navBar(document)»
            «recurse(document)»
          </div>
          <!-- Placed at the end of the document so the pages load faster -->
          <script src="https://ajax.googleapis.com/ajax/libs/jquery/1.12.4/jquery.min.js"></script>
          <script>window.jQuery || document.write('<script src="assets/js/vendor/jquery.min.js"><\/script>')</script>
          <script src="dist/js/bootstrap.min.js"></script>
        </body>
      </html>
    '''
  }
  
  def protected dispatch String render(Bullets bullets) {
    val String tag = if (bullets.ordered) "ol" else "ul"
    return '''
    <«tag»>
      «FOR child : bullets.children»
        <li>
          «render(child)»
        </li>
      «ENDFOR»
    </«tag»>
    '''
  }
  
  def protected dispatch String render(Object object) {
    object.toString
  }
  
  var Integer currentDepth = null
  def protected dispatch String render(Section section) {
    if (currentDepth > 6) {
      throw new RuntimeException("Max section depth is 6.")
    }
    val int depth = currentDepth++
    '''
    <h«depth»>«section.name»</h«depth»>
    «recurse(section)»
    '''
  }
  
  def protected String recurse(DocElement element) {
    '''
    «FOR child : element.children»
      «render(child)»
    «ENDFOR»
    '''
  }
  
  def private navBar(Document document) {
    '''
    <div class="header clearfix">
            <nav>
              <ul class="nav nav-pills pull-right">
                «FOR menuItem : documents»
                  «navLink(menuItem, menuItem === document)»
                «ENDFOR»
              </ul>
            </nav>
            <h3 class="text-muted">«siteName»</h3>
          </div>
    '''
  }
  
  def private navLink(Document menuItem, boolean isActive) {
    '''
    <li role="presentation"«IF isActive» class="active"«ENDIF»>
      <a href="«menuItem.fileName»">«menuItem.name»</a>
    </li>
    '''
  }
  
  def private header(Document document) {
    '''
      <head>
        <meta charset="utf-8">
        <meta http-equiv="X-UA-Compatible" content="IE=edge">
        <meta name="viewport" content="width=device-width, initial-scale=1">
        <!-- The above 3 meta tags *must* come first in the head; any other head content must come *after* these tags -->
        <meta name="description" content="Blang documentation">
    
        <title>«document.name»</title>
    
        <link href="https://fonts.googleapis.com/css?family=Roboto" rel="stylesheet">
      
        <!-- Bootstrap core CSS -->
        <link href="dist/css/bootstrap.min.css" rel="stylesheet">
    
        <!-- Custom styles for this template -->
        <link href="jumbotron-narrow.css" rel="stylesheet">
    
        <!-- HTML5 shim and Respond.js for IE8 support of HTML5 elements and media queries -->
        <!--[if lt IE 9]>
          <script src="https://oss.maxcdn.com/html5shiv/3.7.3/html5shiv.min.js"></script>
          <script src="https://oss.maxcdn.com/respond/1.4.2/respond.min.js"></script>
        <![endif]-->
      </head>
    '''
  }
  
  def static String fileName(Document document) {
    document.name.replaceAll(" ", "_") + ".html"
  }
}