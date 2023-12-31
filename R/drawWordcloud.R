#' Extract the list of PCs in a cluster
#'
#' A RAV model contain clusters of PCs from individual
#' studies. This function extracts the names of the original
#' PCs from the RAV model given the index in the RAV model.
#'
#' @param RAVmodel A PCAGenomicSignatures object
#' @param ind An index of RAV
#'
#' @return A character vector of PC/study names
#'
#' @examples
#' data(miniRAVmodel)
#' PCinRAV(miniRAVmodel,695)
#'
#' @export
PCinRAV <- function(RAVmodel, ind) {

    ## Switching metadata structure of RAVmodel
    if (version(RAVmodel) == ">= 0.0.7" | version(RAVmodel) == ">= 0.0.6") {
        cluster <- S4Vectors::metadata(RAVmodel)$cluster
        k <- which(cluster == ind)
        out <- names(k)
    } else {
        ##### update with RAVmodel restructure #####
        # cluster <- colData(RAVmodel)$cluster
        # out <- cluster[[paste0("RAV", ind)]]
        cluster <- S4Vectors::metadata(RAVmodel)$cluster
        k <- which(cluster == ind)
        out <- names(k)
    }

    return(out)
}


#' Build a two-column word/frequency table
#'
#' @import dplyr
#' @importFrom S4Vectors metadata
#'
#' @param RAVmodel A PCAGenomicSignatures object
#' @param ind An index of RAV
#' @param rm.noise An integer. Under the default (\code{rm.noise=NULL}), if
#' cluster size (= \code{s}) is smaller than 8, \code{rm.noise = floor(s*0.5)}.
#' For clusters with >= 8 PCs, \code{rm.noise = 4}. If \code{rm.noise = 0}, all
#' the MeSH terms in RAV will be used to draw wordcloud.
#' @param weighted A logical. If \code{TRUE}, MeSH terms from each study are
#' weighted based on the variance explained by the principle component of the
#' study contributing a give RAV. Default is \code{TRUE}.
#' @param filterMessage A logical. Under the default \code{TRUE}, any output
#' RAV belong to the filtering list will give a message. Silence this message
#' with \code{filterMessage=FALSE}. You can check the filter list using
#' \code{data("filterList")}.
#'
#' @return A table with two columns, \code{word} and \code{freq}. MeSH terms in
#' the defined RAV (by \code{ind} argument) is ordered based on their frequency.
#'
#' @examples
#' data(miniRAVmodel)
#' meshTable(miniRAVmodel,1139)
#'
#' @export
meshTable <- function(RAVmodel, ind, rm.noise = NULL,
                      weighted = TRUE, filterMessage = TRUE) {
    
    ### Check ind validity for meshTable
    if (length(ind) != 1) {stop("Provide only one index.")}
    if (ind %% 1 != 0) {stop("`ind` should be integer.")}

    ### Check ind validity
    .availableRAV(RAVmodel, ind)

    ### Check the RAV quality
    .lowQualityRAVs(RAVmodel, ind, filterMessage)

    ### Remove noise
    if (is.null(rm.noise)) {
        s <- S4Vectors::metadata(RAVmodel)$size[paste0("RAV", ind)]
        # s <- colData(RAVmodel)$size[paste0("RAV", ind)] ## update with RAVmodel restructure
        if (s < 8) {rm.noise <- floor(s*0.5)}
        else if (s >= 8) {rm.noise <- 4}
    }

    ### Create a 'universe' for bag-of-words model
    # frequency of the `name` in the background
    bow <- unlist(S4Vectors::metadata(RAVmodel)$MeSH_freq)
    # remove rare terms
    bow <- bow[which(bow > rm.noise)]

    ### Not weighted version
    if (weighted == FALSE) {
        ind_name <- paste0("Cl", metadata(RAVmodel)$k, "_", ind)
        study_id <- studies(RAVmodel)[[ind_name]]   # a list of studies in RAV
        all_MeSH <- mesh(RAVmodel)   # all the MeSH data

        # remove SRP069088 (no MeSH term)
        if ("SRP069088" %in% study_id) {
            ind_rm <- which(study_id == "SRP069088")
            PCs <- PCs[-ind_rm]
            var <- var[,-ind_rm]
            study_id <- study_id[-ind_rm]
        }

        # subset to the participating studies
        mesh_subset <- all_MeSH[study_id]

        ### Combine all MeSH words
        d <- list()
        for (i in seq_along(mesh_subset)) {
            d <- c(d, mesh_subset[[i]]$name)
        }

        ### Build a term-frequency table
        summary <- unlist(d)
        summary <- table(summary)
        summary <- summary[names(summary) %in% names(bow)]

    ### Weighted based on variance explained by PC
    } else {
        PCs <- PCinRAV(RAVmodel, ind)
        varAll <- Reduce(cbind, PCAsummary(RAVmodel))
        var <- varAll[,PCs,drop=FALSE]
        study_id <- gsub("\\.PC.*$", "", PCs)
        all_MeSH <- mesh(RAVmodel)   # all the MeSH data

        # remove SRP069088 (no MeSH term)
        if ("SRP069088" %in% study_id) {
            ind_rm <- which(study_id == "SRP069088")
            PCs <- PCs[-ind_rm]
            var <- var[,-ind_rm]
            study_id <- study_id[-ind_rm]
        }

        mesh_subset <- sapply(all_MeSH[study_id], function(x) {x$name})

        weight <- as.data.frame(matrix(nrow = 0, ncol = 3))
        colnames(weight) <- c("PCs", "var", "mesh")

        for (i in seq_along(PCs)) {
            new <- data.frame(PCs = PCs[i],
                             var = var["Variance", i],
                             mesh = mesh_subset[[i]])
            weight <- rbind(weight, new)
        }

        weight <- weight %>% group_by(mesh) %>% summarise(total_var = sum(var))

        ### Build a term-frequency table
        summary <- stats::setNames(weight$total_var, as.character(weight$mesh))
        summary <- summary[names(summary) %in% names(bow)]
    }

    for (i in seq_along(summary)) {
        summary[i] <- summary[i]/bow[names(summary[i])]
    }
    all <- as.data.frame(matrix(NA, ncol = 0, nrow = length(summary)))
    all$word <- names(summary)
    all$freq <- summary
    all <- all[order(all$freq, decreasing = TRUE),]

    return(all)
}


