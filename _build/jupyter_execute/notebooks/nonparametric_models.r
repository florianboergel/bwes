x_values = c(0,1,2,3)
y_values = c(1,2,4,1)
plot(x_values,y_values)

slopes = c(-1,2,0,-3)
my_splinefunction = splinefunH(x=x_values, y=y_values, m=slopes)  # determine spline function
x_axis = seq(from=0,to=3,by=0.1)                                  # define an x axis vector
my_spline = my_splinefunction(x_axis)                             # apply the function to the x values to obtain y values

# now plot the spline as line and the knots as points
plot(x_axis,my_spline,type="l")
points(x_values,y_values,col="red",pch=15)


