#Global Variables
DEBUG 			 = false
LOAD_LIBS		 = false
JULIA_PROMPT	 = "\e[0;32;246mjulia>\e[0m "
T 				 = 0
graph_write_path = "$(pwd())/io/write/"
graph_read_path  = "$(pwd())/io/read/"

#intro functions
function debug(str)
	if DEBUG println("DEBUG>> $str") end
end
function julia(str)
	println("$JULIA_PROMPT $str")
end
julia("Precompile started[\"l4.jl\"]")
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
    Pkg.add("DataStructures")
    Pkg.add("Plots")

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
# 
# try
	using Suppressor
	using ProgressMeter
	using Random
	using DelimitedFiles
	using DataStructures
	using Plots
#  catch e 
# 	julia("Woah there buddy! You dont have the packages I need.")
# 	julia("Go to the directory l4.jl is in and change settings.txt to have the line:")
# 	julia("\"getlibs = 1\"")
# 	exit()
# end
julia("Precompile complete: enjoy effeciency and speed courtesy of julia.")

#progress counter
p = Progress(3,1)

#main functionality
function random_graph(nOfEdges, nOfNodes)
	nodes 		= string.(1:nOfNodes)

	parentNodes = append!(nodes, rand(nodes, nOfEdges - nOfNodes))
	parentNodes = shuffle(parentNodes)

	childNodes  = nodes
	childNodes  = shuffle(childNodes)

	for i = 1:nOfEdges
		parentNodes[i] = "N$(parentNodes[i])"
		childNodes[i]  = "N$(childNodes[i])"
		if(parentNodes[i] == "N") parentNodes[i] = "N1" end
		if(childNodes[i] == "N") childNodes[i] = "N1" end
	end

	links		= [parentNodes childNodes]

	return links
end

function write_graph( graph, path) #Include data for in/out
	io = IOBuffer()

	for i = 1:size(graph)[1]-1
	    print(io, "$(graph[i,1])\t$(graph[i,2])\n")
	end
	print(io, "$(graph[size(graph)[1],1])\t$(graph[size(graph)[1],2])")

	out = open(path,"w")
	write(out, String(take!(io)))
	close(out)
end

function read_graph( path )
	graph = readdlm(path, '\t', String, '\n')
	return graph
end

function compare_graph(a, b)
	if size(a) != size(b) return false end
	for i = 1:size(a)[1]
		if a[i] != b[i] return false end
	end
	return true
end

# function DFS_R(G)
# 	data = make_data(G)
# 	for key in keys(G)
# 		if(!data[key][1])
# 			data = DFS_R2(G, data, key)
# 		end
# 	end
# end


function DFS_R(G)
	global T = 0
	data = make_data(G)
	for key in keys(G)
		if( !data[key][1] )
			data = DFS_R2(G, data, key)
		end
	end
	return data
end

function DFS_R2(G, data, key)
	global T 
	data[key][2] = T
	data[key][1] = true
	global T += 1
	for neighbour in G[key]

		if( !data[neighbour][1] )
			data[neighbour][4] = key
			data[key][1]	  = true
			data = DFS_R2(G,data,neighbour)
		end
	end

	data[key][3] = T
	global T += 1
	return data
end

function DFS_I(G)
	global T = 0
	data = make_data(G)
	
	for key in keys(G)
		if(!data[key][1])
			S = Stack{String}()
			push!(S, key)
			data[key][1] = true
			data[key][2] = T
			T += 1
			data = DFS_I2(G, data, S)
		end
	end	

	return data
end

function DFS_I2(G, data, S)
	global T
	while( !isempty(S) )
		value = pop!(S)
		for neighbour in G[value]
			if(!data[neighbour][1])
				push!(S, neighbour)
				data[neighbour][1] = true
				data[neighbour][2] = T
				data[neighbour][4] = value
				T += 1
			end
		end
	    data[value][3] = T
	    T += 1
	end
	return data
end

# function DFS_I(G)
# 	global T = 0
# 	data = make_data(G)
# 	s = Stack{String}()
# 	for key in keys(G)
# 		push!(s, key)
# 	end
# 	while( !isempty(s) )
# 		val = pop!(s)
# 		explore_node(G, data, s, val)
# 	end
# end

