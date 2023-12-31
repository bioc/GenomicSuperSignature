#' @include GenomicSignatures-class.R


#' @title Formatting RAV name
#'
#' @description Keep the name with 'k + cluster number + number of PCs + number
#' of unique studies' info during the model construction to make it easy to keep
#' track of them, but at the PCAGenomicSignatures-class object building step,
#' covert them into 'RAV + cluster number'.
#'
#' @param x PCAGenomicSignatures object
#' @param ... Additional arguments for supporting functions.
#'
#' @return a character vector
#' 
#' @keywords internal
#'
.RAVName <- function(x, ...) {
    rownames(x@colData) <- paste0("RAV", seq_len(ncol(x)))
    x@colData$RAV <- rownames(x@colData)
    return(x)
}


### ==============================================
### PCAGenomicSignatures Constructor
### ==============================================
#' @name PCAGenomicSignatures
#' @title Construct \code{PCAGenomicSignatures} object
#'
#' @description The default contents of \code{PCAGenomicSignatures} object, with
#' a set of accessors and setter generic functions, which extract either the
#' \code{assay}, \code{colData}, \code{metadata}, or \code{trainingData} slots
#' of a \code{\link{PCAGenomicSignatures-class}} object. When you create this
#' object, \code{colData$studies} should be populated before adding any
#' information in \code{trainingData} slot
#'
#' @details
#' \itemize{
#'     \item RAVindex(x) : RAVindex (= avgLoadings) containing genes x RAVs
#'     \item metadata(x)$cluster : A vector of integers (from 1:k) indicating
#'     the cluster to which each point is allocated.
#'     \item metadata(x)$size : The number of PCs in each cluster.
#'     \item metadata(x)$k : The number of RAVs.
#'     \item metadata(x)$n : The number of top PCs from each dataset.
#'     \item metadata(x)$geneSets : Name of the prior gene sets used to annotate
#'     average loadings.
#'     \item colData(x)$studies : A list of character vectors containing studies
#'     contributing to each PC cluster.
#'     \item colData(x)$silhouetteWidth : A numeric array of average silhouette
#'     widths of each clusters
#'     \item colData(x)$gsea : A list of data frames. Each element is a subset
#'     of outputs from \code{clusterProfiler::GSEA} function.
#' }
#'
#' @section Setters:
#' Setter method values (i.e., \code{function(x) <- value}):
#' \itemize{
#'     \item geneSets<- : A character vector containing the name of gene sets
#'     used to annotate average loadings
#'     \item studies<- : A list of character vectors containing gene sets used
#'     to annotate average loadings
#'     \item gsea<- : A list of data frames. Each element is a subset of output
#'     from \code{gseaResult} objects.
#'     \item metadata<- : A \code{list} object of metadata
#'     \item `$<-` : A vector to replace the indicated column in \code{colData}
#' }
#'
#' @section Accessors:
#' All the accessors inherited from \code{SummarizedExperiment} are available
#' and the additional accessors for \code{PCAGenomicSignatures} specific data
#' are listed below.
#' \itemize{
#'    \item RAVindex : Equivalent to the \code{assay(x)}
#'    \item geneSets : Access the \code{metadata(x)$geneSets} slot
#'    \item studies : Access the \code{colData(x)$studies} slot
#'    \item gsea : Access the \code{colData(x)$gsea}
#'    \item `$` : Access a column in \code{colData}
#'    \item trainingData : Access the \code{trainingData} slot
#'    \item mesh : Access the \code{trainingData(x)$MeSH} slot
#'    \item PCAsummary : Access the \code{trainingData(x)$PCAsummary} slot
#' }
#'
#' @slot trainingData A \code{\link[S4Vectors]{DataFrame}} class object for
#' metadata associated with training data
#'
#' @param trainingData A \code{\link[S4Vectors]{DataFrame}} class object for
#' metadata associated with training data
#' @param ... Additional arguments for supporting functions.
#' @return PCAGenomicSignatures object with multiple setters or accessors
#'
#' @examples
#' data(miniRAVmodel)
#' miniRAVmodel
#'
#' @export
PCAGenomicSignatures <- function(..., trainingData)
{
    se <- SummarizedExperiment::SummarizedExperiment(...)
    .RAVName(se) #--> Move this to the model_building process instead
    gs <- .PCAGenomicSignatures(se, trainingData = trainingData)
}


