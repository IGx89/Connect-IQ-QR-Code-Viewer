function stringReplace(str, oldString, newString)
{
	var result = str;
	var start = result.find(oldString);

	while (start != null) {
		var end = start + oldString.length();
		result = result.substring(0, start) + newString + result.substring(end, result.length());

		start = result.find(oldString);
	}

	return result;
}

function emptyArray(len) {
	var arr = new[len];
	
	for( var i=0; i<len; i++) {
		arr[i] = 0;
	}
	
	return arr;
}

function twoDimensionalArray(dim1, dim2) {
	// Shout out to all the Java programmers in the house
	var array = new [dim1];
	
	// Initialize the sub-arrays
	for( var i = 0; i < dim1; i++ ) {
	    array[i] = new [dim2];
	}
	
	return array;
}

function max(val1, val2) {
	return val2 > val1 ? val2 : val1;
}

function min(val1, val2) {
	return val2 < val1 ? val2 : val1;
}