# function explore_node(G, data, stack, key)
# 	global T
# 	if(!data[key][1])
# 		data[key][1] = true
# 		data[key][2] = T
# 		T += 1
# 		push!(stack, key)
# 	else if 

# 	end
# end


# 
# function DFS_recursive( graph )
# 	data = make_data(graph)
# 	DFS_recursive(graph, first(graph)[1], data, 0)
# end

# function DFS_recursive(graph, node, data, v)
# 	data[node] = (true, v, 0)
# 	pre = v
# 	for neighbour in graph[node]
		
# 		if(!data[neighbour][1])
# 			v += 1
# 			DFS_recursive(graph, neighbour, data, v)
# 		# else
# 		# 	data[neighbour] = (true, data[neighbour][2], v)
# 		end
# 	end
# 	println("$node pre: $pre post: $v")
# end

function toNodeList(graph)
	n = size(graph)[1]
	nodes = Dict()
	for i = 1:n
		if( !haskey(nodes, graph[i,1]) )
			nodes[graph[i,1]] = Set()
		end
		if( !haskey(nodes, graph[i,2]))
			nodes[graph[i,2]] = Set()
		end
		push!(nodes[graph[i,1]], graph[i,2])
		push!(nodes[graph[i,2]], graph[i,1])
	end
	return nodes
end

function printNodeList(graph)
	io = IOBuffer()
	for key in keys(graph)
		println(io, "$key:")
		for val in graph[key]
			println(io, "\t$val")
		end
		println(io,"")
	end
	print(String(take!(io)))
end

function make_data(graph)
	result = Dict()
	for key in keys(graph)
		result[key] = [false, -1, -1, "Start Point"]
	end
	return result
end

function allNodes(graph)
	n 	  = size(graph)[1]
	edges = Set()
	for i = 1:n
		push!(edges, graph[i,2])
		push!(edges, graph[i,1])
	end
	return edges
end

function print_graph( graph )
	# max = size(graph)[1] > 100 ? 100 : size(graph)[1]
	max = size(graph)[1]
	println("Graph size() = $(size(graph)[1])")
	io = IOBuffer()
	for i = 1:max
	    print(io, "[$i]:\t$(graph[i,1])\t->  $(graph[i,2])\n")
	end
	println(String(take!(io)))
end

function print_data( data )

	for key in keys(data)
		println("key = $key : $(data[key])")
	end
end

function structure()
	files  = isdir("io")
	plots  = isdir("plots")
	reads  = false
	writes = false
	if files
		reads  = isdir("io/read")
		writes = isdir("io/write")
	end 
	if !plots mkdir("plots") end
	if !files mkdir("io"); mkdir("io/read"); mkdir("io/write");	else
		if !reads  mkdir("io/read")  end
		if !writes mkdir("io/write") end
	end
	return convert(Int8, files + plots + reads + writes) 
end

function clean_dirs()
	rm("io/write", 	recursive = true, force = true)
	rm("plots/",	recursive = true, force = true)
	x = structure()
end

function testall()
	contents = readdir("io/read")
	for file in contents
		graph_0 = read_graph("$(graph_read_path)$file")
		graph_1 = toNodeList(graph_0)
		println("\n=====================\nFor $(file):\n")
		printNodeList(graph_1)
		println("recursive: ")
		data = DFS_R(graph_1)
		print_data(data)
		println("Iterative: ")
		data = DFS_I(graph_1)
		print_data(data)


		
	end

	runtime_RN = zeros(100)
	runtime_RE = zeros(100)
	runtime_IN = zeros(100)
	runtime_IE = zeros(100)

	for i = 1:100
		G = random_graph(100*100,100*i)
		G = toNodeList(G)
		G_0 = random_graph(100*i,100)
		G_0 = toNodeList(G_0)
		runtime_RN[i] = @elapsed DFS_R(G)
		runtime_IN[i] = @elapsed DFS_I(G)
		runtime_RE[i] = @elapsed DFS_R(G_0)
		runtime_IE[i] = @elapsed DFS_I(G_0)
	end
    pyplot()
    x = range(1,100)
    y = range(1,100)
    f1(x,y) = runtime_RN[x] / runtime_RE[x]
    f2(x,y) = runtime_IN[x] / runtime_IE[x]
    plot(x,y,f1,st=:surface,camera=(-30,30))
end


clean_dirs()
testall()