#' @name PCAGenomicSignatures-methods
#' @title Methods and accesors for \code{PCAGenomicSignatures} object
#'
#' @description The default contents of \code{PCAGenomicSignatures} object, with
#' a set of accessor and setter generic functions, which extract either the
#' \code{assay}, \code{colData}, \code{metadata}, or \code{trainingData} slots
#' of a \code{\link{PCAGenomicSignatures-class}} object. When you create this
#' object, \code{colData$studies} should be populated before adding any
#' information in \code{trainingData} slot
#'
#' @details
#' \itemize{
#'     \item RAVindex(x) : RAVindex (= avgLoadings) containing genes x RAVs
#'     \item metadata(x)$cluster : A vector of integers (from 1:k) indicating
#'     the cluster to which each PC is allocated.
#'     \item metadata(x)$size : The number of PCs in each cluster.
#'     \item metadata(x)$k : The number of RAVs.
#'     \item metadata(x)$n : The number of top PCs from each dataset.
#'     \item metadata(x)$geneSets : Name of the prior gene sets used to annotate
#'     average loadings.
#'     \item colData(x)$studies : A list of character vectors containing studies
#'     contributing to each PC cluster.
#'     \item colData(x)$gsea : A list of data frames. Each element is a subset
#'     of outputs from \code{clusterProfiler::GSEA} function.
#' }
#'
#' @section Setters:
#' Setter method values (i.e., \code{function(x) <- value}):
#' \itemize{
#'     \item geneSets<- : A character vector containing the name of gene sets
#'     used to annotate average loadings
#'     \item studies<- : A list of character vectors containing gene sets used
#'     to annotate average loadings
#'     \item gsea<- : A list of \code{gseaResult} objects.
#'     \item metadata<- : A \code{list} object of metadata
#'     \item `$<-` : A vector to replace the indicated column in \code{colData}
#' }
#'
#' @section Accessors:
#' All the accessors inherited from \code{SummarizedExperiment} are available
#' and the additional accessors for \code{PCAGenomicSignatures} specific data
#' are listed below.
#' \itemize{
#'    \item RAVindex : Equivalent to the \code{assay(x)}
#'    \item geneSets : Access the \code{metadata(x)$geneSets} slot
#'    \item studies : Access the \code{colData(x)$studies} slot
#'    \item gsea : Access the \code{colData(x)$gsea}
#'    \item `$` : Access a column in \code{colData}
#'    \item trainingData : Access the \code{trainingData} slot
#'    \item mesh : Access the \code{trainingData(x)$MeSH} slot
#'    \item PCAsummary : Access the \code{trainingData(x)$PCAsummary} slot
#' }
#'
#' @slot trainingData A \code{\link[S4Vectors]{DataFrame}} class object for
#' metadata associated with training data
#'
#' @param object,x A \code{PCAGenomicSignatures} object
#' @param value See details.
#'
#' @examples
#' data(miniRAVmodel)
#' miniRAVmodel
#'
#' @return PCAGenomicSignatures object with multiple setters or accessors
#' @aliases studies<- silhouetteWidth<- gsea<- trainingData<- mesh<-
#' PCAsummary<- studies silhouetteWidth gsea trainingData mesh PCAsummary
NULL

### ==============================================
### Setter
### ==============================================
#' @export
setGeneric("studies<-", function(x, value) standardGeneric("studies<-"))

#' @exportMethod studies<-
#' @rdname PCAGenomicSignatures-methods
setMethod("studies<-", "PCAGenomicSignatures", function(x, value) {
    x@colData$studies <- value
    allStudies <- unlist(value)
    allStudies <- unique(allStudies)
    
    if (!all(allStudies %in% row.names(x@trainingData))) {
        stop("Studies do not match with the training datasets.")
    }
    # x@trainingData <- S4Vectors::DataFrame(row.names = allStudies) 
    # validObject(x)
    return(x)
})


#' @export
setGeneric("silhouetteWidth<-",
           function(x, value) standardGeneric("silhouetteWidth<-"))

#' @exportMethod silhouetteWidth<-
#' @rdname PCAGenomicSignatures-methods
setMethod("silhouetteWidth<-", "PCAGenomicSignatures", function(x, value) {
    x@colData$silhouetteWidth <- value
    return(x)
})


