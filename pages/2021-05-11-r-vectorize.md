@def title = "Vectorizing a function in R"
@def hascode = true
@def date = Date(2021, 5, 11)
@def rss = "Vectorizing a function in R"

@def tags = ["all", "notes", "R"]

# Vectorizing a Function in 

I recently refereed a paper for an `R` package, where the function `base::Vectorize` is used.
The documentation is given [here](https://stat.ethz.ch/R-manual/R-devel/library/base/html/Vectorize.html).

As its name suggests, the function vectorizes a customized function written only for scalars.
Unfortunately, it does not given good performance improvement (see [here](https://thatdatatho.com/vectorization-r-purrr/)).

I was quite surprised at first sight, but then I realized it is quite similar to 
broadcasting in `julia`. The latter is done more conveniently: Say the user has defined a function
`f(x)` for a scalar input `x`, then `f.(vec_x)` vectorizes the same function to a vector input `vec_x`.

