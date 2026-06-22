# EpiDomus_Model
A SEIRD compartmental model in R studio, using R-C++ framework with support from the blofeld package (Denwood 2026). Code accompanying the paper: "Estimating the time and scale of HPAIV introduction into commercial turkey flocks using mechanistic simulation modelling", submitted to Preventive Veterinary Medicine Journal. 

# R-C++ Epidemic Simulation Model

This repository contains an R and R-C++ compartmental epidemic simulation model implementing deterministic and stochastic group-based transmission dynamics.

The model supports density-dependent, frequency-dependent, and sublinear transmission processes and simulates disease progression in a structured population using C++-accelerated state updates.

# Model Overview

The simulation implements a compartmental framework with the following states:

- S: Susceptible  
- E: Exposed  
- I: Infectious  
- R: Recovered  
- D: Death

The system is implemented using `Rcpp` for performance and supports both:

- Deterministic simulation
- Stochastic simulation

Transmission can be configured via:

- `contact_power = 0` → Density-dependent transmission  
- `contact_power = 0.5` → Sublinear transmission  
- `contact_power = 1` → Frequency-dependent transmission  

## Features

- Rcpp-accelerated group-based epidemic simulation
- Deterministic and stochastic model variants
- Flexible parameterization of disease dynamics
- Configurable time resolution (`d_time`)
- Pre- and post-exposure simulation phases
- Optional export of simulation outputs

## Installation

### R dependencies

install.packages(
  'blofeld',
  repos = c(CRAN = "https://cran.rstudio.com/",
            "ku-awdc" = "https://ku-awdc.github.io/drat/")
)

```r
install.packages(c(
  "Rcpp",
  "tidyverse",
  "dplyr",
  "purrr",
  "tidyr",
  "patchwork"
))
```

## Citation

If you use this model in academic work, please cite:

@software{carapeto2026epidomusmodel,
  author = {Carapeto, Sandra and Denwood, Matt and Boklund, Anette and Kjær, Lene and Kirkeby, Carsten},
  title = {EpiDomus Model},
  year = {2026},
  url = {https://github.com/SandraCarapeto24/EpiDomusModel}
}

Or cite the repository directly:
Custom Rcpp epidemic simulation model, available at:
https://github.com/SandraCarapeto24/EpiDomusModel