#' @export
setGeneric("gsea<-", function(x, value) standardGeneric("gsea<-"))

#' @exportMethod gsea<-
#' @rdname PCAGenomicSignatures-methods
setMethod("gsea<-", "PCAGenomicSignatures", function(x, value) {
    x@colData$gsea <- value
    return(x)
})


#' @export
setGeneric("trainingData<-",
           function(x, value) standardGeneric("trainingData<-"))

#' @exportMethod trainingData<-
#' @rdname PCAGenomicSignatures-methods
setMethod("trainingData<-", "PCAGenomicSignatures", function(x, value) {
    x@trainingData <- value
    # validObject(x)
    return(x)
})


#' @export
setGeneric("mesh<-", function(x, value) standardGeneric("mesh<-"))

#' @exportMethod mesh<-
#' @rdname PCAGenomicSignatures-methods
setMethod("mesh<-", "PCAGenomicSignatures", function(x, value) {
    trainingData(x)$MeSH <- NA
    for (i in seq_along(value)) {
        ind <- which(rownames(trainingData(x)) == names(value[i]))
        trainingData(x)$MeSH[ind] <- value[i]
    }
    names(trainingData(x)$MeSH) <- rownames(trainingData(x))
    return(x)
})


#' @export
setGeneric("PCAsummary<-", function(x, value) standardGeneric("PCAsummary<-"))

#' @exportMethod PCAsummary<-
#' @rdname PCAGenomicSignatures-methods
setMethod("PCAsummary<-", "PCAGenomicSignatures", function(x, value) {
    trainingData(x)$PCAsummary <- NA
    for (i in seq_along(value)) {
        ind <- which(rownames(trainingData(x)) == names(value[i]))
        trainingData(x)$PCAsummary[ind] <- value[i]
    }
    names(trainingData(x)$PCAsummary) <- rownames(trainingData(x))
    return(x)
})



### ==============================================
### Getter
### ==============================================
#' @export
setGeneric("studies", function(x) standardGeneric("studies"))

#' @exportMethod studies
#' @rdname PCAGenomicSignatures-methods
setMethod("studies", "PCAGenomicSignatures", function(x) {
    out <- x@colData$studies
    return(out)
})


#' @export
setGeneric("silhouetteWidth", function(x) standardGeneric("silhouetteWidth"))

#' @exportMethod silhouetteWidth
#' @rdname PCAGenomicSignatures-methods
setMethod("silhouetteWidth", "PCAGenomicSignatures", function(x) {
    out <- x@colData$silhouetteWidth
    return(out)
})


#' @export
setGeneric("gsea", function(x) standardGeneric("gsea"))

#' @exportMethod gsea
#' @rdname PCAGenomicSignatures-methods
setMethod("gsea", "PCAGenomicSignatures", function(x) {
    out <- x@colData$gsea
    return(out)
})


#' @export
setGeneric("trainingData", function(x) standardGeneric("trainingData"))

#' @exportMethod trainingData
#' @rdname PCAGenomicSignatures-methods
setMethod("trainingData", "PCAGenomicSignatures", function(x) {
    out <- x@trainingData
    return(out)
})


#' @export
setGeneric("mesh", function(x) standardGeneric("mesh"))

#' @exportMethod mesh
#' @rdname PCAGenomicSignatures-methods
setMethod("mesh", "PCAGenomicSignatures", function(x) {
    out <- x@trainingData$MeSH
    return(out)
})


#' @export
setGeneric("PCAsummary", function(x) standardGeneric("PCAsummary"))

#' @exportMethod PCAsummary
#' @rdname PCAGenomicSignatures-methods
setMethod("PCAsummary", "PCAGenomicSignatures", function(x) {
    out <- x@trainingData$PCAsummary
    return(out)
})



### ==============================================
### Show method
### ==============================================
#' @exportMethod show
#' @rdname PCAGenomicSignatures-methods
setMethod("show", "PCAGenomicSignatures", function(object) {
    callNextMethod()

    colnames <- colnames(trainingData(object))
    S4Vectors::coolcat("trainingData(%d): %s\n", colnames)

    rownames <- rownames(trainingData(object))
    S4Vectors::coolcat("trainingData names(%d): %s\n", rownames)
})

