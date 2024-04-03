# Building reproducible analytical pipelines with R
# Chapter 11 - Packaging your code

# load packages
if (!require("fusen")){
     install.packages("fusen")
     library(fusen)
}

# quickstart
fusen::create_fusen(path = "fusen.quickstart",
                    template = "minimal")

# set and try pkgdown documentation website
usethis::use_pkgdown()
pkgdown::build_site()

