library(spdep)
library(performance)


model_diagnostics <- function(model, longs = NULL, lats = NULL, k = 5, hist_bins = 30, plot_col = "green", lwd = 2, nsim = 100) {

  par(mfrow = c(2, 2))

  # Homoscedasticity check
  plot(resid(model) ~ fitted(model), main = "Residuals vs Fitted", xlab = "Fitted values", ylab = "Residuals")
  abline(h = 0, col = "red")

  # Residuals distribution check
  hist(resid(model), breaks = hist_bins, main = "Residuals Distribution", xlab = "Residuals", col = "lightblue")

  # Multicollinearity check
  print("Multicollinearity Check (VIFs):")
  print(check_collinearity(model))

  # Spatial Autocorrelation (SAC) Check - only if lat/lon coordinates are provided
  if (!is.null(longs) && !is.null(lats)) {
    coords <- cbind(longs, lats)
    coords <- as.matrix(coords, longlat = TRUE)

    # Nearest neighbors based on provided 'k'
    k1 <- knn2nb(knearneigh(coords, k = k, longlat = TRUE))
    
    is_symmetric <- is.symmetric.nb(k1)
    if (is_symmetric) {
      print("The neighborhood graph is symmetric.")
    } else {
      print("Warning: The neighborhood graph is not symmetric.")
    }

    # Max distance for neighbor calculation
    max_dist <- max(unlist(nbdists(k1, coords)))

    # Spatial weights based on neighbor distances
    spat_weight <- dnearneigh(coords, 0, max_dist, longlat = FALSE)

    # Plot spatial weights
    plot(spat_weight, coords, col = plot_col, lwd = lwd, main = "Spatial Neighbors")

    # Create list of weights for Moran's I calculation
    spat_weight_w <- nb2listw(spat_weight, glist = NULL, style = "W", zero.policy = FALSE)

    # Moran's I test results
    print("Moran's I Test (without randomisation):")
    print(moran.test(residuals(model), listw = spat_weight_w, randomisation = FALSE)$estimate[["Moran I statistic"]])

    print("Moran's I Test (with randomisation):")
    print(moran.test(residuals(model), listw = spat_weight_w, randomisation = TRUE)$estimate[["Moran I statistic"]])

    print("Moran's I Test (two-sided alternative hypothesis):")
    print(moran.test(residuals(model), listw = spat_weight_w, randomisation = FALSE, alternative = "two.sided")$estimate[["Moran I statistic"]])

    # Monte Carlo Moran's I test with nsim parameter
    print(paste("Monte Carlo Moran's I Test with", nsim, "simulations:"))
    print(moran.mc(residuals(model), spat_weight_w, nsim = nsim)$statistic)
  } else {
    print("Spatial Autocorrelation (SAC) not computed because 'longs', 'lats', or 'k' was not provided.")

  }
  
}
