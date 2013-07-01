#' Mosaic Displays for a glmlist Object

#' @param x    a glmlist object
#' @param selection the index or name of one glm in \code{x}
#' @param type      a character string indicating whether the \code{"observed"} or the \code{"expected"} values of the table should be visualized
#' @param legend    show a legend in the mosaic displays?
#' @param main      either a logical, or a vector of character strings used for plotting the main title. If main is a logical and TRUE, the name of the selected glm object  is used
#' @param ask  should the function display a menu of models, when one is not specified in \code{selection}?
#' @param graphics  use a graphic menu when \code{ask=TRUE}?
#' @param rows,cols when \code{ask=FALSE}, the number of rows and columns in which to plot the mosaics
#' @param newpage   start a new page? (only applies to \code{ask=FALSE})
#' @param ...       other arguments passed to \code{\link{mosaic.glm}}
#' @export

mosaic.glmlist <- function(x, selection,
  type=c("observed", "expected"), 
	legend=FALSE, main=NULL,
	ask=TRUE, graphics=TRUE, rows, cols, newpage=TRUE,
	 ...) {

	calls <- sapply(x, mod.call)  # get model calls as strings
	models <- names(x)
  if (!is.null(main)) {
      if (is.logical(main) && main) 
          main <- models
  }
  else main <- rep(main, length(x))
 

  type=match.arg(type)
	if (!missing(selection)){
#		if (is.character(selection)) selection <- gsub(" ", "", selection)
		return(mosaic(x[[selection]], type=type, main=main[selection], legend=legend, ...))
	}
	# perhaps make these model labels more explicit for the menu
	if (ask & interactive()){
		repeat {
			selection <- menu(models, graphics=graphics, title="Select Model to Plot")
			if (selection == 0) break
			else mosaic(x[[selection]], type=type, main=models[selection], legend=legend, ...)
		}
	}
	else {
		nmodels <- length(x)
		mfrow <- mfrow(nmodels)
		if (missing(rows) || missing(cols)){
			rows <- mfrow[1]
			cols <- mfrow[2]
		}

    if (newpage) grid.newpage()
    lay <- grid.layout(nrow=rows, ncol = cols)
		pushViewport(viewport(layout = lay, y = 0, just = "bottom"))
		for (i in 1:rows) {
			for (j in 1:cols){
				if ((sel <-(i-1)*cols + j) > nmodels) break
				pushViewport(viewport(layout.pos.row=i, layout.pos.col=j))
				mosaic(x[[sel]], type=type, main=models[sel], newpage=FALSE, legend=legend, ...)
				popViewport()
			}
		}
	}

}

# from effects::utilities.R
mfrow <- function(n, max.plots=0){
	# number of rows and columns for array of n plots
	if (max.plots != 0 & n > max.plots)
		stop(paste("number of plots =",n," exceeds maximum =", max.plots))
	rows <- round(sqrt(n))
	cols <- ceiling(n/rows)
	c(rows, cols)
}

# from plot.lm: get model call as a string 
# TODO: should use abbreviate() 
mod.call <- function(x) {
        cal <- x$call
        if (!is.na(m.f <- match("formula", names(cal)))) {
            cal <- cal[c(1, m.f)]
            names(cal)[2L] <- ""
        }
        cc <- deparse(cal, 80)
        nc <- nchar(cc[1L], "c")
        abbr <- length(cc) > 1 || nc > 75
        cap <- if (abbr) 
            paste(substr(cc[1L], 1L, min(75L, nc)), "...")
        else cc[1L]
		cap
}

TESTME <- FALSE
if(TESTME) {
# require(grid) 
# gl <- grid.layout(3, 3, widths=rep(1,3), heights=rep(1,3)) 
# gl <- grid.layout(3, 3)
# grid.show.layout(gl) 

library(vcdExtra)
data(JobSatisfaction, package="vcd")
# view all pairwise mosaics
pairs(xtabs(Freq~management+supervisor+own, data=JobSatisfaction), shade=TRUE, diag_panel=pairs_diagonal_mosaic)
modSat <- Kway(Freq ~ management+supervisor+own, data=JobSatisfaction, 
               family=poisson, prefix="JobSat")

mosaic(modSat)              # uses menu, if interactive()
mosaic(modSat, "JobSat.1")  # model label
mosaic(modSat, 2)           # model index

mosaic(modSat, ask=FALSE)   # uses viewports 

# use a different panel function
mosaic(modSat, 1, main=TRUE, panel=sieve)

}