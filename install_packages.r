
myinstall<-function(packageName, isBioc){
  if(!packageName %in% installed.packages()){
    cat("Installing", packageName, "\n", file=stderr())
    if(isBioc){
      biocLite(packageName)
    }else{
      install.packages("RColorBrewer",repos="http://cran.us.r-project.org")
    }
  }
}

myinstall("RColorBrewer", 0)
myinstall("Rcpp", 0)
myinstall("VennDiagram", 0)
myinstall("ggplot2", 0)
myinstall("grid", 0)
myinstall("heatmap3", 0)
myinstall("lattice", 0)
myinstall("reshape", 0)
myinstall("reshape2", 0)
myinstall("scales", 0)

source("https://bioconductor.org/biocLite.R")
myinstall("DESeq2", 1)
myinstall("edgeR", 1)
