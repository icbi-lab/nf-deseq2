
process HELLO {

	conda "conda-forge::python=3.8"

	input:
	val(what)

	output:
	path("*.txt"), emit: hello

	script:
	"""
	echo "Hello $what!" > hello.txt
	"""
}
