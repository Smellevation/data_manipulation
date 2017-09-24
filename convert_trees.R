# Read in Trees Shapefiles containing lat lon points and export them to a csv file.
# https://data.seattle.gov/dataset/Trees/xg4t-j322

# Useful info on reading and writing:
# https://www.nceas.ucsb.edu/scicomp/usecases/ReadWriteESRIShapeFiles
# https://stackoverflow.com/questions/17341987/r-how-to-write-an-xyz-file-from-a-spatialpointsdataframe

library(sp)
library(rgdal)

# Change directory to where the dataset is.
# setwd("~/codeforseattle/city4all2017")
tree_data <- readOGR(dsn="Trees/WGS84", layer="Trees", stringsAsFactors=FALSE)
saveRDS(tree_data, "tree_data.rds")
write.csv(cbind(coordinates(tree_data), tree_data@data[, c("DIAM", "COMMON_NAM")]), file="tree_data.csv", row.names=FALSE)