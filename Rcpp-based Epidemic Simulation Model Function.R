# ---------------------------------------------------------
# Rcpp Simulation Model
#
# Deterministic and stochastic compartmental epidemic model
# implemented using Rcpp for fast group-based simulation.
#
# Repository: https://github.com/SandraCarapeto24/EpiDomusModel
# --------------------------------------------------------- 

install.packages(
  'blofeld',
  repos = c(CRAN = "https://cran.rstudio.com/",
            "ku-awdc" = "https://ku-awdc.github.io/drat/")
)

install.packages(c(
  "Rcpp",
  "tidyverse",
  "dplyr"
))

library("blofeld")
library("Rcpp")
library("tidyverse")
library("dplyr")




run_rcpp_model <- function(
    run_type = "deterministic", # Select - to run deterministic or stochastic.
    beta_clinical, # Transmission Rate
    contact_power, #Transmission Function used - Frequency-dependent, Density-dependent and Sublinear function
    initial_exposed_animals, #At the moment of introduction
    mortality_I = 0.61, #Disease-induced mortality
    d_time, #internal time step
    save_results = TRUE,
    save_prefix = NULL,
    n_per_day = 1 #data extraction 1 => one per day
) {
  stopifnot(d_time > 0)
  
  if (length(find("Group")) == 0) sourceCpp("testRcppnew.cpp") #Rcpp file needed to run the model, where the subcompartments are typed
  
  if (run_type == "deterministic") {
    Group <- DeterministicGroup
    Pop   <- DeterministicPop
  } else if (run_type == "stochastic") {
    Group <- StochasticGroup
    Pop   <- StochasticPop
  } else {
    stop("Unknown run_type. Use 'deterministic' or 'stochastic'.")
  }
  
  transmission_type <- c(
    "0"   = "Density-Dependent Transmission",
    "0.5" = "Sublinear Transmission",
    "1"   = "Frequency-Dependent Transmission"
  )
  
  if (!as.character(contact_power) %in% names(transmission_type)) {
    stop("contact_power must be 0, 0.5, or 1.")
  }
  
  transmission_type_name <- transmission_type[as.character(contact_power)]
  
  pars <- list(
    beta_subclin = 0,
    beta_clinical = beta_clinical,
    contact_power = contact_power,
    incubation = 1, #latent period rate 
    progression = 0,
    healing = 0,
    recovery = 0.29, #recovery rate
    reversion = 0,
    waning = 0, 
    vaccination = 0,
    mortality_E = 0,
    mortality_L = 0,
    mortality_I = mortality_I,
    mortality_D = 0,
    death = 0.00086, #background mortality rate applied in all comparmtents except D compartment
    d_time = d_time
  )
  
  gps <- list(
    new(Group) |> (\(g) {
      g$set_parameters(pars)
      g$set_state(list(S = 6000), distribute = FALSE) #population size = 6000, start with 6000 susceptible individuals
      g
    })()
  )
  
  pop <- new(Pop, gps)
  
  # PRE-EXPOSURE PERIOD
  as.list(1:(50 * n_per_day)) |> #I can change the day of exposure here! Now it is day 50!
    map(\(x){
      
      pop$update(1/(n_per_day * d_time),1) # matrix update by minute
      
      lapply(gps, \(g) g$get_state()) |>
        bind_rows(.id = "Group")
    }) |>
    bind_rows() -> pre
  
  # introduce exposure
  cS <- gps[[1]]$get_state()$S
  stopifnot(cS > initial_exposed_animals)
  
  gps[[1]]$set_state(list(S = cS - initial_exposed_animals, E = initial_exposed_animals),FALSE)
  
  # POST-EXPOSURE PERIOD
  as.list(1:(100 * n_per_day)) |>
    map(\(x){
      
      pop$update(1/(n_per_day * d_time), 1) # matrix update by minute
      
      lapply(gps, \(g) g$get_state()) |>
        bind_rows(.id = "Group")
    }) |>
    bind_rows() -> post
  
  outputdf <- bind_rows(pre, post) |>
    rename(D = M) |> # Just change to keep D as death to due the disease!
    select(-Group) |>
    mutate(transmission_type = transmission_type_name, d_time=d_time)
  
  # --------------------
  # SAVE RESULTS (optional)
  # --------------------
  if (save_results) {
    prefix <- if (is.null(save_prefix)) {
      paste0(
        "ModelRcpp_",
        transmission_type_name, "_",
        beta_clinical, "_",
        initial_exposed_animals, "_",
        d_time, "_",
        n_per_day
      )
    } else {
      save_prefix
    }
    
    df_file <- paste0(prefix, "_output.xlsx")
    writexl::write_xlsx(outputdf, df_file)
    
    assign(paste0(prefix, "_df"), outputdf, envir = .GlobalEnv)
    
    message("Saved data to: ", df_file)
  }
  
  return(outputdf)
}
#Example
run_rcpp_model(beta_clinical = 2, contact_power = 0,initial_exposed_animals = 1, d_time = (1/(24*60)), save_results = TRUE, n_per_day=1)
