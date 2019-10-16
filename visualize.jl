#Global Variables
DEBUG 			= false
LOAD_LIBS		= false
JULIA_PROMPT	= "\e[0;32;246mjulia>\e[0m "

#intro functions
function debug(str)
	if DEBUG println("DEBUG>> $str") end
end
function julia(str)
	println("$JULIA_PROMPT $str")
end
julia("Precompile started[\"visualize.jl\"]")
function getSettings()
	open("settings.txt") do f 
		for (i,line) in enumerate(eachline(f))
			if line == "getlibs = 1" 	global LOAD_LIBS 	= true end
			if line == "debug = 1" 		global DEBUG 		= true end
		end
	end
end


#Loading settings 
getSettings()

if LOAD_LIBS
	julia("Loading libs due to: \'getlibs = 1\'")
    using Pkg
    Pkg.add("ProgressMeter")
    Pkg.add("Suppressor")
    Pkg.add("RCall")

    julia("Loading libs complete -> \'getlibs = 0\' now")

    file = ""
    open("settings.txt") do f 
    	global file
		for (i,line) in enumerate(eachline(f))
			if line == "getlibs = 1" file = "$(file)getlibs = 0\n" else
				file = "$file$line\n"
			end
		end
	end
	path = open("settings.txt","w")
	write(path, file)
	close(path)
end


try
	using ProgressMeter
	using Suppressor
catch e 
	julia("Woah there buddy! You dont have the packages I need.")
	julia("Go to the directory l4.jl is in and change settings.txt to have the line:")
	julia("\"getlibs = 1\"")
	exit()
end
@suppress using RCall
try
	@suppress reval("suppressPackageStartupMessages(library(igraph))");
catch e
	julia("Install igraph in R, using r studio or the cli interface.")
	julia("Error R has no package \'Igraph\'");
	exit()
end
julia("Precompile complete: enjoy effeciency and speed courtesy of julia.")

#progress counter
p = Progress(3,1)

function plot( file_path, write_path, name )
	@rput file_path
	@rput write_path
	@rput name
	R"""
		graph.plot <- function(links){
		  net <- graph_from_data_frame( d=links, directed=F ) 
		  par(bg="black")
		  plot(net, 
    			    layout=layout.circle,

			    # === vertex
			    vertex.color = rgb(0.8,0.4,0.3,0.8),          
			    vertex.frame.color = "white",                 
			    vertex.shape="circle",                        
			    vertex.size=14,                               
			    vertex.size2=NA,                              
			    
			    # === vertex label
			    vertex.label.color="white",                  
			    vertex.label.font=2,                          
			    vertex.label.cex=4,                           
			    vertex.label.dist=0,                          
			    vertex.label.degree=0 ,                       
			    
			    # === Edge
			    edge.color="white",                           
			    edge.width=4,                                 
			    edge.arrow.size=1,                            
			    edge.arrow.width=1,                           
			    edge.lty="solid",                             
			    edge.curved=0.3                          
			    )
		  
		  return (NULL)
		}

		#Read the graph file, return the inside data. An option to plot or not plot by specifying plot parameter.
		graph.from.file <- function(input.file, plot=TRUE){
		  ##
		  links <- read.table( input.file, header = FALSE, sep = '\t', quote = "", stringsAsFactors = FALSE)
		  colnames(links) <- c("from", "to", "in", "out") 
		  ##
		  if(plot){
		  	jpeg(paste(write_path,name,sep=""),width = 1920, height = 1920)
		    	graph.plot(links)
		    	dev.off()
		  }
		  return (links)
		}
		graph.from.file(file_path, plot=TRUE)
	"""
end

function plot_all()
	contents = readdir("io/write")
	for file in contents
		@show file
		plot("io/write/$file","plots/","$(file[1:length(file)-4]).jpeg")
	end
end

plot_all()
