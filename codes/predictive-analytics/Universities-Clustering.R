#----Libraries------
library(dplyr)

#----Datasets------
dataset <- read.csv("datasets/Universities.csv")

# Encode categorical variables
dataset$State <- as.numeric(as.factor(dataset$State))
dataset$Public.vs.Private <- as.numeric(as.factor(dataset$Public.vs.Private))-1

str(dataset)

dataset <- na.omit(dataset)
df_norm <- dataset
df_norm[,4:20] <- as.data.frame(sapply(df_norm[,4:20],scale))

#---Hierarchical clustering----

# Manhattan
dist_manhattan <- dist(df_norm[,4:20], method = "manhattan")
hc_manhattan <- hclust(dist_manhattan, method = "complete")

plot(hc_manhattan, hang = -1, main = "Dendrogram (Manhattan Distance)",
     xlab = "Colleges", sub = "", cex = 0.6)


# Euclidean distance and complete linkage
dist_euclidean <- dist(df_norm[,4:20], method = "euclidean")
hc_euclidean <- hclust(dist_euclidean, method = "complete")

plot(hc_euclidean, hang = -1, main = "Dendrogram (Euclidean Distance)",
     xlab = "Colleges", sub = "", cex = 0.6)

##--- Clustering and Comparison of Summary Statistics ----

member.cl <- cutree(hc_manhattan,3)
member.eu <- cutree(hc_euclidean,3)

# Inspect how many observations are in each cluster
table(member.cl)
table(member.eu)

print("Aggregate statistics for Manhattan clusters:")
aggregate(dataset[,4:20],list(member.cl), mean)

print("Aggregate statistics for Euclidean clusters:")
aggregate(dataset[,4:20],list(member.eu), mean)

#---Hierarchical clustering: with categorical variables----

# Manhattan
dist_manhattan <- dist(df_norm[,2:20], method = "manhattan")
hc_manhattan <- hclust(dist_manhattan, method = "complete")

plot(hc_manhattan, hang = -1, main = "Dendrogram (Manhattan Distance)",
     xlab = "Colleges", sub = "", cex = 0.6)

# Euclidean distance and complete linkage
dist_euclidean <- dist(df_norm[,2:20], method = "euclidean")
hc_euclidean <- hclust(dist_euclidean, method = "complete")

plot(hc_euclidean, hang = -1, main = "Dendrogram (Euclidean Distance)",
     xlab = "Colleges", sub = "", cex = 0.6)

##--- Clustering and Comparison of Summary Statistics ----

member.cl <- cutree(hc_manhattan,2)
member.eu <- cutree(hc_euclidean,2)

# Inspect how many observations are in each cluster
table(member.cl)
table(member.eu)

print("Aggregate statistics for Manhattan clusters:")
aggregate(dataset[,2:20],list(member.cl), mean)

print("Aggregate statistics for Euclidean clusters:")
aggregate(dataset[,2:20],list(member.eu), mean)

