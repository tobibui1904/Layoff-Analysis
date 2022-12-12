# Download all neccessary Packages
#using  Pkg
#Pkg.add("DataFrames")
#Pkg.add("CSV")
#Pkg.add("Plots")
#Pkg.add("StatsPlots")

#Packages used for the project
using CSV
using DataFrames
using Plots
using Statistics
using Random
using StatsPlots

# Load the data from kaggle as CSV
df = DataFrame(CSV.File("layoffs_data.csv"))

# filter the data with null values
df = filter(:Laid_Off_Count => Laid_Off_Count -> !(ismissing(Laid_Off_Count) || isnothing(Laid_Off_Count) || isnan(Laid_Off_Count)), df)
df = filter(:Percentage => Percentage -> !(ismissing(Percentage) || isnothing(Percentage) || isnan(Percentage)), df)
df = filter(:Funds_Raised => Funds_Raised -> !(ismissing(Funds_Raised) || isnothing(Funds_Raised) || isnan(Funds_Raised)), df)

# Put the DataFrame to better Table
df = DataFrame(Company = df.Company, 
               Location = df.Location,
               Industry = df.Industry,
               Laid_Off_Count = df.Laid_Off_Count,
               Percentage = df.Percentage,
               Date = df.Date,
               Funds_Raised = df.Funds_Raised,
               Stage = df.Stage,
               Country = df.Country,
               Total_Employee = df.Total_Employee,
                 )

print(df)

# Scatter Plot to see the situation overall
scatter_plot = scatter(df.Company,
    df.Laid_Off_Count,
    label = "Laid_Off_Count/Company",
    title = "Models and Laid_Off_Count/Company",
    xrotation = 90,
    legend =:topleft)

# Comment about the graph: From the plot, we can see that most companies have laid off mostly smaller or equal to 2500. In the x-axis are the top 10 least companies that layoff

display(scatter_plot)
gui()

# Table that counts most Date that Company laid off
df1 = combine(groupby(df, [:Date]), nrow => :count)
df1 = df1[sortperm(df1[:, 2]), :]
print(df1)

# Bar chart of Most Date that Company laid off
p = Plots.bar(df1.Date, df1.count, label= "Date", 
                                    ylabel= "Count", 
                                    xlabel= "Date",
                                    title = "Most Date Layoffs",
                                    size = (1200, 700))

display(p)
gui()

# Comment about the graph: From the plot, we can see that the date that companies layoff in ascending order. In the plot, it shows the 4/2/2020 to be the date that companies layoff mostly: 168 companies

# Table that counts most Industry that Company laid off
df2 = combine(groupby(df, [:Industry]), nrow => :count)
df2 = df2[sortperm(df2[:, 2]), :]
print(df2)

# pie chart for most laid off Industry
labels = ["Marketing", "Retail","Finance"]
colors = ["orange", "blue","red"]
sizes = [61, 71,123]
explode = zeros(length(sizes))
z = pie(sizes, labels = labels, colors = colors, shadow = true, startangle = 90, autopct = "%1.1f%%")

display(z)
gui()

# Comment about the graph: From the plot, we can see that Marketing and Retail have approximately the same count with 61 and 71 respectively. While Finance has the largest count of 123

# Table that counts most Country that Company laid off in reverse order 
df3 = combine(groupby(df, [:Country]), nrow => :count)
df3 = sort(df3, [order(:count, rev=true)])
print(df3)

# Top3 Horizontal Bar chart of Most Date that Company laid off
ticklabel = ["United States", "India", "Canada" ]
chart = bar([559,55,48], orientation=:h, yticks=([559,55,48], ticklabel), yflip=true)

display(chart)
gui()

# Comment about the graph: From the plot, we can see that India and Canada have approximately the same count with 55 and 48 respectively. While United States has the largest count of companies layoff with 559

# Sum of layoffs by Coutry
gdf = groupby(df, :Country)
gdf = combine(gdf, :Laid_Off_Count => sum)
gdf = sort(gdf, [order(:Laid_Off_Count_sum, rev=true)])
print(gdf)

# line chart for Sum of layoffs by Coutry
a = plot(gdf.Country, gdf.Laid_Off_Count_sum,
    xlabel="Country",
    ylabel="Laid_Off_Count_sum",
    title="Sum of layoffs by Coutry",
    size=(1200, 700))

display(a)
gui()

# Comment about the graph: From the plot, we can see that the downward trend of Coutries

# average of layoffs by Country
gdf1 = groupby(df, :Country)
gdf1 = combine(gdf1, :Laid_Off_Count => mean)
gdf1 = gdf1[sortperm(gdf1[:, 2]), :]
print(gdf1)

# line chart for mean of layoffs by Coutry with extra graphic for fun
b = plot(gdf1.Laid_Off_Count_mean, line=:stem, marker=:star, markersize=20)

display(b)
gui()

# Comment about the graph: From the plot, we can see that the upwarding trend with the x-axis is the mean's position from smallest to largest. We can see that the highest average mean of layoffs is 400.015 at position 32.

# Table that counts most Stages that Company laid off in reverse order 
df4 = combine(groupby(df, [:Stage]), nrow => :count)
df4 = sort(df4, [order(:count, rev=true)])

# Sum of layoffs by Stage
gdf2 = groupby(df, :Stage)
gdf2 = combine(gdf2, :Laid_Off_Count => sum)
gdf2 = sort(gdf2, [order(:Laid_Off_Count_sum, rev=true)])

