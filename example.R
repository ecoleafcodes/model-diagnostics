source("model_diagnostics.R")


# Generate synthetic latitude and longitude coordinates
set.seed(123)
n <- 100  # Number of points
longs <- runif(n, -100, -50)  # Random longitudes
lats <- runif(n, 30, 60)  # Random latitudes

# Create synthetic explanatory variables
x1 <- runif(n, 0, 10)
x2 <- rnorm(n, 5, 2)

# Simulate a synthetic response variable with some noise
y <- 3 + 1.5 * x1 - 0.7 * x2 + rnorm(n, 0, 1)

# Fit a linear model (using the synthetic data)
model <- lm(y ~ x1 + x2)

# Test the spatial diagnostics function
cat("\n###### Without SAC ######\n")
model_diagnostics(model)


k <- 4  # Number of neighbors
cat("\n###### With SAC ######\n")
model_diagnostics(model, longs, lats, k)

