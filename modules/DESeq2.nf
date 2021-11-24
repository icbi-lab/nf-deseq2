process DESeq2 {

	conda "conda-forge::python=3.8"

	// input:
	// val(WAASSS)

	output:
	path("test_sandro.txt"), emit: hello

	script:
	"""
	echo "Hello WAASSS!" > test_sandro.txt
	"""
}