# Merge df4 & gdf2 together 
merger = innerjoin(df4, gdf2, on = :Stage)
print(merger)

# Two y-axis plot of merger DataFrame
fig = plot(merger.Stage, merger.count, ylabel="count", leg=:topright)
fig = plot!(twinx(), merger.Stage, merger.Laid_Off_Count_sum,
    c=:red,
    ylabel="Laid_Off_Count_sum",
    leg=:bottomright,
    size=(1200, 700))

display(fig)
gui()

# Comment about the graph: From the plot, we can see that the downwarding trend of both graphs. As we can see, there are 2 main points that we should notice. The 2 peaks of the Laid_Off_Count_sum graph: the Series A and Series B. Despite the number of companies being laid off are low but Total_Employee being laid off are too huge comparing with the number of companies being laid off.

# Sum of Total_Employee by Stage
#df.Total_Employee = parse.(Float64, df.Total_Employee)
gdf3 = groupby(df, :Stage)
gdf3 = combine(gdf3, :Total_Employee => sum)
gdf3 = sort(gdf3, [order(:Total_Employee_sum, rev=true)])
print(gdf3)

# Sum of Funds_Raised by Stage
gdf7 = groupby(df, :Stage)
gdf7 = combine(gdf7, :Funds_Raised=> sum)
gdf7 = sort(gdf7, [order(:Funds_Raised_sum, rev=true)])
print(gdf7)

# Merge gdf2 & gdf7 together 
merger2 = innerjoin(gdf7, gdf2, gdf3, on = :Stage)
print(merger2)

stack = bar([merger2.Funds_Raised_sum merger2.Laid_Off_Count_sum],
        bar_position = :stack,
        bar_width=0.7,
        xticks=(1:15, merger2.Stage),
        label =["Funds_Raised_sum" "Laid_Off_Count_sum"],
        size=(1200, 700),
        xrotation = 90)

display(stack)
gui()

# Comment about the graph: From the plot, we can see that the Funds_Raised_sum is larger than Laid_Off_Count_sum, which can be a good signal for the upcoming year where we will escape the Recession.

# 2D Scatterplot of Sum of Total_Employee by Stage
ms = rand(15) * 30
xyz = scatter(gdf3.Stage, gdf3.Total_Employee_sum, markersize=ms, size = (1200, 700), xrotation = 90)

display(xyz)
gui()

# Comment about the graph: From the plot, we can see the downwarding trend with IPO having the most total employee and Seed has the least.

# Sum of Funds_Raised by Location
gdf4 = groupby(df, :Location)
gdf4 = combine(gdf4, :Funds_Raised=> sum)
gdf4 = sort(gdf4, [order(:Funds_Raised_sum, rev=true)])
print(gdf4)

# Sum of Laid_Off_Count by Location
gdf5 = groupby(df, :Location)
gdf5 = combine(gdf5, :Laid_Off_Count=> sum)
gdf5 = sort(gdf5, [order(:Laid_Off_Count_sum, rev=true)])
print(gdf5)

# Sum of Total_Employee by Location
gdf6 = groupby(df, :Location)
gdf6 = combine(gdf6, :Total_Employee=> sum)
gdf6 = sort(gdf6, [order(:Total_Employee_sum, rev=true)])
print(gdf6)

# Merge gdf4 & gdf5 & gdf6  together 
merger1 = innerjoin(gdf4, gdf5, gdf6, on = :Location)
print(merger1)

# 3-line charts for 3 different categories
lineplot = plot(merger1.Location , [merger1.Funds_Raised_sum, merger1.Laid_Off_Count_sum, merger1.Total_Employee_sum],
    xlabel="Location",
    ylabel="Sum",
    label=[" Funds_Raised_sum" "Laid_Off_Count_sum" "Total_Employee_sum"],
    leg=:bottomleft,
    size = (1200, 700), 
    xrotation = 90)

display(lineplot)
gui()

# Comment about the graph: From the plot, we can see the downwarding trend of the Total_Employee graph but not with the Funds_Raised_sum and Laid_Off_Count_sum graphs. They are too small comparing to the Total_Employee_sum, which means that companies don't layoff too much employees of their own. Therefore it is a good signal for a return of the tech Industry in the next year.

# boxplot of Laid_Off_Count, Funds_Raised, Percentage
box = boxplot([df.Laid_Off_Count df.Funds_Raised df.Percentage], label=["Laid_Off_Count" "Funds_Raised" "Percentage"])

display(box)
gui()

# Comment about the graph: From the plot, we can see the overall stats of the Laid_Off_Count, Funds_Raised and Percentage are in control since there're not too much outliers except for the Funds_Raised, which is good for the tech Industry's return in the next year. 

# Summary Stats of the DataFrame
stats = DataFrame(Sum = [sum(skipmissing(df.Laid_Off_Count)), sum(skipmissing(df.Funds_Raised)), sum(skipmissing(df.Total_Employee))], 
                  Average = [mean(skipmissing(df.Laid_Off_Count)), mean(skipmissing(df.Funds_Raised)), mean(skipmissing(df.Total_Employee))],
                  Median = [median(skipmissing(df.Laid_Off_Count)), median(skipmissing(df.Funds_Raised)), median(skipmissing(df.Total_Employee))],
                 )

print(stats)



