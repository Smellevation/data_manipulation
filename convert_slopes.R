# Read in centers of downtown Seattle grid. Compute spacing. Construct grid
# polygons around them. Make a SpatialPolygonsDataFrame including the slope.

# Note for this initial database:
# This expects a file of center points of grid "squares". We don't construct
# the grid, because we need to be compatible with grade data extracted from the
# USGS Digital Elevation Model. It was divided into a square grid in a local
# projection. The center points of that grid were converted to longitude and
# latitude, WGS84. In that form, the latitudes are no longer evenly spaced.
# We avoid discrepancies by basing grid cells on those from the dataset.

# We may revisit this later...

require(sp)

# Change directory to where the data file is.
# setwd("~/codeforseattle/city4all2017")
# This contains three columns, longitude, latitude, and a value proportional
# to slope.
slope_data_raw <- read.csv("Slope_xyz.ssv", header=FALSE, sep=" ", col.names=c("x", "y", "slope"))

# Make sure these are in increasing order by both x and y coordinates.
# A look at the original csv data shows that it iterates over x within each
# y value, i.e. y remains the same as x steps through its set of values.
# Each y values has 202 x values. Within each y, the x values increase.
# However, the y values are in decreasing order. Change both so that they
# are increasing.
order_idx <- order(slope_data_raw$y, slope_data_raw$x)
slope_data_sorted <- slope_data_raw[order_idx, ]

# Get unique x and y values, and make sure they remain in sorted order.
unique_x <- sort(unique(slope_data_sorted$x))
unique_y <- sort(unique(slope_data_sorted$y))
# Make rectangular grid polygons with centers at these points. Want to split
# half way between the coordinates. For the edge points, use the same distance
# outward as inward. The easiest way to do this is to add an extra point on
# each end at the "center" of a non-existent extra grid cell. There we don't
# need a special case during vector computations.
low_x <- unique_x[1] - (unique_x[2] - unique_x[1])
#low_x <- 2 * unique_x[1] - unique_x[2]
num_x <- length(unique_x)
high_x <- unique_x[num_x] + (unique_x[num_x] - unique_x[num_x - 1])
# Tack those on the ends.
unique_x <- c(low_x, unique_x, high_x)
# Same for y.
low_y <- unique_y[1] - (unique_y[2] - unique_y[1])
num_y <- length(unique_y)
high_y <- unique_y[num_y] + (unique_y[num_y] - unique_y[num_y - 1])
unique_y <- c(low_y, unique_y, high_y)

# Now the polygon bounds are the midpoints between adjacent coordinates.
# Add half the difference between adjacent coordinates to the lower coordinates
# of the pair.
diff_x <- unique_x[2 : (num_x + 2)] - unique_x[1 : (num_x + 1)]
diff_y <- unique_y[2 : (num_y + 2)] - unique_y[1 : (num_y + 1)]
grid_x <- unique_x[1 : (num_x + 1)] + (diff_x / 2.0)
grid_y <- unique_y[1 : (num_y + 1)] + (diff_y / 2.0)

# Construct a polygon for each row in the sorted data. The most straightforward
# way to do this is with a double loop, appending to a list. This is highly
# inefficient in R, not because it is not vectorized, but because R has
# collection objects like vector, list, matrix *are immutable*. Assigning to an
# element, causes an entire new collection object to be created. This it is no
# use to pre-allocate the entire vector / list / matrix -- it will just be
# thrown away on every assignment. Options to deal with this are: Write a
# C function to do the work. Use the mutatr package. Use Python. Because this
# is for a 2-day hackathon, we'll just let R toss the objects, and call the
# garbage collector.
#
# Note also we cannot use GridTopology, as we are not assured that the spacing
# is the same between points in the original data. In fact, it is *not* expected
# to be the same, as this started as an evenly spaced grid *in a state plane
# projection*, and was converted to WGS84 lon lat.