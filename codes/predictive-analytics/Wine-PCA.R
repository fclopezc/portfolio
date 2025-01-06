# Importa data
wine.df <- read.csv("datasets/Wine.csv")

# PCA: Baseline----
pcs <- prcomp(wine.df[,-1])
summary(pcs)

# Explain why the value for PC1 is so much greater than that of any other column?

cat("In PCA, the first principal component (PC1) captures the direction with 
    the highest variance, which is why its standard deviation is much larger 
    compared to the other components.")

# PCA: Normalized data----
pcs.norm <- prcomp(wine.df[,-1], scale. = T)
summary(pcs.norm)

cat("Normalization scales all variables to have equal variance, so no single 
    variable dominates the analysis. Compared to the baseline PCA, the variance 
    is now distributed more evenly across components, and the proportion of 
    variance explained by PC1 is much lower, indicating a more balanced contribution 
    from all variables.")

# PCA: Visualization----
# Extract PC1 and PC2 scores
pc.scores <- pcs.norm$x

# Create a scatterplot of PC1 vs. PC2, color-coded by Wine Type
plot(pc.scores[, 1], pc.scores[, 2], 
     xlab = "PC1", ylab = "PC2", 
     main = "PC1 vs PC2 Scatterplot (Color-coded by Wine Type)", 
     col = as.factor(wine.df$Wine), pch = 19)

cat("The PCA scatterplot shows how the data clusters based on the first two PC, highlighting groupings.
    It reveals patterns and relationships in the data by reducing dimensionality while preserving 
    maximum variance.")
