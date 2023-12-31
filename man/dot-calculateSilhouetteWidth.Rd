% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/buildAvgLoading.R
\name{.calculateSilhouetteWidth}
\alias{.calculateSilhouetteWidth}
\title{Calculate Silhouette Information of RAVs}
\usage{
.calculateSilhouetteWidth(dat, kmeansRes)
}
\arguments{
\item{dat}{A matrix with all the top PCs from training data to be clustered.}

\item{kmeansRes}{Output from \code{stats::kmeans}.}
}
\value{
Silhouette-class object, which is an n x 3 matrix with attributes.
}
\description{
The silhouette value is a measure of how similar an object is
to its own cluster (cohesion) compared to other clusters (separation). The
silhouette width ranges from -1 to +1, where a high value indicates that
the object is well matched to its own cluster and poorly matched to
neighboring clusters.
}
\seealso{
\code{\link[stats]{kmeans}}
}
\keyword{internal}
