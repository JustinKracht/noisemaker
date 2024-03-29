% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/get_wb_mod.R
\name{get_wb_mod}
\alias{get_wb_mod}
\title{Find an \code{lm} model to use with the Wu & Browne (2015) model error method}
\usage{
get_wb_mod(mod, n = 50, values = 10, lower = 0.01, upper = 0.095)
}
\arguments{
\item{mod}{A \code{fungible::simFA()} model object.}

\item{n}{The number of times to evaluate \code{wb()} at each point.}

\item{values}{The number of target RMSEA values to evaluate between 0.02 and
0.1.}

\item{lower}{(scalar) The smallest target RMSEA value to use.}

\item{upper}{(scalar) The largest target RMSEA value to use.}
}
\value{
(\code{lm} object) An \code{lm} object to use with the \code{\link{wb}}
function to obtain population correlation matrices with model error that
have RMSEA values closer to the target RMSEA values. The \code{lm} object will
predict a \code{target_rmsea} value that will give solutions with (median) RMSEA
values close to the desired RMSEA value.
}
\description{
The Wu & Browne (2015) model error method takes advantage of the relationship
between v and RMSEA:
}
\details{
\deqn{v = RMSEA^2 + o(RMSEA^2).}

As RMSEA increases, the approximation \eqn{v ~= RMSEA^2} becomes worse. This
function generates population correlation matrices with model error for
multiple target RMSEA values and then regresses the target RMSEA values on
the median observed RMSEA values for each target. The fitted model can then
be used to predict a \code{target_rmsea} value that will give solutions with RMSEA
values that are close to the desired value.
}
\examples{
mod <- fungible::simFA(Seed = 42)
set.seed(42)
wb_mod <- get_wb_mod(mod)
noisemaker(mod, method = "WB", target_rmsea = 0.05, wb_mod = wb_mod)
}