#' @title Draw wordcloud using the collection of RAVs' MeSH terms
#' @description Plot a word cloud using the remaining MeSH terms in the selected
#' RAV after user-defined filtering.
#'
#' @param RAVmodel PCAGenomicSignatures object
#' @param ind An index of the RAV you want to draw wordcloud.
#' @param rm.noise An integer. Under the default (\code{rm.noise=NULL}), if
#' cluster size (= \code{s}) is smaller than 8, \code{rm.noise = floor(s*0.5)}.
#' For clusters with >= 8 PCs, \code{rm.noise = 4}. If \code{rm.noise = 0}, all
#' the MeSH terms in RAV will be used to draw wordcloud.
#' @param scale A \code{scale} argument for \code{\link[wordcloud]{wordcloud}}
#' function
#' @param weighted A logical. If \code{TRUE} (default), MeSH terms from each
#' study are weighted based on the variance explained by the principle component
#' of the study contributing to a given RAV.
#' @param drop A character vector containing MeSH terms to be excluded from word
#' cloud. Under the default (\code{NULL}), manually selected non-informative
#' MeSH terms are excluded, which can be viewed through \code{data(droplist)}.
#' @param filterMessage A logical. Under the default \code{TRUE}, any output
#' RAV belong to the filtering list will give a message. Silence this message
#' with \code{filterMessage=FALSE}. You can check the filter list using
#' \code{data("filterList")}.
#'
#' @return A word cloud with the MeSH terms associated with the given cluster.
#'
#' @examples
#' data(miniRAVmodel)
#' drawWordcloud(miniRAVmodel, 1139)
#'
#' @export
drawWordcloud <- function(RAVmodel, ind, rm.noise = NULL, scale = c(3, 0.5),
                          weighted = TRUE, drop = NULL, filterMessage = TRUE) {

    # Check ind validity
    .availableRAV(RAVmodel, ind)

    # Check the RAV quality
    .lowQualityRAVs(RAVmodel, ind, filterMessage)

    if (is.null(rm.noise)) {
        s <- S4Vectors::metadata(RAVmodel)$size[paste0("RAV", ind)]
        # s <- colData(RAVmodel)$size[paste0("RAV", ind)] ## update with RAVmodel restructure
        if (s < 8) {rm.noise <- floor(s*0.5)}
        else if (s >= 8) {rm.noise <- 4}
    }

    # MeSH word table
    all <- meshTable(RAVmodel, ind, rm.noise = rm.noise,
                     weighted = weighted, filterMessage = FALSE)

    # Remove enriched MeSH term if it is in 'droplist'
    if (!is.null(drop)) {
        droplist <- drop
    } else {
        local_data_store <- new.env(parent = emptyenv())
        data("droplist", envir = local_data_store, package = "GenomicSuperSignature")
        droplist <- local_data_store[["droplist"]]
    }
    drop_ind <- which(all$word %in% droplist)
    if (length(drop_ind) != 0) {all <- all[-drop_ind,]}
    if (nrow(all) == 0) {stop("No MeSH term is enriched.")}

    # generate the word cloud
    wordcloud::wordcloud(words = all$word, freq = all$freq, scale = scale,
                         max.words = Inf, random.order = FALSE, rot.per = 0,
                         colors = RColorBrewer::brewer.pal(8, "Dark2"))
}
