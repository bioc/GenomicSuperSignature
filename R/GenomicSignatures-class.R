### ==============================================
### GenomicSignatures-Class
### ==============================================
#' GenomicSignatures
#' @name GenomicSignatures-class
#' @title Virtual class inherited from SummarizedExperiment
#'
#' @description GenomicSignatures is a virtual class inherited from
#' SummarizedExperiment and hosts GenomicSignatures models built from different
#' dimensional reduction methods. Currently, PCA-based model, called
#' PCAGenomicSignatures, is available.
#'
#' @param x A \code{GenomicSignatures-class} object
#' @param value See details.
#'
#' @import SummarizedExperiment
#' @docType class
#' @exportClass GenomicSignatures
setClass("GenomicSignatures",
         contains = c("SummarizedExperiment", "VIRTUAL")
)

### ==============================================
### PCAGenomicSignatures-Class
### ==============================================
#' PCAGenomicSignatures
#' @name PCAGenomicSignatures-class
#' @title PCAGenomicSignatures-class
#'
#' @description PCA-based \code{\link{GenomicSignatures-class}}.
#'
#' @slot trainingData A \code{\link[S4Vectors]{DataFrame}} class object for
#' metadata associated with training data
#' @param x A \code{GenomicSignatures-class} object
#' @param value See details.
#'
#' @docType class
#'
#' @examples
#' data(miniRAVmodel)
#' miniRAVmodel
#'
#' @exportClass PCAGenomicSignatures
.PCAGenomicSignatures <- setClass("PCAGenomicSignatures",
         slots = list(
             trainingData = "DataFrame" 
         ),
         contains = "GenomicSignatures"
)
