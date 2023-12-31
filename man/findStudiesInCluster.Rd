% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/findStudiesInCluster.R
\name{findStudiesInCluster}
\alias{findStudiesInCluster}
\title{Find the studies contributing each RAV}
\usage{
findStudiesInCluster(RAVmodel, ind = NULL, studyTitle = FALSE)
}
\arguments{
\item{RAVmodel}{PCAGenomicSignatures object.}

\item{ind}{A numeric vector containing the RAV indexes. Under the default
(\code{NULL}), studies associated with all the RAV indexes will be returned
as a list.}

\item{studyTitle}{Default is \code{FALSE}. This parameter is effective only when
the \code{index} value is specificed. If it's \code{TRUE}, the output will be
a data frame with the study}
}
\value{
A list of character vectors. Under the default condition
(\code{ind = NULL}), all the RAVs will be checked for their contributing
studies and the length of the list will be same as the number of RAVs
(= \code{metadata(x)$k}). If you provide the \code{ind} argument, studies
associated with only the specified RAVs will be returned.
}
\description{
Find the studies contributing each RAV
}
\note{
Mainly used for model building, within \link{buildAvgLoading}.
}
\examples{
data(miniRAVmodel)
findStudiesInCluster(miniRAVmodel, 1076)

}
