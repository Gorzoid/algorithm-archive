local function frequency_array(str)
	-- Collect all frequency values into a dict
	local map = {}
	for c in str:gmatch"." do
		map[c] = (map[c] or 0) + 1
	end
	
	-- Dump each key value pair into a contigious array
	local arr = {}
	for k,v in pairs(map) do
		arr[#arr+1] = {k,v}
	end
	table.sort(arr,function(a,b) return a[2] > b[2] end)
	return arr
end

function build_huffman_tree(message)

	local freq = frequency_array(message)

	while #freq > 1 do
		
		-- Take two of the least frequent nodes
		local node1, node2 = table.remove(freq), table.remove(freq)
		
    -- Group node values in first index, and sum of node frequencies in second
		local node3 = {{node1[1],node2[1]},node1[2]+node2[2]}
	
		local flag -- Did we insert it inside the array
		for i = 1,#freq do
			if freq[i][2] > node3[2] then
				table.insert(freq, i, node3)
				flag = true
				break
			end
		end
		if not flag then
			table.insert(freq, node3)
		end
	end
	
	return freq[1][1] -- Return value of only element in freq array
end

local function _create_codebook(node,tbl,code)
	if type(node) == "string" then
		tbl[node] = code -- if node is a leaf then add it to codebook
	else
		_create_codebook(node[1], tbl, code.."0") -- Left side
		_create_codebook(node[2], tbl, code.."1") -- Right side
	end
end

function create_codebook(tree)
	local tbl = {}
	_create_codebook(tree, tbl, "")
	return tbl
end

function huffman_encode(codebook, message)
	local encoded_chars = {}
	for c in message:gmatch(".") do
		encoded_chars[#encoded_chars+1] = codebook[c]
	end
	return table.concat(encoded_chars) -- table.concat to avoid slow string bufferin
end

local function _huffman_decode(node, bitstring, i)
	if type(node) == "string" then
		return node,i
	end
	if bitstring:sub(i,i) == "0" then
		return _huffman_decode(node[1], bitstring, i+1)
	elseif bitstring:sub(i,i) == "1" then
		return _huffman_decode(node[2], bitstring, i+1)
	end
end

function huffman_decode(tree, bitstring)	
	local decoded_chars, i = {}, 1
	while i <= #bitstring do
		decoded_chars[#decoded_chars+1], i = _huffman_decode(tree, bitstring, i)
	end
	
	return table.concat(decoded_chars)
end

local message = "bibbity_bobbity"

local tree = build_huffman_tree(message)
local codebook = create_codebook(tree)

local bitstring = huffman_encode(codebook, message)
print("Encoded: " .. bitstring)

print("Decoded: " .. huffman_decode(tree, bitstring))
