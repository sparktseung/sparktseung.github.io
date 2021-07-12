@def title = "Spark's Work"
@def tags = ["all", "homepage"]

# Acedemic Stuff

**LRMoE**:

The **L**ogit-weighted **R**educed **M**ixture-**o**f-**E**xperts model is a flexible
framework for modelling insurance claim numbers and claim amounts. Theoretical developments
and some applications can be found in [Fung et al. (2019)](https://www.sciencedirect.com/science/article/abs/pii/S0167668719303956) and [Fung et al. (2019)](https://www.cambridge.org/core/journals/astin-bulletin-journal-of-the-iaa/article/abs/class-of-mixture-of-experts-models-for-general-insurance-application-to-correlated-claim-frequencies/E9FCCAD03E68C3908008448B806BAF8E).

In this project, we implement this model in `julia` as a statistical software package `LRMoE.jl`.
The source code and package documentation are given [here](https://github.com/sparktseung/LRMoE.jl) and 
[here](https://work.sparktseung.com/LRMoE.jl/dev/). A paper accompanying this package has been published
in the Annals of Actuarial Science ([link](https://www.cambridge.org/core/journals/annals-of-actuarial-science/article/abs/lrmoejl-a-software-package-for-insurance-loss-modelling-using-mixture-of-experts-regression-model/18B8F5C17733C4DBAF2F921E08372DD8)).

We recommend using `julia` as it provides great numerical performance. Meanwhile, an `R` version is also
available but is currently not regularly maintained (see [here](https://github.com/sparktseung/LRMoE)).

# Personal Notes

[All](/tag/notes)

Latest:

{{ recentblogposts 3 }}

